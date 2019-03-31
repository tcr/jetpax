use gemkernel::*;
use maplit::*;
use rand::Rng;
use rayon::prelude::*;
use std::collections::{HashMap, HashSet};
use std::fs::File;
use std::io::prelude::*;
use serde_json;
use serde::{Serialize, Deserialize};

const SOLVE_THREADS: usize = 1;

fn random_gem() -> Gem {
    match rand::thread_rng().gen_range(0, 4) {
        1 => Gem_0_1,
        2 => Gem_1_0,
        3 => Gem_1_1,
        0 | _ => Gem_0_0,
    }
}

fn random_entry<T>(entries: &[T]) -> T where T: Copy {
    let idx = rand::thread_rng().gen_range(0, entries.len());
    entries[idx]
}

fn random_bc(kernel: Kernel) -> Bytecode {
    let mut out_of = vec![
        Bytecode::Nop,
        Bytecode::VdelOn, // D0=1
        Bytecode::VdelOff, // D0=0
        Bytecode::BlankOn, // How?
        Bytecode::BlankOff, // How?
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
            Bytecode::BlankOff => { score += 5; },
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
    let x = random_gem();

    // Contained Y values.
    let y = random_gem();
    // let y = {
    //     let mut values = hashset![];
    //     for (i, gem) in gems.iter().enumerate() {
    //         match gem {
    //             // Gem_0_0 => { values.insert(Gem_0_0); }
    //             Gem_0_1 => { values.insert(Gem_0_1); }
    //             Gem_1_0 => { values.insert(Gem_1_0); }
    //             Gem_1_1 => if i == 3 || i == 4 {
    //                 values.insert(Gem_1_1);
    //             },
    //             _ => {}
    //         }
    //     }
    //     let gems = values.into_iter().sorted().collect::<Vec<Gem>>();
    //     if gems.is_empty() { Gem_1_1 } else { random_entry(&gems) }
    // };

    let in_vdel = rand::thread_rng().gen();

    let vdel_value = random_gem();

    let grp0 = random_gem();

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
    let mut retry = 4;
    let mut i = 0;
    while i < gems.len() - 1 { // One from end
        // if i == 4 && gems[i] == Gem_0_0 && gems[i + 1] == Gem_0_0 {
        // program.push(Bytecode::Reset4);
        // i += 1;
        // continue;
        // }
        // if i == 5 && gems[i] == Gem_0_0 && gems[i - 1] == Gem_0_0 {
        // program.push(Bytecode::Reset4);
        // i += 1;
        // continue;
        // }

        if kernel == Kernel::A {
            if i == 3 && gems[i] == Gem_0_0 {
                program.push(Bytecode::Reset4);
                i += 1;
                continue;
            }
            if i == 1 && gems[i] == Gem_0_0 {
                program.push(Bytecode::Reset4);
                i += 1;
                continue;
            }
            if i == 2 && gems[i] == Gem_0_0 {
                // This is a Reset2.
                program.push(Bytecode::Reset4);
                i += 1;
                continue;
            }
        }

        let bc = {
            if i == 0 {
                Bytecode::Nop
            } else {
                random_bc(kernel)
            }
        };
        // if bc == Bytecode::Php && !(i == 4 || i == 3 || i == 2) {
        //     continue;
        // }

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
    let mut count_php = 0;
    for bc in &program {
        match bc {
            Bytecode::Php => {
                count_php += 1;
            }
            _ => {},
        }
    }
    if count_php > 1 {
        return None;
    }

    // println!("program {:?}", program);

    // Check for imbalanced vdel.
    if state.in_vdel {
        // println!("imbalanced vdel");
        return None;
    }
    print!(". ");

    Some((program, init_state, state))
}
