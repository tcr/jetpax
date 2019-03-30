// TODO The Reset3 functionality in kernel A (only for kernel A!) is by missing
// the prior RESP0 call, calling RESP0 on the GEM_09 write. This will bump the
// spries over by one column, unfortunately, so a trick of: only writing the 
// high bit (as the low bit) and ussing the right missile starting earlier to
// get the sprites working. it's tricky but i'm done with it lol

#![allow(non_camel_case_types)]

extern crate rand;
#[macro_use] extern crate itertools;
extern crate rayon;

use rand::Rng;
use rayon::prelude::*;

#[derive(Debug, Copy, Clone, PartialEq)]
enum Gem {
    Gem_0_0,
    Gem_0_1,
    Gem_1_0,
    Gem_1_1,
}

use self::Gem::*;

fn random_gem() -> Gem {
    match rand::thread_rng().gen_range(0, 4) {
        1 => Gem_0_1,
        2 => Gem_1_0,
        3 => Gem_1_1,
        0 | _ => Gem_0_0,
    }
}

#[derive(Debug, Copy, Clone, PartialEq)]
enum Bytecode {
    Nop,
    VdelOn,
    VdelOff,
    BlankOn,
    BlankOff,
    Stx,
    Sty,
    Php,
    Reflect,
    Reset4,
}

fn random_bc(kernel: &str) -> Bytecode {
    let mut out_of = vec![
        Bytecode::Nop,
        Bytecode::VdelOn, // How?
        Bytecode::VdelOff, // How?
        Bytecode::BlankOn, // How?
        Bytecode::BlankOff, // How?
        Bytecode::Stx,
        Bytecode::Sty,
    ];
    if kernel == "A" {
        out_of.push(Bytecode::Reflect);
    }
    if kernel == "B" {
        out_of.push(Bytecode::Php);
    }
    out_of[rand::thread_rng().gen_range(0, out_of.len())]
}

#[derive(Debug, Copy, Clone)]
struct State {
    x: Gem,
    y: Gem,
    in_vdel: bool,
    in_blank: bool,
    vdel_value: Gem,
    reflected: bool,
    grp0: Gem,
}

impl State {
    fn current(&self) -> Gem {
        let mut grp0 = if self.in_vdel { self.vdel_value } else { self.grp0 };
        if self.reflected {
            grp0 = match grp0 {
                Gem_0_1 => Gem_1_0,
                Gem_1_0 => Gem_0_1,
                _ => grp0,
            };
        }
        if self.in_blank {
            grp0 = Gem_0_0;
        }
        grp0
    }

    fn process(&self, bc: Bytecode) -> Option<State> {
        let mut state = self.clone();

        match bc {
            Bytecode::Nop => {},
            Bytecode::VdelOn => {
                if state.in_vdel {
                    return None;
                }
                state.in_vdel = true;
            }
            Bytecode::VdelOff => {
                if !state.in_vdel {
                    return None;
                }
                state.in_vdel = false;
            }
            Bytecode::BlankOn => {
                if state.in_blank {
                    return None;
                }
                state.in_blank = true;
            }
            Bytecode::BlankOff => {
                if !state.in_blank {
                    return None;
                }
                state.in_blank = false;
            }
            Bytecode::Stx => {
                state.grp0 = state.x;
            }
            Bytecode::Sty => {
                state.grp0 = state.y;
            }
            Bytecode::Reflect => {
                state.reflected = !state.reflected;
            }
            Bytecode::Php => {
                state.grp0 = if rand::thread_rng().gen::<bool>() { Gem_1_0 } else { Gem_1_1 };
            }
            Bytecode::Reset4 => {
                panic!("unreachable");
            }
        }
        Some(state)
    }
}

const GLOBAL_THREADS: usize = 1;

fn main() {
    let all_gems = vec![Gem_0_0, Gem_0_1, Gem_1_0, Gem_1_1];

    for kernel in &["A", "B"] {
        // Uncomment to iterate over a specific condition.
        // let i = [
        //     (&Gem_0_1, &Gem_0_1, &Gem_0_0, &Gem_1_0, &Gem_1_1, &Gem_0_0)
        // ];

        let i = iproduct!(&all_gems, &all_gems, &all_gems, &all_gems, &all_gems, &all_gems);
        for gt in i {
            println!("[{}] solving: {:?}", kernel, gt);

            // Make a vector to hold the children which are spawned.
            let results = (0..GLOBAL_THREADS)
                .into_iter()
                .collect::<Vec<usize>>()
                .par_iter()
                .map(|_| {
                    let gems = vec![*gt.0, *gt.1, *gt.2, *gt.3, *gt.4, *gt.5];
                    // Spin up another thread
                    loop {
                        if let Some(result) = attempt(kernel, &gems) {
                            return result;
                        }
                    }
                })
                .collect::<Vec<Vec<Bytecode>>>();
            
            let mut result_ranking = results
                .into_iter()
                .map(|program| {
                    // generate score
                    let score = ranking(&program);
                    (score, program)
                })
                .collect::<Vec<_>>();
            
            result_ranking.sort_by(|a, b| a.0.cmp(&b.0));

            let program = result_ranking[0].clone();

            println!("\n[{}] program: {:?}", kernel, program);
            println!();
        }
    }
}

fn ranking(program: &[Bytecode]) -> isize {
    let mut score = 100;
    for bc in program {
        match bc {
            Bytecode::Nop => { score -= 10 },
            Bytecode::VdelOn => { score += 5; },
            Bytecode::VdelOff => { score += 2; },
            Bytecode::BlankOn => { score += 5; },
            Bytecode::BlankOff => { score += 5; },
            Bytecode::Reset4 => { score += 50; },
            Bytecode::Reflect => { score += 20; },
            Bytecode::Php => { score += 50; },
            Bytecode::Stx | Bytecode::Sty => {}
        }
    }
    score
}


// Gradually remove the randomness from these features
fn attempt(kernel: &str, gems: &[Gem]) -> Option<Vec<Bytecode>> {
    let mut state = State {
        x: random_gem(),
        y: random_gem(),
        vdel_value: random_gem(),
        in_vdel: rand::thread_rng().gen(),
        grp0: random_gem(),
        in_blank: false,
        reflected: false,
    };
    
    // We only track the middle four nodes, cause like NOP is "free"
    let mut program = vec![Bytecode::Nop];
    let mut retry = 4;
    let mut i = 0;
    while i < gems.len() - 1 { // One from end
        if kernel == "A" {
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

        let bc = if i == 0 { Bytecode::Nop } else { random_bc(kernel) };
        let result = state.process(bc);
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
    print!(". ");

    // TODO this is required
    if state.in_vdel {
        // Imbalenced vdel
        println!("imbalanced vdel");
        return None;
    }

    Some(program)
}
