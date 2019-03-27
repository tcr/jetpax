// cargo-deps: rand="*", itertools = "*", rayon = "*"

extern crate rand;
#[macro_use] extern crate itertools;
extern crate rayon;

use rand::Rng;
use std::thread;
use itertools::Itertools;
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
    // Php,
    Reflect,
    Reset4,
}

use self::Bytecode::*;

fn random_bc() -> Bytecode {
    let out_of = vec![
        Nop,
        VdelOn,
        VdelOff,
        BlankOn,
        BlankOff,
        Stx,
        Sty,
        Reflect,
        // Php,
        // Reset4,
    ];
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
            Nop => {},
            VdelOn => {
                if state.in_vdel {
                    return None;
                }
                state.in_vdel = true;
            }
            VdelOff => {
                if !state.in_vdel {
                    return None;
                }
                state.in_vdel = false;
            }
            BlankOn => {
                if state.in_blank {
                    return None;
                }
                state.in_blank = true;
            }
            BlankOff => {
                if !state.in_blank {
                    return None;
                }
                state.in_blank = false;
            }
            Stx => {
                state.grp0 = state.x;
            }
            Sty => {
                state.grp0 = state.y;
            }
            Reflect => {
                state.reflected = !state.reflected;
            }
            // Php => {
            //     state.grp0 = Gem_1_0;
            // }
            Reset4 => {
                panic!("unreachable");
            }
        }
        Some(state)
    }
}

fn main() {
    // GEM list is six pairs wide.
    let gems: Vec<_> = (0..6).map(|_| random_gem()).collect();

    // To iterate over a specific condition.
    let i = [
        (&Gem_0_1, &Gem_0_1, &Gem_0_0, &Gem_1_0, &Gem_1_1, &Gem_0_0)
    ];

    let all_gems = vec![Gem_0_0, Gem_0_1, Gem_1_0, Gem_1_1];
    // let i = iproduct!(&all_gems, &all_gems, &all_gems, &all_gems, &all_gems, &all_gems);
    for gt in &i {
        println!("solving: {:?}", gt);

        // Make a vector to hold the children which are spawned.
        let results: Vec<Vec<Bytecode>> = (0..512)
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

        println!("program: {:?}", program[0]);
        println!();
    }
}

fn ranking(program: &[Bytecode]) -> isize {
    let mut score = 100;
    for bc in program {
        match bc {
            Nop => { score -= 10 },
            VdelOn => { score += 5; },
            VdelOff => { score += 2; },
            BlankOn => { score += 5; },
            BlankOff => { score += 5; },
            Php => { score += 50; },
            Reflect => { score += 2; },
            Stx | Sty => {}
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
    // println!("gems {:?}", gems);
    // println!("state: {:?}", state);

    let mut program = vec![Nop];
    let mut retry = 4;
    let mut i = 1;
    while i < gems.len() - 1 {
        if i == 3 && gems[i] == Gem_0_0 {
            program.push(Reset4);
        // } else if i == 2 && gems[i] == Gem_0_0 {
        //     program.push(Reset4);
        } else {

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
        }
        i += 1;
    }

    // println!("program {:?}", program);
    if state.in_vdel {
        // Imbalenced vdel
        // println!("imbalanced vdel");
        return None;
    }

    Some(program)
}
