// TODO The Reset3 functionality in kernel A (only for kernel A!) is by missing
// the prior RESP0 call, calling RESP0 on the GEM_09 write. This will bump the
// spries over by one column, unfortunately, so a trick of: only writing the 
// high bit (as the low bit) and ussing the right missile starting earlier to
// get the sprites working. it's tricky but i'm done with it lol

#![allow(non_camel_case_types, dead_code, unused_variables)]

use maplit::*;
use itertools::*;
use rand::Rng;
use rayon::prelude::*;
use std::collections::{HashMap, HashSet};
use std::fs::File;
use std::io::prelude::*;
use serde_json;
use serde::{Serialize, Deserialize};

const SOLVE_THREADS: usize = 1;

fn main() {
    if false {
        main_generate_tables();
    } else {
        main_process_features();
    }
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, PartialOrd, Ord)]
enum Gem {
    Gem_0_0,
    Gem_0_1,
    Gem_1_0,
    Gem_1_1,
}

use self::Gem::*;

#[derive(Debug, Copy, Clone, PartialEq, Eq, Serialize, Deserialize)]
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

#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
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

type GemRow = [Gem; 6];

fn gem_permutations() -> Vec<GemRow> {
    // Hardcoded.
    // return vec![
    //     [Gem_0_1, Gem_0_1, Gem_0_0, Gem_1_0, Gem_1_1, Gem_0_0]
    // ];

    let all_gems = vec![Gem_0_0, Gem_0_1, Gem_1_0, Gem_1_1];
    iproduct!(&all_gems, &all_gems, &all_gems, &all_gems, &all_gems, &all_gems)
        .into_iter()
        .map(|(gem0, gem1, gem2, gem3, gem4, gem5)| {
            [*gem0, *gem1, *gem2, *gem3, *gem4, *gem5]
        })
        .collect()
}

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

#[derive(Debug, Hash, Eq, PartialEq, Clone, Copy)]
enum Feature {
    Seq1([Gem; 1]),
    Seq2([Gem; 2]),
    Seq3([Gem; 3]),
    Seq4([Gem; 4]),
    Seq5([Gem; 5]),
    Seq6([Gem; 6]),
    Span1(usize, [Gem; 1]),
    Span2(usize, [Gem; 2]),
    Span3(usize, [Gem; 3]),
    Span4(usize, [Gem; 4]),
    Span5(usize, [Gem; 5]),
    Span6(usize, [Gem; 6]),
    Php(usize),
    StartX(Gem),
    StartY(Gem),
    StartVdel(Gem),
    StartInVdel(bool),
    StartGrp0(Gem),
}

fn identify_features(gems: &[Gem; 6]) -> HashSet<Feature> {
    let mut res = vec![];

    // spans
    res.append(&mut gems.windows(1).enumerate()
        .map(|(idx, s)| Feature::Span1(idx, [s[0]])).collect());
    res.append(&mut gems.windows(2).enumerate()
        .map(|(idx, s)| Feature::Span2(idx, [s[0], s[1]])).collect());
    res.append(&mut gems.windows(3).enumerate()
        .map(|(idx, s)| Feature::Span3(idx, [s[0], s[1], s[2]])).collect());
    res.append(&mut gems.windows(4).enumerate()
        .map(|(idx, s)| Feature::Span4(idx, [s[0], s[1], s[2], s[3]])).collect());
    res.append(&mut gems.windows(5).enumerate()
        .map(|(idx, s)| Feature::Span5(idx, [s[0], s[1], s[2], s[3], s[4]])).collect());
    res.append(&mut gems.windows(6).enumerate()
        .map(|(idx, s)| Feature::Span6(idx, [s[0], s[1], s[2], s[3], s[4], s[5]])).collect());

    // sequences
    res.append(&mut gems.windows(1).enumerate()
        .map(|(idx, s)| Feature::Seq1([s[0]])).collect());
    res.append(&mut gems.windows(2).enumerate()
        .map(|(idx, s)| Feature::Seq2([s[0], s[1]])).collect());
    res.append(&mut gems.windows(3).enumerate()
        .map(|(idx, s)| Feature::Seq3([s[0], s[1], s[2]])).collect());
    res.append(&mut gems.windows(4).enumerate()
        .map(|(idx, s)| Feature::Seq4([s[0], s[1], s[2], s[3]])).collect());
    res.append(&mut gems.windows(5).enumerate()
        .map(|(idx, s)| Feature::Seq5([s[0], s[1], s[2], s[3], s[4]])).collect());
    res.append(&mut gems.windows(6).enumerate()
        .map(|(idx, s)| Feature::Seq6([s[0], s[1], s[2], s[3], s[4], s[5]])).collect());

    res.into_iter().collect()
}

#[derive(Copy, Clone, PartialEq, Hash, Debug)]
enum Kernel {
    A,
    B,
}

type Program = Vec<Bytecode>;
type Export = HashMap<GemRow, (Program, State, State)>;
type ExportFormat = Vec<(GemRow, (Program, State, State))>;


fn main_generate_tables() {
    for kernel in [Kernel::A, Kernel::B].into_iter() {
    // for kernel in [Kernel::A].into_iter() {
        let mut solved: Export = hashmap![];
        for gems in gem_permutations() {
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

    // Check for imbalanced vdel.
    if state.in_vdel {
        // println!("imbalanced vdel");
        return None;
    }
    print!(". ");

    Some((program, init_state, state))
}

fn main_process_features() {
    let kernel = Kernel::B;

    let json_file = File::open(&format!("{:?}.txt", kernel)).unwrap();
    let list: ExportFormat =
        serde_json::from_reader(json_file).expect("error while reading json");
    let solved: Export = list.into_iter().collect();

    for (gems, (program, init_state, state)) in solved.clone() {
        println!("G {:?}", gems);
        println!("  {:?}", program);
    }
    println!();

    println!("==== FEATURE DETECTION ====");
    let mut feature_union: HashMap<Feature, isize> = hashmap![];
    let mut total = 0;
    'solver: for (gems, (program, init_state, state)) in solved {
        // let cond = program.iter().position(|bc| *bc == Bytecode::BlankOn).is_none();
        let cond = init_state.y == Gem_1_1;
        if !cond {
            continue;
        }

        let mut features = hashset![
            // Feature::Php(program.iter().position(|bc| *bc == Bytecode::Php).unwrap()),
            Feature::StartX(init_state.x),
            Feature::StartY(init_state.y),
            Feature::StartVdel(init_state.vdel_value),
            Feature::StartInVdel(init_state.in_vdel),
            Feature::StartGrp0(init_state.grp0),
        ];
        features.extend(identify_features(&gems));

        // Disqualify some features.
        let disqualifying = vec![
        ];
        for dis in &disqualifying {
            if features.contains(dis) {
                continue 'solver;
            }
        }

        if cond {
            total += 1;
        }

        // 
        for feature in features {
            // if cond {
                *feature_union.entry(feature).or_insert(0) += 1;
            // } else {
            //     // Non cond
            //     if let Some(entry) = feature_union.get_mut(&feature) {
            //         *entry -= 1;
            //     }
            // }
        }

        // Print filtered rows.
        // println!("Gems {:?}", gems);
    }
    println!();

    println!("total {:?}", total);
    let mut list = feature_union.into_iter().collect::<Vec<_>>();
    list.sort_by(|a, b| b.1.cmp(&a.1));
    for (i, item) in list.into_iter().enumerate().take(30) {
        println!("{}: {:?}", i, item);
    }
}

