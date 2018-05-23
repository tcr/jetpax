// cargo-deps: bit-vec="*" piston_window="*"

extern crate bit_vec;
extern crate piston_window;

use piston_window::*;
use bit_vec::BitVec;

const MAP: &'static [u8] = br#"

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!..XXg..g........g.......g.!!!!!!!
!!!!!!!Xg.XXg.X.XXXXXXXXX.X....X.!!!!!!!
!!!!!!!XXg.XX.Xg........X..X...X.!!!!!!!
!!!!!!!.XXg.X.XXXXXXXXX.XX...X.X.!!!!!!!
!!!!!!!g.XXg..X........gX..X...X.!!!!!!!
!!!!!!!Xg.XXg.X.XXXXXXXXX.X....X.!!!!!!!
!!!!!!!XXg.XX.Xg........X..XXX.X.!!!!!!!
!!!!!!!gXXg..gXXXXXXXXX.XX.....X.!!!!!!!
!!!!!!!.gg..gXX........gX.....XX.!!!!!!!
!!!!!!!gXX.gXXXXXXXXXXXXX.X.XX.X.!!!!!!!
!!!!!!!XX.gXXXX....gggg.X......X.!!!!!!!
!!!!!!!X.gXXXXX.X.gXXXXgXXX....X.!!!!!!!
!!!!!!!.gXXXXXX.X.XXXXXXXXXXXXXX.!!!!!!!
!!!!!!!.XXXXXXX.X.gggggg.gggggg.g!!!!!!!
!!!!!!!.XXXXXXX.X.XXXXXXXXXXXXXXX!!!!!!!
!!!!!!!..........................!!!!!!!
!!!!!!!XXXXXXXXXXXXXXXXXXXXXXXXXX!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"#;

fn playfield() -> BitVec {
    let mut v = BitVec::new();
    for &item in MAP.iter() {
        if item == b'X' || item == b'!' {
            v.push(true);
        } else if !(item as char).is_whitespace() {
            v.push(false);
        }
    }
    v
}

fn playfield_gems() -> BitVec {
    let mut v = BitVec::new();
    for &item in MAP.iter() {
        if item == b'g' {
            v.push(true);
        } else if !(item as char).is_whitespace() {
            v.push(false);
        }
    }
    v
}

fn player() -> BitVec {
    let input = br#"

XX..
XX..
X...
XX..
X...
XX..
.X..
.X..

"#;

    let mut v = BitVec::new();
    for &item in input.iter() {
        if item == b'X' {
            v.push(true);
        } else if item == b'.' {
            v.push(false);
        }
    }
    v
}

const GREEN: [f32; 4] = [0.0, 0.0, 0.0, 1.0];
const RED:   [f32; 4] = [0.3, 0.3, 0.3, 1.0];
const PLAYER: [f32; 4] = [0.8, 0.3, 0.3, 1.0];
const GEM: [f32; 4] = [0.0, 0.9, 0.0, 1.0];

fn main() {
    let mut window: PistonWindow = WindowSettings::new("Pistone", [320*2, 192*2])
        .exit_on_esc(true)
        .build()
        .unwrap();

    window.set_max_fps(30);

    let mut frame: u64 = 0;
    let mut pos = (58.0, 48.0);
    while let Some(e) = window.next() {
        if let Some(button) = e.press_args() {
            match button {
                Button::Keyboard(Key::W) => pos.1 -= 1.0,
                Button::Keyboard(Key::A) => pos.0 -= 2.0,
                Button::Keyboard(Key::S) => pos.1 += 1.0,
                Button::Keyboard(Key::D) => pos.0 += 2.0,
                _ => (),
            }
        }

        if let Some(_) = e.render_args() {
            frame += 1;

            window.draw_2d(&e, |c, gl| {
                // Clear the screen.
                clear(GREEN, gl);

                for (i, pixel) in playfield().iter().enumerate() {
                    let x = (i % 40) * 8;
                    let y = (i / 40) * 8;

                    let transform = c.transform
                        .scale(2.0, 2.0)
                        .trans(x as f64, y as f64);

                    if pixel {
                        rectangle(RED,
                            [0.0, 0.0, 8.0, 8.0],
                            transform,
                            gl);
                    }
                }

                for (i, gem) in playfield_gems().iter().enumerate() {
                    if !gem {
                        continue;
                    }

                    let gx = (i % 40) * 8;
                    let gy = (i / 40) * 8;

                    let poverload = pos.1 < (gy as f64) + 5.0 && pos.1 > (gy as f64) - 4.0;
                    let mut gc = if poverload { PLAYER } else { GEM };
                    if frame % 2 != 0 {
                        //gc[3] = 0.6;
                    }

                    rectangle(gc,
                        [0.0, 0.0, 4.0, 2.0],
                        c.transform
                            .scale(2.0, 2.0)
                            .trans(gx as f64 + 2.0, gy as f64 + 2.0),
                        gl);
                    rectangle(RED,
                        [0.0, 0.0, 8.0, 1.0],
                        c.transform
                            .scale(2.0, 2.0)
                            .trans(gx as f64, gy as f64 + 4.0),
                        gl);
                }

                for (i, pixel) in player().iter().enumerate() {
                    let x = (i % 4) * 2 + (pos.0 as usize);
                    let y = (i / 4) * 1 + (pos.1 as usize);

                    let transform = c.transform
                        .scale(2.0, 2.0)
                        .trans(x as f64, y as f64);

                    if pixel {
                        rectangle(PLAYER,
                            [0.0, 0.0, 2.0, 1.0],
                            transform,
                            gl);
                    }
                }

            });
        }
    }
}
