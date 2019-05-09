use regex::Regex;
use std::error::Error;
use std::collections::VecDeque;
use std::fmt::Write;

#[derive(Debug, Clone)]
enum Parse {
    NibbleStartKernel(String, isize),
    NibbleIf(String),
    NibbleElse,
    NibbleEndIf,
    NibbleEndKernel,
    NibbleWrite(String, Vec<String>),
    NibbleWriteOpcode(String, isize, String),
    Opcode(String),
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

fn main() -> Result<(), Box<dyn Error>> {
    let re_nibble_start_kernel = Regex::new(r"^NIBBLE_START_KERNEL\s+(\S.*)\s*,\s*(\S.*)\s*")?;
    let re_nibble_if = Regex::new(r"^NIBBLE_IF\s+(.+)\s*")?;
    let re_nibble_else = Regex::new(r"^NIBBLE_ELSE")?;
    let re_nibble_end_if = Regex::new(r"^NIBBLE_END_IF")?;
    let re_nibble_write = Regex::new(r"^NIBBLE_WRITE\s+([^,]+)(?:\s*,\s*([^,]+))+")?;
    let re_nibble_write_args = Regex::new(r",\s*([^,]+)")?;
    let re_nibble_write_opcode = Regex::new(r"^NIBBLE_WRITE_OPCODE\s+(\S.*),\s*(\S.*)\s*,\s*(\S.*)\s*")?;
    let re_nibble_end_kernel = Regex::new(r"^NIBBLE_END_KERNEL")?;
    
    let re_data = Regex::new(r"^\s*(.+?)\s*(;.*)?$")?;

    let input_file = std::fs::read_to_string("../src/game_frame.s")?;

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
            eprintln!("line {:?}", line);
            let selection = re_nibble_write_args.captures_iter(&line).map(|n| {
                eprintln!("{:?}", n);
                n
            }).map(|n| n[1].to_string()).collect::<Vec<_>>();
            eprintln!("selection {:?}", selection);
            Parse::NibbleWrite(m[1].to_string(), selection)
        } else if let Some(m) = re_nibble_write_opcode.captures(&line) {
            Parse::NibbleWriteOpcode(m[1].to_string(), m[2].parse()?, m[2].to_string())
        } else if let Some(_) = re_nibble_end_kernel.captures(&line) {
            Parse::NibbleEndKernel
        } else {
            Parse::Opcode(line.to_string())
        };
        lines.push(parsed);

        if let Some(_) = re_nibble_end_kernel.captures(&line) {
            break;
        }
    }

    let mut kernel_name = "".to_string();
    let mut opcode_count = 0;
    
    let mut kernel_data = String::new();
    let mut kernel_code = String::new();
    let mut if_counter = 0;
    let mut if_depth = VecDeque::new();
    for line in &lines {
        match line {
            Parse::NibbleStartKernel(name, cycles) => {
                // Pass in conditionals in A
                kernel_name = name.to_string();
                writeln!(&mut kernel_code, "    MAC NIBBLE_{}", name)?;
            }
            Parse::NibbleIf(cond) => {
                if_counter += 1;
                if_depth.push_front(IfDepth {
                    cond: cond.to_string(),
                    number: if_counter,
                });
                let current_if = if_depth.front().unwrap();
                writeln!(&mut kernel_code, ".if_{}:", current_if.number)?;
                writeln!(&mut kernel_code, "    asl")?;
                writeln!(&mut kernel_code, "    bcc .else_{}", current_if.number)?;
            }
            Parse::NibbleElse => {
                let current_if = if_depth.front().unwrap();
                writeln!(&mut kernel_code, "    jmp .endif_{}", current_if.number)?;
                writeln!(&mut kernel_code, ".else_{}:", current_if.number)?;
            }
            Parse::NibbleEndIf => {
                let current_if = if_depth.front().unwrap();
                writeln!(&mut kernel_code, ".endif_{}:", current_if.number)?;
                if_depth.pop_front();
            }
            Parse::NibbleEndKernel => {}
            Parse::NibbleWrite(label, values) => {
                for (i, value) in values.iter().enumerate() {
                    writeln!(&mut kernel_code, "    ldx {}", value)?;
                    writeln!(&mut kernel_code, "    stx [{} + {}]", label, i)?;
                }
            }
            Parse::NibbleWriteOpcode(label, len, value) => {
                opcode_count += 1;
                writeln!(&mut kernel_data, "NIBBLE_{}_OPCODE_{}:", kernel_name, opcode_count)?;
                writeln!(&mut kernel_data, "    {}", value)?;
                writeln!(&mut kernel_data, "    ASSERT_SIZE_EXACT NIBBLE_{}_OPCODE_{}, ., {}", kernel_name, opcode_count, len)?; // enforce
                for i in 0..*len {
                    writeln!(&mut kernel_code, "    ldx [NIBBLE_{}_OPCODE_{} + {}]", kernel_name, opcode_count, i)?;
                    writeln!(&mut kernel_code, "    stx [{} + {}]", label, i)?;
                }
            }
            Parse::Opcode(opcode) => {}
        }
    }
    writeln!(&mut kernel_code, "    ENDM")?;

    struct IfDepth {
        cond: String,
        number: usize,
    }

    let mut kernel_build = String::new();
    let mut build_if_counter = 0;
    let mut build_if_depth = VecDeque::new();
    for line in &lines {
        match line {
            Parse::NibbleStartKernel(name, cycles) => {
                // Pass in conditionals in A
                kernel_name = name.to_string();
                writeln!(&mut kernel_build, "    MAC NIBBLE_{}_BUILD", name)?;
                writeln!(&mut kernel_build, "    lda #0");
            }
            Parse::NibbleIf(cond) => {
                build_if_counter += 1;
                build_if_depth.push_front(IfDepth {
                    cond: cond.to_string(),
                    number: build_if_counter,
                });
                let current_if = build_if_depth.front().unwrap();
                writeln!(&mut kernel_build, ".if_{}:", current_if.number)?;
                writeln!(&mut kernel_build, "    b{} .else_{}", invert_cond(&cond), current_if.number)?;
                writeln!(&mut kernel_build, "    sec")?;
                writeln!(&mut kernel_build, "    rol")?;
            }
            Parse::NibbleElse => {
                let current_if = build_if_depth.front().unwrap();
                writeln!(&mut kernel_build, "    jmp .endif_{}", current_if.number)?;
                writeln!(&mut kernel_build, ".else_{}:", current_if.number)?;
                writeln!(&mut kernel_build, "    clc")?;
                writeln!(&mut kernel_build, "    rol")?;
            }
            Parse::NibbleEndIf => {
                let current_if = build_if_depth.front().unwrap();
                writeln!(&mut kernel_build, ".endif_{}:", current_if.number)?;
                build_if_depth.pop_front();
            }
            Parse::NibbleEndKernel => {}
            Parse::NibbleWrite(label, values) => {}
            Parse::NibbleWriteOpcode(label, len, value) => {},
            Parse::Opcode(opcode) => {
                writeln!(&mut kernel_build, "    {}", opcode)?;
            }
        }
    }
    writeln!(&mut kernel_build, "    ENDM")?;

    println!("{}", kernel_data);
    println!("{}", kernel_build);
    println!("{}", kernel_code);

    Ok(())
}
