// cargo-deps: rand="*", itertools = "*", rayon = "*"

#[allow(non_camel_case_types)]

extern crate rand;
#[macro_use] extern crate itertools;
extern crate rayon;

use rand::Rng;
use std::thread;
use rayon::prelude::*;

#[derive(Debug, Copy, Clone, PartialEq)]
enum Gem {
    Gem_0_0,
    Gem_0_1,
    Gem_1_0,
    Gem_1_1,
}

use self::Gem::*;

// const KERNEL: &'static str = "A";
const KERNEL: &'static str = "B";

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

fn random_bc() -> Bytecode {
    let mut out_of = vec![
        Bytecode::Nop,
        Bytecode::VdelOn,
        Bytecode::VdelOff,
        Bytecode::BlankOn,
        Bytecode::BlankOff,
        Bytecode::Stx,
        Bytecode::Sty,
    ];
    if KERNEL == "A" {
        out_of.push(Bytecode::Reflect);
    }
    if KERNEL == "B" {
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
                state.grp0 = Gem_1_0;
            }
            Bytecode::Reset4 => {
                panic!("unreachable");
            }
        }
        Some(state)
    }
}

const GLOBAL_THREADS: usize = 128;

fn main() {
    // GEM list is six pairs wide.
    let gems: Vec<_> = (0..6).map(|_| random_gem()).collect();

    // Uncomment to iterate over a specific condition.
    // let i = [
    //     (&Gem_0_1, &Gem_0_1, &Gem_0_0, &Gem_1_0, &Gem_1_1, &Gem_0_0)
    // ];

    let all_gems = vec![Gem_0_0, Gem_0_1, Gem_1_0, Gem_1_1];
    let i = iproduct!(&all_gems, &all_gems, &all_gems, &all_gems, &all_gems, &all_gems);
    for gt in i {
        println!("solving: {:?}", gt);

        // Make a vector to hold the children which are spawned.
        let results: Vec<Vec<Bytecode>> = (0..GLOBAL_THREADS)
            .into_iter()
            .collect::<Vec<usize>>()
            .par_iter()
            .map(|_| {
                let gems = vec![*gt.0, *gt.1, *gt.2, *gt.3, *gt.4, *gt.5];
                // Spin up another thread
                loop {
                    if let Some(result) = attempt(&gems) {
                        return result;
                    }
                }
            })
            .collect();
        
        let mut program = results
            .into_iter()
            .map(|result| {
                // generate score
                let score = ranking(&result);
                (score, result)
            })
            .collect::<Vec<_>>();
        
        program.sort_by(|a, b| a.0.cmp(&b.0));

        println!("\nprogram: {:?}", program[0]);
        println!();
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


fn attempt(gems: &[Gem]) -> Option<Vec<Bytecode>> {
    let mut state = State {
        x: random_gem(),
        y: random_gem(),
        in_vdel: rand::thread_rng().gen(),
        in_blank: rand::thread_rng().gen(),
        reflected: rand::thread_rng().gen(),
        vdel_value: random_gem(),
        grp0: gems[0],
    };
    let mut final_state = state.clone();
    // println!("gems {:?}", gems);
    // println!("state: {:?}", state);

    // We only track the middle four nodes, cause like NOP is "free"
    let mut program = vec![Bytecode::Nop];
    let mut retry = 4;
    let mut i = 1;
    while i < gems.len() - 1 {
        if KERNEL == "A" {
            if i == 3 && gems[i] == Gem_0_0 {
                program.push(Bytecode::Reset4);
                i += 1;
                continue;
            } else if i == 2 && gems[i] == Gem_0_0 {
                // This is a Reset2.
                program.push(Bytecode::Reset4);
                i += 1;
                continue;
            }
        }

        let bc = random_bc();
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

    // println!("program {:?}", program);
    print!(".");
    // if state.in_vdel {
    //     // Imbalenced vdel
    //     println!("imbalanced vdel");
    //     return None;
    // }

    Some(program)
}
