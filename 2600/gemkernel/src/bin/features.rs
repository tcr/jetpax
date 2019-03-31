#![allow(non_camel_case_types, dead_code, unused_variables)]

use gemkernel::*;
use maplit::*;
use std::collections::{HashMap, HashSet};
use std::fs::File;
use serde_json;

// Filter for features of program or state to restrict solving to.
fn feature_detect(gems: &GemRow, program: &Program, init_state: &State, state: &State) -> bool {
    // Filter to which X value should be used.
    init_state.x == Gem_1_1

    // if gems.iter().collect::<HashSet<_>>().len() < 3 {
    //     return false;
    // }
    // program.iter().position(|bc| *bc == Bytecode::BlankOn).is_none()
    // program[2] == Bytecode::Reset4
    // true
}

#[derive(Debug, Hash, Eq, PartialEq, Clone, Copy)]
enum Feature {
    GemDistinct(usize),
    GemSeq1([Gem; 1]),
    GemSeq2([Gem; 2]),
    GemSeq3([Gem; 3]),
    GemSeq4([Gem; 4]),
    GemSeq5([Gem; 5]),
    GemSeq6([Gem; 6]),
    GemSpan1(usize, [Gem; 1]),
    GemSpan2(usize, [Gem; 2]),
    GemSpan3(usize, [Gem; 3]),
    GemSpan4(usize, [Gem; 4]),
    GemSpan5(usize, [Gem; 5]),
    GemSpan6(usize, [Gem; 6]),
    ProgramPhp(usize),
    StateInitGrp0(Gem),
    StateInitInVdel(bool),
    StateInitVdel(Gem),
    StateInitX(Gem),
    StateInitY(Gem),
}

// Identify features from a GemRow.
fn identify_row_features(gems: &GemRow) -> HashSet<Feature> {
    let mut res = vec![];

    // spans
    res.append(&mut gems.windows(1).enumerate()
        .map(|(idx, s)| Feature::GemSpan1(idx, [s[0]])).collect());
    res.append(&mut gems.windows(2).enumerate()
        .map(|(idx, s)| Feature::GemSpan2(idx, [s[0], s[1]])).collect());
    res.append(&mut gems.windows(3).enumerate()
        .map(|(idx, s)| Feature::GemSpan3(idx, [s[0], s[1], s[2]])).collect());
    res.append(&mut gems.windows(4).enumerate()
        .map(|(idx, s)| Feature::GemSpan4(idx, [s[0], s[1], s[2], s[3]])).collect());
    res.append(&mut gems.windows(5).enumerate()
        .map(|(idx, s)| Feature::GemSpan5(idx, [s[0], s[1], s[2], s[3], s[4]])).collect());
    res.append(&mut gems.windows(6).enumerate()
        .map(|(idx, s)| Feature::GemSpan6(idx, [s[0], s[1], s[2], s[3], s[4], s[5]])).collect());

    // sequences
    // res.append(&mut gems.windows(1).enumerate() // kinda useless
    //     .map(|(idx, s)| Feature::Seq1([s[0]])).collect());
    res.append(&mut gems.windows(2).enumerate()
        .map(|(idx, s)| Feature::GemSeq2([s[0], s[1]])).collect());
    res.append(&mut gems.windows(3).enumerate()
        .map(|(idx, s)| Feature::GemSeq3([s[0], s[1], s[2]])).collect());
    res.append(&mut gems.windows(4).enumerate()
        .map(|(idx, s)| Feature::GemSeq4([s[0], s[1], s[2], s[3]])).collect());
    res.append(&mut gems.windows(5).enumerate()
        .map(|(idx, s)| Feature::GemSeq5([s[0], s[1], s[2], s[3], s[4]])).collect());
    res.append(&mut gems.windows(6).enumerate()
        .map(|(idx, s)| Feature::GemSeq6([s[0], s[1], s[2], s[3], s[4], s[5]])).collect());

    // Count distinct values.
    let distinct = gems.iter().collect::<HashSet<_>>().len();
    for i in 3..=distinct { // start at 3.
        res.push(Feature::GemDistinct(i));
    }

    res.into_iter().collect()
}

fn main() {
    let kernel = Kernel::A;

    let json_file = File::open(&format!("{:?}.txt", kernel)).unwrap();
    let list: ExportFormat =
        serde_json::from_reader(json_file).expect("error while reading json");
    let solved: Export = list.into_iter().collect();

    // // Print the entire document.
    // for (gems, (program, init_state, state)) in solved.clone() {
    //     println!("G {:?}", gems);
    //     println!("  {:?}", program);
    // }
    // println!();

    let mut feature_union: HashMap<Feature, isize> = hashmap![];
    let mut total = 0;
    'solver: for (gems, (program, init_state, state)) in solved.clone() {
        let cond = feature_detect(&gems, &program, &init_state, &state);
        if !cond {
            continue;
        }

        let mut features = hashset![
            // Feature::Php(program.iter().position(|bc| *bc == Bytecode::Php).unwrap()),
            Feature::StateInitX(init_state.x),
            Feature::StateInitY(init_state.y),
            Feature::StateInitVdel(init_state.vdel_value),
            Feature::StateInitInVdel(init_state.in_vdel),
            Feature::StateInitGrp0(init_state.grp0),
        ];
        features.extend(identify_row_features(&gems));

        // OVERRIDE Disqualify some features from feature detection.
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
    println!("==== FEATURE DETECTION ====");
    println!();
    println!("feature_detect() selected {:?} out of {:?} rows.", total, solved.iter().count());
    println!();
    let mut list = feature_union.into_iter().collect::<Vec<_>>();
    list.sort_by(|a, b| b.1.cmp(&a.1));
    for (i, item) in list.into_iter().enumerate().take(30) {
        println!("{:2}: {:4} rows = {:?}", i, item.1, item.0);
    }
    println!("...");
}
