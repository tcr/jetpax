use gemkernel::*;
use maplit::*;
use itertools::*;
use rand::Rng;
use rayon::prelude::*;
use std::collections::{HashMap, HashSet};
use std::fs::File;
use std::io::prelude::*;
use serde_json;
use serde::{Serialize, Deserialize};

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

// Detect features of program or state.
fn feature_detect(program: &Program, init_state: &State, state: &State) -> bool {
    program.iter().position(|bc| *bc == Bytecode::BlankOn).is_none()
    // init_state.y == Gem_1_1
}

// Identify features from a GemRow.
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
    // res.append(&mut gems.windows(1).enumerate() // kinda useless
    //     .map(|(idx, s)| Feature::Seq1([s[0]])).collect());
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

        // 

    res.into_iter().collect()
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
        let cond = feature_detect(&program, &init_state, &state);
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
