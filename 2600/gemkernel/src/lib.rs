// TODO The Reset3 functionality in kernel A (only for kernel A!) is by missing
// the prior RESP0 call, calling RESP0 on the GEM_09 write. This will bump the
// spries over by one column, unfortunately, so a trick of: only writing the 
// high bit (as the low bit) and ussing the right missile starting earlier to
// get the sprites working. it's tricky but i'm done with it lol

#![allow(non_camel_case_types, dead_code, unused_variables)]

use itertools::*;
use rand::Rng;
use rayon::prelude::*;
use std::collections::{HashSet, HashMap};
use std::io::prelude::*;
use serde_json;
use serde::{Serialize, Deserialize};

#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, PartialOrd, Ord)]
pub enum Gem {
    Gem_0_0,
    Gem_0_1,
    Gem_1_0,
    Gem_1_1,
}

pub use self::Gem::*;

#[derive(Hash, Debug, Copy, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum Bytecode {
    Nop,
    VdelOn,
    VdelOff,
    BlankOn,
    Stx,
    Sty,
    Php10,
    Php11,
    Reflect,
    Reset4,
}

#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub struct State {
    pub x: Gem,
    pub y: Gem,
    pub in_vdel: bool,
    pub in_blank: bool,
    pub vdel_value: Gem,
    pub reflected: bool,
    pub grp0: Gem,
}

impl State {
    pub fn current(&self) -> Gem {
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

    pub fn step(&self, bc: Bytecode) -> Option<State> {
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
            Bytecode::Stx => {
                state.grp0 = state.x;
            }
            Bytecode::Sty => {
                state.grp0 = state.y;
            }
            Bytecode::Reflect => {
                state.reflected = !state.reflected;
            }
            Bytecode::Php10 => {
                state.grp0 = Gem_1_0;
            }
            Bytecode::Php11 => {
                state.grp0 = Gem_1_1;
            }
            Bytecode::Reset4 => {
                panic!("unreachable");
            }
        }
        Some(state)
    }
}

pub type GemRow = [Gem; 6];

// All possible gme permutations.
pub fn all_gem_rows() -> Vec<GemRow> {
    // Hardcoded override.
    // return vec![
    //     [Gem_0_0, Gem_0_0, Gem_0_1, Gem_1_0, Gem_0_0, Gem_0_0]
    // ];

    let all_gems = vec![Gem_0_0, Gem_0_1, Gem_1_0, Gem_1_1];
    iproduct!(&all_gems, &all_gems, &all_gems, &all_gems, &all_gems, &all_gems)
        .into_iter()
        .map(|(gem0, gem1, gem2, gem3, gem4, gem5)| {
            [*gem0, *gem1, *gem2, *gem3, *gem4, *gem5]
        })
        .collect()
}

#[derive(Copy, Clone, PartialEq, Hash, Debug)]
pub enum Kernel {
    A,
    B,
}

pub type Program = Vec<Bytecode>;
pub type Export = HashMap<GemRow, (Program, State, State)>;
pub type ExportFormat = Vec<(GemRow, (Program, State, State))>;

pub fn distinct(gems: &[Gem]) -> usize {
    gems.iter().collect::<HashSet<_>>().len()
}
