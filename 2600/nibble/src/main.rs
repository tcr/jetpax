use regex::Regex;
use std::error::Error;
use std::collections::VecDeque;
use std::fmt::Write;

const IS_ZERO_PAGE: bool = false;

#[derive(Debug, Clone)]
enum Parse {
    NibbleStartKernel(String, isize),
    NibbleIf(String),
    NibbleElse,
    NibbleEndIf,
    NibbleEndKernel,
    NibbleWrite(String, Vec<String>),
    Opcode(String),
}

trait KernelWalker {
    type TNode;

    fn start(&mut self, name: &str, cycles: usize) -> Self::TNode;
    fn end(&mut self, node: Self::TNode);

    fn if_start(&mut self, parent: &mut Self::TNode, cond: &str) -> Self::TNode;
    fn if_else(&mut self, parent: &mut Self::TNode, then_node: &mut Self::TNode) -> Self::TNode;
    fn if_end(&mut self, parent: &mut Self::TNode, then_node: Self::TNode, else_node: Self::TNode);

    fn write(&mut self, parent: &mut Self::TNode, label: &str, values: &[String]);
    fn opcode(&mut self, parent: &mut Self::TNode, value: &str);
}

struct KernelBuild {
    build: String,
    eval: String,
}

impl KernelBuild {
    fn new() -> Self {
        Self {
            build: String::new(),
            eval: String::new(),
        }
    }
}

#[derive(Debug)]
struct BuildState {
    index: usize,
    checkdepth: usize,
    cycles: usize
}

impl BuildState {
    fn with_index(&mut self, index: usize) -> Self {
        BuildState { index, cycles: self.cycles, checkdepth: self.checkdepth }
    }

    fn with_cycles(&mut self, cycles: usize) -> Self {
        BuildState { index: self.index, cycles: self.cycles, checkdepth: self.checkdepth }
    }

    fn with_checkdepth(&mut self, checkdepth: usize) -> Self {
        BuildState { index: self.index, cycles: self.cycles, checkdepth }
    }
}

impl KernelWalker for KernelBuild {
    type TNode = BuildState;

    fn start(&mut self, name: &str, cycles: usize) -> Self::TNode {
        // BUILD
        writeln!(&mut self.build, "    MAC NIBBLE_{}_BUILD", name);
        writeln!(&mut self.build, "    lda #0");

        // EVAL
        writeln!(&mut self.eval, "    MAC NIBBLE_{}", name);
        
        BuildState { index: 0, cycles: 0, checkdepth: 0 }
    }

    fn end(&mut self, node: Self::TNode) {
        if node.checkdepth > 8 {
            panic!("TOO MANY IFs");
        }

        // BUILD
        writeln!(&mut self.build, "    ; [BIT DEPTH] Final: {} (out of 8 bits)", node.checkdepth);
        for i in node.checkdepth..8 {
            writeln!(&mut self.build, "    rol");
        }
        writeln!(&mut self.build, "    ENDM");
        writeln!(&mut self.build, "");
        writeln!(&mut self.build, "");
        writeln!(&mut self.build, "");
        writeln!(&mut self.build, "");

        // EVAL
        writeln!(&mut self.eval, "    ENDM ; {} cycles max", node.cycles);
        writeln!(&mut self.eval, "");
        writeln!(&mut self.eval, "");
        writeln!(&mut self.eval, "");
        writeln!(&mut self.eval, "");
    }

    fn if_start(&mut self, parent_node: &mut Self::TNode, cond: &str) -> Self::TNode {
        let index = parent_node.index + 1;
        let checkdepth = parent_node.checkdepth + 1;
        let mut cycles = parent_node.cycles;

        // BUILD
        writeln!(&mut self.build, ".if_{}:", index);
        writeln!(&mut self.build, "    b{} .else_{}", invert_cond(&cond), index);
        writeln!(&mut self.build, "    sec");
        writeln!(&mut self.build, "    rol");

        // EVAL
        writeln!(&mut self.eval, ".if_{}:", index);
        writeln!(&mut self.eval, "    asl");
        cycles += 2;
        writeln!(&mut self.eval, "    bcc .else_{}", index);
        cycles += 2;

        parent_node
            .with_index(index)
            .with_checkdepth(checkdepth)
            .with_cycles(cycles)
    }

    fn if_else(&mut self, parent_node: &mut Self::TNode, then_node: &mut Self::TNode) -> Self::TNode {
        let index = parent_node.index + 1;
        let checkdepth = parent_node.checkdepth + 1;
        let cycles = parent_node.cycles + 5; // asl + bcc with branch

        let if_token = format!("<<<{}>>>", then_node.index);

        // BUILD
        writeln!(&mut self.build, "{}", if_token);
        writeln!(&mut self.build, "    jmp .endif_{}", index);
        writeln!(&mut self.build, "    ; [BIT DEPTH] #{} If-End @ {}", index, checkdepth);
        writeln!(&mut self.build, ".else_{}:", index);
        writeln!(&mut self.build, "    clc");
        writeln!(&mut self.build, "    rol");

        // EVAL
        writeln!(&mut self.eval, "{}", if_token);
        writeln!(&mut self.eval, "    jmp .endif_{}", index);
        then_node.cycles += 2;
        writeln!(&mut self.eval, ".else_{}:", index);

        parent_node
            .with_index(then_node.index)
            .with_checkdepth(checkdepth)
            .with_cycles(cycles) 
    }

    fn if_end(&mut self, parent_node: &mut Self::TNode, mut then_node: Self::TNode, mut else_node: Self::TNode) {
        let index = parent_node.index + 1;
        let if_token = format!("<<<{}>>>", index);

        // BUILD
        {
            let mut if_token_replacement = String::new();
            writeln!(&mut self.build, "    ; [BIT DEPTH] #{} *If-End @ {}", then_node.index, then_node.checkdepth);
            writeln!(&mut self.build, "    ; [BIT DEPTH] #{} Else-End @ {}", else_node.index, else_node.checkdepth);
            if else_node.checkdepth > then_node.checkdepth {
                // then block needs to advance
                for _ in then_node.checkdepth..else_node.checkdepth {
                    if_token_replacement.push_str(&"    rol\n");
                }
            } else if then_node.checkdepth > else_node.checkdepth {
                // else block needs to advance
                for _ in else_node.checkdepth..then_node.checkdepth {
                    writeln!(&mut self.build, "    rol");
                }
            }
            // Replace token
            self.build = self.build.replace(&if_token, &if_token_replacement);
            writeln!(&mut self.build, ".endif_{}:", index);
        }

        // EVAL
        {
            let mut if_token_replacement = String::new();
            writeln!(&mut self.eval, "    ; [BIT DEPTH] #{} *If-End @ {}", then_node.index, then_node.checkdepth);
            writeln!(&mut self.eval, "    ; [BIT DEPTH] #{} Else-End @ {}", else_node.index, else_node.checkdepth);
            if else_node.checkdepth > then_node.checkdepth {
                // then block needs to advance
                for _ in then_node.checkdepth..else_node.checkdepth {
                    if_token_replacement.push_str(&"    rol\n");
                    then_node.cycles += 2;
                }
            } else if then_node.checkdepth > else_node.checkdepth {
                // else block needs to advance
                for _ in else_node.checkdepth..then_node.checkdepth {
                    writeln!(&mut self.eval, "    rol");
                    else_node.cycles += 2;
                }
            }

            // Balance out cycles
            if else_node.cycles > then_node.cycles {
                // then block needs to advance
                if_token_replacement.push_str(&format!("    sleep {}", else_node.cycles - then_node.cycles));
            } else if then_node.cycles > else_node.cycles {
                // else block needs to advance
                writeln!(&mut self.eval, "    sleep {}", then_node.cycles - else_node.cycles);
            }

            // Replace token
            self.eval = self.eval.replace(&if_token, &if_token_replacement);
            writeln!(&mut self.eval, ".endif_{}:", index);
        }

        parent_node.index = else_node.index;
        parent_node.checkdepth = std::cmp::max(then_node.checkdepth, else_node.checkdepth);
        parent_node.cycles = std::cmp::max(then_node.cycles, else_node.cycles);
    }

    fn write(&mut self, parent_node: &mut Self::TNode, label: &str, values: &[String]) {
        // EVAL
        for (i, value) in values.iter().enumerate() {
            writeln!(&mut self.eval, "    ldx {}", value);
            parent_node.cycles += 2;
            writeln!(&mut self.eval, "    stx [{} + {}]", label, i);
            parent_node.cycles += if IS_ZERO_PAGE { 3 } else { 4 };
        }
    }

    fn opcode(&mut self, parent_node: &mut Self::TNode, opcode: &str) {
        // BUILD
        if opcode.starts_with(".") && !opcode.starts_with(".byte") {
            writeln!(&mut self.build, "{}", opcode);
        } else {
            writeln!(&mut self.build, "    {}", opcode);
        }
    }
}

fn invert_cond(cond: &str) -> &'static str {
    match cond {
        "cs" => "cc",
        "cc" => "cs",
        "ne" => "eq",
        "eq" => "ne",
        "pl" => "mi",
        "mi" => "pl",
        "vc" => "vs",
        "vs" => "vc",
        _ => panic!("unknown {:?}", cond),
    }
}

fn gen_kernel_build(lines: &[Parse]) -> Result<KernelBuild, Box<dyn Error>> {
    let mut code = KernelBuild::new();
    let mut code_queue = VecDeque::new();
    for line in lines {
        match line {
            Parse::NibbleStartKernel(name, cycles) => {
                // Push new node.
                code_queue.push_front(code.start(&name, *cycles as usize));
            }
            Parse::NibbleIf(cond) => {
                // Push if node.
                let mut parent_node = code_queue.pop_front().unwrap();
                let if_node = code.if_start(&mut parent_node, &cond);
                code_queue.push_front(parent_node);
                code_queue.push_front(if_node);
            }
            Parse::NibbleElse => {
                // Handle else node.
                let mut if_node = code_queue.pop_front().unwrap();
                let mut parent_node = code_queue.pop_front().unwrap();
                let else_node = code.if_else(&mut parent_node, &mut if_node);
                code_queue.push_front(parent_node);
                code_queue.push_front(if_node);
                code_queue.push_front(else_node);
            }
            Parse::NibbleEndIf => {
                // Pop if node.
                let mut else_node = code_queue.pop_front().unwrap();
                let mut if_node = code_queue.pop_front().unwrap();
                let mut parent_node = code_queue.pop_front().unwrap();
                let else_node = code.if_end(&mut parent_node, if_node, else_node);
                code_queue.push_front(parent_node);

            }
            Parse::NibbleWrite(label, values) => {
                // Write to node.
                let mut parent_node = code_queue.pop_front().unwrap();
                code.write(&mut parent_node, &label, &values);
                code_queue.push_front(parent_node);
            }
            Parse::Opcode(opcode) => {
                // Write to node.
                let mut parent_node = code_queue.pop_front().unwrap();
                code.opcode(&mut parent_node, &opcode);
                code_queue.push_front(parent_node);
            }
            Parse::NibbleEndKernel => {
                // Pop kernel node.
                let end_node = code_queue.pop_front().unwrap();
                code.end(end_node);
            }
        }
    }
    Ok(code)
}


type KernelDefinition = Vec<Parse>;

fn parse_kernels(
    input_file: &str,
) -> Result<Vec<KernelDefinition>, Box<dyn Error>> {
    let re_nibble_start_kernel = Regex::new(r"^NIBBLE_START_KERNEL\s+(\S.*)\s*,\s*(\S.*)\s*")?;
    let re_nibble_if = Regex::new(r"^NIBBLE_IF\s+(.+)\s*")?;
    let re_nibble_else = Regex::new(r"^NIBBLE_ELSE")?;
    let re_nibble_end_if = Regex::new(r"^NIBBLE_END_IF")?;
    let re_nibble_write = Regex::new(r"^NIBBLE_WRITE\s+([^,]+)(?:\s*,\s*([^,]+))+")?;
    let re_nibble_write_args = Regex::new(r",\s*([^,]+)")?;
    let re_nibble_end_kernel = Regex::new(r"^NIBBLE_END_KERNEL")?;
    
    let re_data = Regex::new(r"^\s*(.+?)\s*(;.*)?$")?;

    let mut kernels = vec![];
    let mut lines = vec![];
    let mut active = false;
    for line in input_file.lines() {
        let line = if let Some(m) = re_data.captures(line) {
            m[1].to_string()
        } else {
            continue;
        };

        if !active {
            if let Some(_) = re_nibble_start_kernel.captures(&line) {
                // Restart
                lines = vec![];
                active = true;
            } else {
                continue;
            }
        }

        let parsed = if let Some(m) = re_nibble_start_kernel.captures(&line) {
            Parse::NibbleStartKernel(m[1].to_string(), m[2].parse()?)
        } else if let Some(m) = re_nibble_if.captures(&line) {
            // Limitation for now until client NIBBLE_IF code figured out
            Parse::NibbleIf(m[1].to_string())
        } else if let Some(_) = re_nibble_else.captures(&line) {
            Parse::NibbleElse
        } else if let Some(_) = re_nibble_end_if.captures(&line) {
            Parse::NibbleEndIf
        } else if let Some(m) = re_nibble_write.captures(&line) {
            // eprintln!("line {:?}", line);
            let selection = re_nibble_write_args.captures_iter(&line).map(|n| {
                // eprintln!("{:?}", n);
                n
            }).map(|n| n[1].to_string()).collect::<Vec<_>>();
            // eprintln!("selection {:?}", selection);
            Parse::NibbleWrite(m[1].to_string(), selection)
        } else if let Some(_) = re_nibble_end_kernel.captures(&line) {
            Parse::NibbleEndKernel
        } else {
            Parse::Opcode(line.to_string())
        };
        lines.push(parsed);

        if let Some(_) = re_nibble_end_kernel.captures(&line) {
            kernels.push(lines.clone());
            active = false;
        }
    }

    Ok(kernels)
}

fn main() -> Result<(), Box<dyn Error>> {
    let input_file = std::fs::read_to_string("../src/game_nibble.s")?;
    let output_build = "../src/nibble_build.s";
    let output_eval = "../src/nibble_eval.s";

    let kernels = parse_kernels(&input_file)?;

    let mut kernel_build = String::new();
    let mut kernel_eval = String::new();
    for lines in &kernels {
        let kernel = gen_kernel_build(&lines)?;
        kernel_build.push_str(&kernel.build);
        kernel_eval.push_str(&kernel.eval);
    }

    std::fs::write(&output_build, &kernel_build)?;
    std::fs::write(&output_eval, &kernel_eval)?;

    println!("{}", output_build);
    println!("{}", kernel_build);
    println!("{}", kernel_eval);

    Ok(())
}
