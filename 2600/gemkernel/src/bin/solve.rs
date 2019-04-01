#![allow(non_camel_case_types, dead_code, unused_variables)]

use gemkernel::*;
use maplit::*;
use rand::Rng;
use rayon::prelude::*;
use std::fs::File;
use std::io::prelude::*;
use std::collections::{HashMap, HashSet};
use serde_json;
use serde::{Serialize, Deserialize};
use std::hash::Hash;

const SOLVE_THREADS: usize = 1;

fn random_gem() -> Gem {
    random_entry(&[Gem_0_0, Gem_0_1, Gem_1_0, Gem_1_1])
}

fn random_entry<T>(entries: &[T]) -> T where T: Copy {
    let idx = rand::thread_rng().gen_range(0, entries.len());
    entries[idx]
}

fn solve<K>(map: &HashMap<K, usize>) -> K where K: Copy + Eq + Hash {
    let mut entries: Vec<K> = vec![];
    for (k, v) in map {
        for _ in 0..*v {
            entries.push(*k);
        }
    }
    let idx = rand::thread_rng().gen_range(0, entries.len());
    entries[idx]
}

fn random_bc(kernel: Kernel) -> Bytecode {
    let mut out_of = vec![
        Bytecode::Nop,
        Bytecode::VdelOn, // D0=1
        Bytecode::VdelOff, // D0=0
        Bytecode::Stx,
        Bytecode::Sty,
    ];
    if kernel == Kernel::A {
        out_of.push(Bytecode::Reflect);
    }
    if kernel == Kernel::B {
        out_of.push(Bytecode::Php);
    }
    out_of[rand::thread_rng().gen_range(0, out_of.len())]
}

/// Generate A.txt and B.txt.
fn main() {
    for kernel in [Kernel::A, Kernel::B].into_iter() {
    // for kernel in [Kernel::A].into_iter() {
        let mut solved: Export = hashmap![];
        for gems in all_gem_rows() {
            println!("[{:?}] solving: {:?}", kernel, gems);

            // Make a vector to hold the children which are spawned.
            let results = (0..SOLVE_THREADS)
                .into_iter()
                .collect::<Vec<usize>>()
                .par_iter()
                .map(|_| {
                    // Spin up another thread
                    loop {
                        if let Some(result) = attempt(*kernel, &gems) {
                            return result;
                        }
                    }
                })
                .collect::<Vec<(Program, State, State)>>();
            
            // Rank results.
            let mut result_ranking = results
                .into_iter()
                .map(|(program, init_state, state)| {
                    // generate score
                    let score = ranking(&program, &init_state);
                    (score, (program, init_state, state))
                })
                .collect::<Vec<_>>();
            result_ranking.sort_by(|a, b| a.0.cmp(&b.0));

            let (score, (program, init_state, state)) = result_ranking[0].clone();

            println!("\n[{:?}] program: {:?} (score: {:?})", kernel, program, score);
            println!();

            solved.insert(gems, (program, init_state, state));
        }
        println!();

        let filename = format!("{:?}.txt", kernel);
        let mut file = File::create(&filename).unwrap();
        file.write_all(serde_json::to_string(
            &solved.clone().into_iter().collect::<ExportFormat>(),
        ).unwrap().as_bytes()).unwrap();
    }
}

fn ranking(program: &[Bytecode], init_state: &State) -> isize {
    let mut score = 100;
    for bc in program {
        match bc {
            Bytecode::Nop => { score -= 10 },
            Bytecode::VdelOn => { score += 5; },
            Bytecode::VdelOff => { score += 2; },
            Bytecode::BlankOn => { score += 5; },
            Bytecode::Reset4 => { score += 30; },
            Bytecode::Reflect => { score += 20; },
            Bytecode::Php => { score += 50; },
            Bytecode::Stx | Bytecode::Sty => {}
        }
    }

    if init_state.in_vdel {
        score += 50;
    }

    score
}

// Gradually remove the randomness from these features
fn attempt(kernel: Kernel, gems: &[Gem]) -> Option<(Vec<Bytecode>, State, State)> {
    let mut retry = 4; // const

    let x = {
        solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ])
    };

    let y = {
        solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ])
    };

    let is_distinct_4 =
        gems.iter().take(4).collect::<HashSet<_>>().len() == 4;
    let is_distinct_3 =
        gems.iter().take(3).collect::<HashSet<_>>().len() == 3;

    let in_vdel = {
        solve(&hashmap![
            true => 1,
            false => 10,
        ])
    };

    let vdel_value = {
        solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ])
    };

    let grp0 = if in_vdel {
        gems[1]
    } else {
        gems[0]
    };

    // Start state assembly.

    let mut state = State {
        x,
        y,
        vdel_value,
        in_vdel,
        grp0,
        in_blank: false,
        reflected: false,
    };
    let init_state = state.clone();
    
    // We only track the middle four nodes, cause like NOP is "free"
    let mut program = vec![];
    let mut i = 0;
    while i < gems.len() - 1 { // One from end

        let bc = if kernel == Kernel::A {
            match i {
                // Kill first 2 sprites if gems[0] == Gem_0_0 and gems[1] too
                | 0 if gems[0] == Gem_0_0 && gems[1] == Gem_0_0 => {
                    Bytecode::Reset4
                }
                | 1 if gems[0] == Gem_0_0 && gems[1] == Gem_0_0 => {
                    Bytecode::Reset4
                }
                | 1 if init_state.in_vdel => {
                    Bytecode::VdelOff
                }

                1 if gems[i] == Gem_0_0 => {
                    Bytecode::Reset4
                }
                2 if gems[i] == Gem_0_0 => {
                    Bytecode::Reset4
                }
                3 if gems[i] == Gem_0_0 => {
                    Bytecode::Reset4
                }

                // Kill last 2 sprites if gems[4] == Gem_0_0 but gems[3] doesn't
                4 if gems[i] == Gem_0_0 && gems[i-1] != Gem_0_0 => {
                    Bytecode::BlankOn
                }

                // Normal
                0 => {
                    Bytecode::Nop
                }
                _ => {
                    solve(&hashmap!{
                        Bytecode::Nop => 10,
                        Bytecode::Stx => 10,
                        Bytecode::Sty => 10,
                        Bytecode::Reflect => 1,
                        Bytecode::VdelOn => 1,
                        Bytecode::VdelOff => 1,
                    })
                }
            }
        } else {
            if i == 0 {
                // Force first command.
                Bytecode::Nop
            } else if i == 1 && init_state.in_vdel {
                Bytecode::VdelOff
            } else {
                solve(&hashmap!{
                    Bytecode::Nop => 3,
                    Bytecode::Stx => 3,
                    Bytecode::Sty => 3,
                    Bytecode::Php => 1,
                    // Bytecode::VdelOn => 1,
                    // Bytecode::VdelOff => 1,
                })
            }
        };

        // if kernel == Kernel::A && bc == Bytecode::VdelOff && i == 2 {
        //     if program[1] != Bytecode::VdelOn || program[0] != Bytecode::Reset4 {
        //         return None;
        //     }
        // }

        // Handle reset4 (skip1).
        if bc == Bytecode::Reset4 {
            program.push(bc);
        } else {
            let result = state.step(bc);
            // println!("exec {:?} \t\t{:?}", bc, gem);
            if let Some(new_state) = result {
                if gems[i] != new_state.current() {
                    // println!("wrong type");
                    retry -= 1;
                    if retry == 0 {
                        return None;
                    } else {
                        continue;
                    }
                }

                state = new_state;
                program.push(bc);
            } else {
                continue;
            }
        }

        i += 1;
    }

    // Nullify test.
    // for bc in &program {
    //     match bc {
    //         Result4 => {
    //             continue;
    //         }
    //         _ => {},
    //     }
    //     let result = final_state.process(*bc);
    //     if let Some(new_state) = result {
    //         final_state = new_state;
    //         // if gems[i] != new_state.current() {
    //     } else {
    //         return None;
    //     }
    // }

    // Only one PHP.
    if program.iter().filter(|x| **x == Bytecode::Php).count() > 1 {
        return None;
    }

    // println!("program {:?}", program);

    // Check for imbalanced vdel.
    if state.in_vdel && state.vdel_value != gems[5] {
        // println!("imbalanced vdel");
        return None;
    }
    print!(".");

    Some((program, init_state, state))
}
