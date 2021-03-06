use regex::Regex;
use std::error::Error;
use std::collections::VecDeque;
use std::fmt::Write;
use std::collections::HashMap;

const IS_ZERO_PAGE: bool = true;

#[derive(Debug, Clone)]
enum Parse {
    NibbleStartKernel(String, isize),
    NibbleEndKernel,
    NibbleIf(String),
    NibbleElse,
    NibbleEndIf,
    NibbleVar(String),
    NibbleWrite(String, Vec<String>),
    NibbleWriteZeroPage(String, Vec<String>),
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
    fn write_zero_page(&mut self, parent: &mut Self::TNode, label: &str, values: &[String]);
    fn opcode(&mut self, parent: &mut Self::TNode, value: &str);
}

struct KernelBuild {
    name: String,
    vars: HashMap<String, usize>,
    build: String,
    eval: Vec<EvalStep>,
}

impl KernelBuild {
    fn new(name: &str) -> Self {
        Self {
            name: name.to_owned(),
            vars: HashMap::new(),
            build: String::new(),
            eval: vec![],
        }
    }

    fn define_var(&mut self, var: &str) {
        self.vars.insert(var.to_string(), 0);
    }

    fn has_var(&mut self, var: &str) -> bool {
        if let Some(var) = self.vars.get_mut(var) {
            *var += 1;
            true
        } else {    
            false
        }
    }

    fn push_eval(&mut self, step: EvalStep) {
        self.eval.push(step);
    }

    fn eval_replace(&mut self, left: &EvalStep, right: EvalStep) -> bool {
        for item in &mut self.eval {
            if item == left {
                *item = right;
                return true;
            }
        }
        false
    }

    fn eval_output(&self) -> String {
        let mut output = String::new();
        for item in &self.eval {
            use EvalStep::*;
            match item {
                Literal(s) => {
                    writeln!(&mut output, "{}", s);
                }
                Token(index) => {
                    writeln!(&mut output, "; raw token: {}", index);
                }

                LoadImm(s) => {
                    writeln!(&mut output, "    ldx #[ {} ]", s);
                }
                LoadZero(s) => {
                    writeln!(&mut output, "    NIBBLE_RAM_LOAD ldx, {}", s);
                }
                StoreAbs(s) => {
                    writeln!(&mut output, "{}", s);
                }
            }
        }
        output
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
        BuildState { index: self.index, cycles, checkdepth: self.checkdepth }
    }

    fn with_checkdepth(&mut self, checkdepth: usize) -> Self {
        BuildState { index: self.index, cycles: self.cycles, checkdepth }
    }
}

#[derive(Debug, PartialEq)]
enum EvalStep {
    Literal(String),
    Token(usize),

    LoadImm(String),
    LoadZero(String),
    StoreAbs(String),
}

impl KernelWalker for KernelBuild {
    type TNode = BuildState;

    fn start(&mut self, name: &str, cycles: usize) -> Self::TNode {
        // BUILD
        // writeln!(&mut self.build, "nibble_build_{}: subroutine", name);
        writeln!(&mut self.build, "    lda #0");
        writeln!(&mut self.build, "    sta RamNibbleBuildState");

        // EVAL
        // self.push_eval(EvalStep::Literal(format!("nibble_eval_{}: subroutine", name)));
        
        BuildState { index: 0, cycles: 0, checkdepth: 0 }
    }

    fn end(&mut self, node: Self::TNode) {
        if node.checkdepth > 8 {
            panic!("TOO MANY IFs");
        }

        // BUILD
        writeln!(&mut self.build, "    ; [BIT DEPTH] Final: {} (out of 8 bits)", node.checkdepth);
        for i in node.checkdepth..8 {
            writeln!(&mut self.build, "    rol RamNibbleBuildState");
        }

        // EVAL
        self.push_eval(EvalStep::Literal(format!("    ; end: {} cycles", node.cycles)));
    }

    fn if_start(&mut self, parent_node: &mut Self::TNode, cond: &str) -> Self::TNode {
        let index = parent_node.index + 1;
        let checkdepth = parent_node.checkdepth + 1;

        // BUILD
        writeln!(&mut self.build, ".if_{}:", index);
        writeln!(&mut self.build, "    b{} .else_{}", invert_cond(&cond), index);
        writeln!(&mut self.build, "    sec");
        writeln!(&mut self.build, "    rol RamNibbleBuildState");

        // EVAL
        self.push_eval(EvalStep::Literal(format!("    asl")));
        parent_node.cycles += 2;
        self.push_eval(EvalStep::Literal(format!("    bcc .else_{}", index)));
        parent_node.cycles += 2;
        self.push_eval(EvalStep::Literal(format!("    ; parent: {:?}", parent_node)));
        self.push_eval(EvalStep::Literal(format!(".if_{}:", index)));

        parent_node
            .with_index(index)
            .with_checkdepth(checkdepth)
    }

    fn if_else(&mut self, parent_node: &mut Self::TNode, then_node: &mut Self::TNode) -> Self::TNode {
        let index = parent_node.index + 1;
        let checkdepth = parent_node.checkdepth + 1;
        let cycles = parent_node.cycles + 1; // bcc with branch

        let if_token = format!("<<<{}>>>", then_node.index);

        // BUILD
        writeln!(&mut self.build, "{}", if_token);
        writeln!(&mut self.build, "    jmp .endif_{}", index);
        writeln!(&mut self.build, "    ; [BIT DEPTH] #{} If-End @ {}", index, checkdepth);
        writeln!(&mut self.build, ".else_{}:", index);
        writeln!(&mut self.build, "    clc");
        writeln!(&mut self.build, "    rol RamNibbleBuildState");

        // EVAL
        self.push_eval(EvalStep::Token(then_node.index));
        self.push_eval(EvalStep::Literal(format!("    jmp .endif_{}", index)));
        then_node.cycles += 3;
        self.push_eval(EvalStep::Literal(format!(".else_{}:", index)));

        parent_node
            .with_index(then_node.index)
            .with_checkdepth(checkdepth)
            .with_cycles(cycles) 
    }

    fn if_end(&mut self, parent_node: &mut Self::TNode, mut then_node: Self::TNode, mut else_node: Self::TNode) {
        let index = parent_node.index + 1;
        let if_token = format!("<<<{}>>>\n", index);

        // BUILD
        {
            let mut if_token_replacement = String::new();
            writeln!(&mut self.build, "    ; [BIT DEPTH] #{} *If-End @ {}", then_node.index, then_node.checkdepth);
            writeln!(&mut self.build, "    ; [BIT DEPTH] #{} Else-End @ {}", else_node.index, else_node.checkdepth);
            if else_node.checkdepth > then_node.checkdepth {
                // then block needs to advance
                for _ in then_node.checkdepth..else_node.checkdepth {
                    if_token_replacement.push_str(&"    rol RamNibbleBuildState\n");
                }
            } else if then_node.checkdepth > else_node.checkdepth {
                // else block needs to advance
                for _ in else_node.checkdepth..then_node.checkdepth {
                    writeln!(&mut self.build, "    rol RamNibbleBuildState");
                }
            }
            // Replace token
            self.build = self.build.replace(&if_token, &if_token_replacement);
            writeln!(&mut self.build, ".endif_{}:", index);
        }

        // EVAL
        {
            let mut if_token_replacement = String::new();
            if else_node.checkdepth > then_node.checkdepth {
                // then block needs to advance
                for _ in then_node.checkdepth..else_node.checkdepth {
                    if_token_replacement.push_str(&"    rol\n");
                    then_node.cycles += 2;
                }
            } else if then_node.checkdepth > else_node.checkdepth {
                // else block needs to advance
                for _ in else_node.checkdepth..then_node.checkdepth {
                    self.push_eval(EvalStep::Literal(format!("    rol")));
                    else_node.cycles += 2;
                }
            }

            // Balance out cycles
            let mut then_sleep = 0;
            let mut else_sleep = 0;
            if else_node.cycles > then_node.cycles {
                // then block needs to advance
                then_sleep = else_node.cycles - then_node.cycles;
            } else if then_node.cycles > else_node.cycles {
                // else block needs to advance
                else_sleep = then_node.cycles - else_node.cycles;
            }

            // Balance sleeps so we don't sleep 1.
            // TODO: We can use other EvalStep data to wait the extra cycle.
            if then_sleep == 1 || else_sleep == 1 {
                else_sleep += 2;
                then_sleep += 2;
            }

            // Write out sleeps.
            if then_sleep > 0 {
                then_node.cycles += then_sleep;
                if_token_replacement.push_str(&format!("    sleep {}\n", then_sleep));
            }
            if else_sleep > 0 {
                else_node.cycles += else_sleep;
                self.push_eval(EvalStep::Literal(format!("    sleep {}", else_sleep)));
            }

            // Replace token
            writeln!(&mut if_token_replacement, "    ; then: {:?}", then_node);
            assert!(self.eval_replace(&EvalStep::Token(index), EvalStep::Literal(if_token_replacement)), "expected token replacement");
            self.push_eval(EvalStep::Literal(format!("    ; else: {:?}", else_node)));
            self.push_eval(EvalStep::Literal(format!(".endif_{}:", index)));
        }

        parent_node.index = else_node.index;
        parent_node.checkdepth = std::cmp::max(then_node.checkdepth, else_node.checkdepth);
        parent_node.cycles = std::cmp::max(then_node.cycles, else_node.cycles);
    }

    fn write(&mut self, parent_node: &mut Self::TNode, label: &str, values: &[String]) {
        // EVAL
        for (i, value) in values.iter().enumerate() {
            self.push_eval(EvalStep::LoadImm(value.to_string()));
            parent_node.cycles += 2;
            self.push_eval(EvalStep::Literal(format!("    stx [{} + {}]", label, i)));
            parent_node.cycles += if IS_ZERO_PAGE { 3 } else { 4 };
        }
    }

    fn write_zero_page(&mut self, parent_node: &mut Self::TNode, label: &str, values: &[String]) {
        // EVAL
        for (i, value) in values.iter().enumerate() {
            assert!(self.has_var(&value), "Did not find var definition: {}", value);

            self.push_eval(EvalStep::LoadZero(value.to_string()));
            parent_node.cycles += 4;
            self.push_eval(EvalStep::Literal(format!("    stx [{} + {}]", label, i)));
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

fn walk_kernel(lines: &[Parse]) -> Result<KernelBuild, Box<dyn Error>> {
    let mut code = KernelBuild::new("null");
    let mut code_queue = VecDeque::new();
    for line in lines {
        match line {
            Parse::NibbleStartKernel(name, cycles) => {
                // Push new node.
                code.name = name.to_owned();
                code_queue.push_front(code.start(&name, *cycles as usize));
            }
            Parse::NibbleVar(label) => {
                code.define_var(&label);
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
            Parse::NibbleWriteZeroPage(label, values) => {
                // Write to node.
                let mut parent_node = code_queue.pop_front().unwrap();
                code.write_zero_page(&mut parent_node, &label, &values);
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

    // for (key, value) in &code.vars {
    //     assert!(*value > 0, "Expected use of {:?} but did not find it.", key);
    // }

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
    let re_nibble_var = Regex::new(r"^NIBBLE_VAR\s+([^,]+)\s*")?;
    let re_nibble_write_imm = Regex::new(r"^NIBBLE_WRITE_IMM\s+([^,]+)(?:\s*,\s*([^,]+))+")?;
    let re_nibble_write_var = Regex::new(r"^NIBBLE_WRITE_VAR\s+([^,]+)(?:\s*,\s*([^,]+))+")?;
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
        } else if let Some(m) = re_nibble_var.captures(&line) {
            Parse::NibbleVar(m[1].to_string())
        } else if let Some(m) = re_nibble_write_imm.captures(&line) {
            // eprintln!("line {:?}", line);
            let selection = re_nibble_write_args
                .captures_iter(&line)
                .map(|n| n[1].to_string())
                .collect::<Vec<_>>();
            // eprintln!("selection {:?}", selection);
            Parse::NibbleWrite(m[1].to_string(), selection)
        } else if let Some(m) = re_nibble_write_var.captures(&line) {
            let selection = re_nibble_write_args
                .captures_iter(&line)
                .map(|n| n[1].to_string())
                .collect::<Vec<_>>();
            Parse::NibbleWriteZeroPage(m[1].to_string(), selection)
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
    for lines in &kernels {
        let kernel = walk_kernel(&lines)?;
        let build = kernel.build.to_owned();
        let eval = kernel.eval_output();

        std::fs::write(&format!("../src/__generated__/nibble_build_{}.s", kernel.name), &build)?;
        std::fs::write(&format!("../src/__generated__/nibble_eval_{}.s", kernel.name), &eval)?;
    }

    Ok(())
}
