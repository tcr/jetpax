#![allow(non_camel_case_types, dead_code, unused_variables)]

use gemkernel::*;
use maplit::*;
use std::collections::{HashMap, HashSet};
use std::fs::File;
use serde_json;

const RESULT_LIST_COUNT: usize = 30;
const FILTER_KERNEL: Kernel = Kernel::A;

// Filter for features of program or state to restrict solving to.
fn feature_detect(features: &[Feature]) -> bool {
    true
    // && features.iter().find(|x| {
    //     // Only show complex scenarios
    //     **x == Feature::GemDistinctTotal(3) ||
    //     **x == Feature::GemDistinctTotal(4)
    // }).is_some()

    // Custom filters

    && features.iter().find(|x| {
        **x == Feature::StateInitInVdel(true)
    }).is_some()
    // && features.iter().find(|x| {
    //     **x == Feature::GemDistinctTotal(3)
    // }).is_some()
    // && features.iter().find(|x| {
    //     **x == Feature::ProgramBytecodeIndex(2, Bytecode::Reflect)
    // }).is_some()
    // && features.iter().find(|x| {
    //     **x == Feature::GemSeq2([Gem_1_0, Gem_0_1]) ||
    //     **x == Feature::GemSeq2([Gem_0_1, Gem_1_0])
    // }).is_none()
}

// OVERRIDE Blacklist some features from printed list. TODO
// don't leave these overridden for too long, they're helpful.
fn features_filter_output(feature: &Feature) -> bool {
    match feature {
        | Feature::ProgramBytecode(Bytecode::Stx)
        | Feature::ProgramBytecode(Bytecode::Sty)
        | Feature::ProgramBytecodeIndex(_, Bytecode::Nop)
        // | Feature::GemSeq1(_)
        // | Feature::GemSpan1(_, _)
        // | Feature::GemDistinct(_)
        // | Feature::ProgramBytecodeIndex(_, _) 
        | Feature::ProgramBytecode(Bytecode::Nop) => false,

        // Whitelist
        // Feature::ProgramBytecodeIndex(_, Bytecode::Php) => true,
        // | Feature::StateInitY(_) => true,
        // _ => false,
        _ => true,
    }
}

#[derive(Debug, Hash, Eq, PartialEq, Clone, Copy)]
enum Feature {
    GemDistinctTotal(usize), // count
    GemDistinct4Window(usize, usize), // start, size
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
    ProgramBytecode(Bytecode),
    ProgramBytecodeIndex(usize, Bytecode),
    StateInitGrp0(Gem),
    StateInitInVdel(bool),
    StateInitVdel(Gem),
    StateInitX(Gem),
    StateInitY(Gem),
    XEqVdel,
    XNeVdel,
    YEqVdel,
    YNeVdel,

    // Custom
    StateVdelIsNotGem1,
    StateVdelIsNotGem0,
    ProgramLateVdel,
    ProgramVdelGap,
    // PhpDoesntMatchGem
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
    res.append(&mut gems.windows(1).enumerate() // kinda useless
        .map(|(idx, s)| Feature::GemSeq1([s[0]])).collect());
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

    // Count number of distinct values.
    res.push(Feature::GemDistinctTotal(distinct(&gems[..])));

    // Distinct 4 window
    res.append(&mut gems.windows(4).enumerate()
        .filter(|(idx, s)| distinct(&s) >= 4)
        .map(|(idx, s)| Feature::GemDistinct4Window(idx, 4)).collect());
    res.append(&mut gems.windows(5).enumerate()
        .filter(|(idx, s)| distinct(&s) >= 4)
        .map(|(idx, s)| Feature::GemDistinct4Window(idx, 5)).collect());
    res.append(&mut gems.windows(6).enumerate()
        .filter(|(idx, s)| distinct(&s) >= 4)
        .map(|(idx, s)| Feature::GemDistinct4Window(idx, 6)).collect());

    res.into_iter().collect()
}

fn main() {
    // Define the kernel to search for features.
    let kernel = FILTER_KERNEL;

    let json_file = File::open(&format!("{:?}.txt", kernel)).unwrap();
    let list: ExportFormat =
        serde_json::from_reader(json_file).expect("error while reading json");
    let rows: Export = list.into_iter().collect();

    // // Print the entire document.
    // for (gems, (program, init_state, state)) in solved.clone() {
    //     println!("G {:?}", gems);
    //     println!("  {:?}", program);
    // }
    // println!();

    let (total, feature_union) = assess_features(&rows, &feature_detect, true);

    fn assess_features(
        rows: &Export,
        cond: impl Fn(&[Feature]) -> bool,
        print: bool,
    ) -> (usize, HashMap<Feature, isize>) {
        let mut feature_union = hashmap![];
        let mut total = 0;
        'solver: for (gems, (program, init_state, state)) in rows.clone() {
            let mut features = hashset![
                Feature::StateInitX(init_state.x),
                Feature::StateInitY(init_state.y),
                Feature::StateInitVdel(init_state.vdel_value),
                Feature::StateInitInVdel(init_state.in_vdel),
                Feature::StateInitGrp0(init_state.grp0),
            ];
            if init_state.vdel_value != gems[0] {
                features.insert(Feature::StateVdelIsNotGem0);
            }
            for (i, bc) in program.iter().enumerate() {
                features.insert(Feature::ProgramBytecode(*bc));
                features.insert(Feature::ProgramBytecodeIndex(i, *bc));
            }
            features.extend(identify_row_features(&gems));
            features.insert(
                if init_state.x == init_state.vdel_value { Feature::XEqVdel } else { Feature::XNeVdel }
            );
            features.insert(
                if init_state.y == init_state.vdel_value { Feature::YEqVdel } else { Feature::YNeVdel }
            );
            // if let Some(pos) = program.iter().position(|x| *x == Bytecode::Php) {
            //     if gems[pos] != Gem_1_0 {
            //         features.insert(Feature::PhpDoesntMatchGem);
            //     }
            // }

            // Custom
            for (i, bc) in program[1..].iter().enumerate() {
                if *bc == Bytecode::VdelOn {
                    features.insert(Feature::ProgramLateVdel);
                }
                // if *bc == Bytecode::VdelOn && (i >= 3 || program[i+2] == Bytecode::VdelOff) {
                //     features.insert(Feature::ProgramVdelGap);
                // }
            }

            let cond = cond(&features.clone().into_iter().collect::<Vec<_>>());
            if !cond {
                continue;
            }
            total += 1;

            features = features
                .drain()
                .filter(features_filter_output)
                .collect();

            // Summarize feature counts.
            for feature in features {
                *feature_union.entry(feature).or_insert(0) += 1;
            }

            if print {
                println!("         [ {}            ]", program.iter().map(|x| format!("{:>8}", format!("{:?}", x))).collect::<Vec<_>>().join(" | "));
                println!("   gems: [ {} ]", gems.iter().map(|x| format!("{:>8}", format!("{:?}", x))).collect::<Vec<_>>().join(" | "));
                println!();
            }
        }
        (total, feature_union)
    }

    let (all_total, all_features) = assess_features(&rows, |_| true, false);
    println!();
    println!("==== FEATURE DETECTION ====");
    println!();
    println!("feature_detect(kernel::{:?}) selected {:?} out of {:?} rows.", kernel, total, rows.iter().count());
    println!();
    println!(" X  count: 4096 ");
    println!(" 0  count: {:4} / {:4}  feature: <feature_detect()>", total, total);
    
    let mut list = feature_union.into_iter().collect::<Vec<_>>();
    list.sort_by(|a, b| b.1.cmp(&a.1));
    let mut count = 0;
    let mut tilde = false;
    for (i, item) in list.into_iter().enumerate() {
        if !tilde && item.1 < (total as isize) {
            println!(" ~");
            tilde = true;
        }

        let inverse: isize = if let Some(count) = all_features.get(&item.0) { *count } else { -1 };
        
        // // Don't print very popular criteria.
        // let TOP_CRITERIA = 5.0;
        // let TOP_CRITERIA = 1.5;
        // if inverse > (item.1 as f64 * TOP_CRITERIA) as isize {
        //     continue;
        // }

        println!("{:2}  count: {:4} / {:4}  feature: {:?}", i+1, item.1, inverse, item.0);
        count += 1;
        if count > RESULT_LIST_COUNT {
            break;
        }
    }
    println!("...");
}
