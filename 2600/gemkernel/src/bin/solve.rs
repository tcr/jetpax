#![allow(non_camel_case_types, dead_code, unused_variables, non_snake_case)]

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
            Bytecode::Php10 => { score += 50; },
            Bytecode::Php11 => { score += 50; },
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

    let is_distinct_4 = distinct(&gems) >= 4;
    let is_distinct_4_exactly = distinct(&gems) == 4;
    let is_distinct_3 = distinct(&gems) >= 3;
    let is_distinct_3_exactly = distinct(&gems) == 3;
    // let is_distinct_3 =
    //     gems.iter().take(3).collect::<HashSet<_>>().len() == 3;

    // in Kernel A we can skip the first two elements.
    let leading_blank_pair = 
        gems[0] == Gem_0_0 && gems[1] == Gem_0_0;
    let trailing_blank_pair =
        gems[4] == Gem_0_0 && gems[5] == Gem_0_0;
    

/*

Middle VDel

if is_distinct_4_exactly && gems[1] == Gem_0_0 && gems[0] == gems[3] {

         [      Nop |   Reset4 |   VdelOn |  VdelOff |      Sty            ]
   gems: [  Gem_1_1 |  Gem_0_0 |  Gem_0_1 |  Gem_1_1 |  Gem_1_0 |  Gem_0_0 ]

         [      Nop |   Reset4 |   VdelOn |  VdelOff |      Stx            ]
   gems: [  Gem_1_1 |  Gem_0_0 |  Gem_1_0 |  Gem_1_1 |  Gem_0_1 |  Gem_1_1 ]

         [      Nop |   Reset4 |   VdelOn |  VdelOff |      Stx            ]
   gems: [  Gem_1_1 |  Gem_0_0 |  Gem_0_1 |  Gem_1_1 |  Gem_1_0 |  Gem_1_0 ]

         [      Nop |   Reset4 |   VdelOn |  VdelOff |      Stx            ]
   gems: [  Gem_1_1 |  Gem_0_0 |  Gem_0_1 |  Gem_1_1 |  Gem_1_0 |  Gem_0_1 ]

            } else if is_distinct_4_exactly && gems[1] == Gem_0_0 && gems[1] == gems[3] {


         [      Nop |      Stx |   VdelOn |  VdelOff |      Sty            ]
   gems: [  Gem_0_0 |  Gem_1_1 |  Gem_1_0 |  Gem_1_1 |  Gem_0_1 |  Gem_1_1 ]

         [      Nop |      Stx |   VdelOn |  VdelOff |      Sty            ]
   gems: [  Gem_0_0 |  Gem_1_1 |  Gem_0_1 |  Gem_1_1 |  Gem_1_0 |  Gem_0_0 ]

         [      Nop |      Sty |   VdelOn |  VdelOff |      Stx            ]
   gems: [  Gem_0_0 |  Gem_1_1 |  Gem_1_0 |  Gem_1_1 |  Gem_0_1 |  Gem_0_0 ]

         [      Nop |      Stx |   VdelOn |  VdelOff |      Sty            ]
   gems: [  Gem_1_0 |  Gem_1_1 |  Gem_0_1 |  Gem_1_1 |  Gem_1_0 |  Gem_0_0 ]

*/

/*

7  bit  0
---- ----
NVss DIZC
|||| ||||
|||| |||+- Carry
|||| ||+-- Zero
|||| |+--- Interrupt Disable
|||| +---- Decimal
||++------ No CPU effect, see: the B flag
|+-------- Overflow
+--------- Negative

*/

    // 6502 "Nibble VM"
    // Microcode for doing "decompression" operations.

    // Solve for variables.

    let mut state = if !is_distinct_3 {
        // B default

        let x = solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ]);

        let y = solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ]);

        let in_vdel = false;
        let vdel_value = Gem_0_0;
        let grp0 = gems[0];

        State {
            x,
            y,
            vdel_value,
            in_vdel,
            grp0,
            in_blank: false,
            reflected: false,
        }
    } else if kernel == Kernel::A {
        let x = solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ]);
        
        let y = solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ]);

        // Start in vdel only for these cases:
        let in_vdel = if
            gems[1] != Gem_0_0 &&
            // gems[1] != gems[0] &&
            // gems[1] != gems[2] &&
            gems[1] != gems[3] &&
            gems[1] != gems[4] {
            true
        } else if {
            gems[0..2] == [Gem_0_0, Gem_0_1] ||
            gems[0..2] == [Gem_0_0, Gem_1_0] ||
            gems[0..2] == [Gem_1_1, Gem_0_1] ||
            gems[0..2] == [Gem_1_1, Gem_1_0]
            // gems[0..3] == [Gem_0_0, Gem_0_1, Gem_0_1] ||
            // gems[0..3] == [Gem_0_0, Gem_0_1, Gem_1_0] ||
            // gems[0..3] == [Gem_0_0, Gem_0_1, Gem_1_1] ||
            // gems[0..3] == [Gem_0_0, Gem_1_0, Gem_0_1] ||
            // gems[0..3] == [Gem_0_0, Gem_1_0, Gem_1_0] ||
            // gems[0..3] == [Gem_0_0, Gem_1_0, Gem_1_1] ||
            // gems[0..3] == [Gem_1_1, Gem_0_1, Gem_0_1] ||
            // gems[0..3] == [Gem_1_1, Gem_0_1, Gem_1_0] ||
            // gems[0..3] == [Gem_1_1, Gem_0_1, Gem_1_1] ||
            // gems[0..3] == [Gem_1_1, Gem_1_0, Gem_0_1] ||
            // gems[0..3] == [Gem_1_1, Gem_1_0, Gem_1_0] ||
            // gems[0..3] == [Gem_1_1, Gem_1_0, Gem_1_1]
        } {
            true
        } else {
            false
        };
            
        let vdel_value = if in_vdel {
            gems[0]
        } else {
            // Possible middle VDEL
            gems[2]
        };

        // (Solved!)
        let grp0 = if in_vdel {
            gems[1]
        } else if leading_blank_pair {
            gems[2]
        } else {
            gems[0]
        };

        State {
            x,
            y,
            vdel_value,
            in_vdel,
            grp0,
            in_blank: false,
            reflected: false,
        }
    } else /*if kernel == Kernel::B*/ {
        let x = solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ]);
        
        let y = solve(&hashmap![
            Gem_0_0 => 1,
            Gem_0_1 => 1,
            Gem_1_0 => 1,
            Gem_1_1 => 1,
        ]);

        let in_vdel = true;
        let vdel_value = gems[0];
        let grp0 = gems[1];

        State {
            x,
            y,
            vdel_value,
            in_vdel,
            grp0,
            in_blank: false,
            reflected: false,
        }
    };

    // Start state assembly.

    let init_state = state.clone();

    let vdel_stands_valiantly_alone = init_state.x != init_state.vdel_value && init_state.y != init_state.vdel_value;
    
    // We only track the middle four nodes, cause like NOP is "free"
    let mut program = vec![];
    let mut i = 0;
    let mut did_php = false;
    while i < gems.len() - 1 { // One from end

        // [1_0, 0_1] or [0_1, 1_0] found as sequence, which
        // prompts the reset call immediately.
        let reflected_sequence = i > 0 && (
            gems[i] == Gem_0_1 && gems[i - 1] == Gem_1_0 ||
            gems[i] == Gem_1_0 && gems[i - 1] == Gem_0_1
        );

        let bc = if kernel == Kernel::A {
            match i {
                // 1bit kill? else?

                // Kill first 2 sprites if gems[0] == gems[1] == Gem_0_0
                | 0 if leading_blank_pair => {
                    Bytecode::Reset4
                }
                | 1 if leading_blank_pair => {
                    Bytecode::Reset4
                }

                // Leading nop
                0 => {
                    Bytecode::Nop
                }

                // 1bit kill? else?

                // If in vdel, immediately disable it.
                | 1 if init_state.in_vdel => {
                    Bytecode::VdelOff
                }

                // Skip sprites 1, 2, or 3.
                1 if gems[i] == Gem_0_0 => {
                    Bytecode::Reset4
                }
                2 if gems[i] == Gem_0_0 => {
                    Bytecode::Reset4
                }
                3 if gems[i] == Gem_0_0 => {
                    Bytecode::Reset4
                }

                // // TODO i don't know how to actually do this:
                // 4 if gems[i] == Gem_0_0 => {
                //     // Skip with value
                //     Bytecode::Reset4
                // }

                // Kill last 2 sprites if dead
                | 4
                | 5 if trailing_blank_pair => {
                    Bytecode::Reset4
                }

                // Reflect around a blank gem[1] or gem[3].
                | 2 if
                    gems[0..3] == [Gem_1_0, Gem_0_0, Gem_0_1] ||
                    gems[0..3] == [Gem_0_1, Gem_0_0, Gem_1_0] => {
                    Bytecode::Reflect
                }
                | 4 if
                    gems[3..5] == [Gem_1_0, Gem_0_0, Gem_0_1] ||
                    gems[3..5] == [Gem_0_1, Gem_0_0, Gem_1_0] => {
                    Bytecode::Reflect
                }

                // Middle VDelOn/Off Pair
                | 2 if {
                    i == 2 &&
                    is_distinct_3 &&
                    gems[3] == Gem_1_1 &&
                    state.current() == Gem_1_1
                } => {
                    Bytecode::VdelOn
                }

                3 if state.in_vdel => {
                    Bytecode::VdelOff
                }

                _ if reflected_sequence => {
                    Bytecode::Reflect
                }

                // Normal execution.
                _ => {
                    solve(&hashmap!{
                        Bytecode::Nop => 1,
                        Bytecode::Stx => 1,
                        Bytecode::Sty => 1,
                    })
                }
            }
        } else {
            match i {
                // Force first command.
                0 => Bytecode::Nop,

                // Disable vdel immediately if on.
                1 if init_state.in_vdel => {
                    Bytecode::VdelOff
                },

                // Use of Php opcode.
                | 2 | 3 | 4 
                if !did_php && init_state.in_vdel && gems[i] == Gem_1_0 => {
                    did_php = true;
                    Bytecode::Php10
                }
                | 2 | 3 | 4 
                if !did_php && init_state.in_vdel && gems[i] == Gem_1_1 => {
                    did_php = true;
                    Bytecode::Php11
                }

                _ => {
                    solve(&hashmap!{
                        Bytecode::Nop => 1,
                        Bytecode::Stx => 1,
                        Bytecode::Sty => 1,
                    })
                }
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
    if program.iter().filter(|x| **x == Bytecode::Php10 || **x == Bytecode::Php11).count() > 1 {
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
