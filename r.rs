// cargo-deps: piston="*" opengl-graphics="*" graphics="*" glutin_window="*"

extern crate piston;
extern crate opengl_graphics;
extern crate graphics;
extern crate glutin_window;

use opengl_graphics::{ GlGraphics, OpenGL };
use graphics::{ Context, Graphics };
use std::collections::HashMap;
use piston::window::{ AdvancedWindow, WindowSettings };
use piston::input::*;
use piston::event_loop::*;
use glutin_window::GlutinWindow as Window;

type AxisValues = HashMap<(i32, u8), f64>;
type TouchValues = HashMap<(i64, i64), ([f64; 2], f64)>;

fn main() {
    let opengl = OpenGL::V3_2;
    let mut window: Window = WindowSettings::new("piston-example-user_input", [600, 600])
        .exit_on_esc(true).opengl(opengl).build().unwrap();

    println!("Press C to turn capture cursor on/off");

    let mut capture_cursor = false;
    let ref mut gl = GlGraphics::new(opengl);
    let mut cursor = [0.0, 0.0];

    let mut axis_values: AxisValues = HashMap::new();
    let mut touch_values: TouchValues = HashMap::new();

    let mut events = window.events();
    while let Some(e) = events.next(&mut window) {
        if let Some(Button::Mouse(button)) = e.press_args() {
            println!("Pressed mouse button '{:?}'", button);
        }
        if let Some(Button::Keyboard(key)) = e.press_args() {
            if key == Key::C {
                println!("Turned capture cursor on");
                capture_cursor = !capture_cursor;
                window.set_capture_cursor(capture_cursor);
            }

            println!("Pressed keyboard key '{:?}'", key);
        };
        if let Some(button) = e.release_args() {
            match button {
                Button::Keyboard(key) => println!("Released keyboard key '{:?}'", key),
                Button::Mouse(button) => println!("Released mouse button '{:?}'", button),
                Button::Controller(button) => println!("Released controller button '{:?}'", button),
            }
        };
        if let Some(args) = e.touch_args() {
            match args.touch {
                Touch::Start | Touch::Move => {
                    touch_values.insert((args.device, args.id), (args.position(), args.pressure()));
                }
                Touch::End | Touch::Cancel => {
                    touch_values.remove(&(args.device, args.id));
                }
            }
            println!("Touch '{} {:?} {} {}'", args.id, args.touch, args.x, args.y);
        }
        if let Some(args) = e.controller_axis_args() {
            axis_values.insert((args.id, args.axis), args.position);
        }
        e.mouse_cursor(|x, y| {
            cursor = [x, y];
            println!("Mouse moved '{} {}'", x, y);
        });
        e.mouse_scroll(|dx, dy| println!("Scrolled mouse '{}, {}'", dx, dy));
        e.mouse_relative(|dx, dy| println!("Relative mouse moved '{} {}'", dx, dy));
        e.text(|text| println!("Typed '{}'", text));
        e.resize(|w, h| println!("Resized '{}, {}'", w, h));
        if let Some(focused) = e.focus_args() {
            if focused { println!("Gained focus"); }
            else {
                touch_values.clear();
                println!("Lost focus");
            }
        };
        if let Some(cursor) = e.cursor_args() {
            if cursor { println!("Mouse entered"); }
            else { println!("Mouse left"); }
        };
        if let Some(args) = e.render_args() {
            gl.draw(args.viewport(), |c, g| {
                    graphics::clear([1.0; 4], g);
                    draw_rectangles(cursor, &window, &c, g);
                    draw_axis_values(&mut axis_values, &window, &c, g);
                    draw_touch_values(&mut touch_values, &window, &c, g);
                }
            );
        }
        e.update(|_| {});
    }
}

fn draw_rectangles<G: Graphics>(
    cursor: [f64; 2],
    window: &Window,
    c: &Context,
    g: &mut G,
) {
    use piston::window::Window;

    let size = window.size();
    let draw_size = window.draw_size();
    let zoom = 0.2;
    let offset = 30.0;

    let rect_border = graphics::Rectangle::new_border([1.0, 0.0, 0.0, 1.0], 1.0);

    // Cursor.
    let cursor_color = [0.0, 0.0, 0.0, 1.0];
    let zoomed_cursor = [offset + cursor[0] * zoom, offset + cursor[1] * zoom];
    graphics::ellipse(
        cursor_color,
        graphics::ellipse::circle(zoomed_cursor[0], zoomed_cursor[1], 4.0),
        c.transform,
        g
    );

    // User coordinates.
    rect_border.draw([
            offset,
            offset,
            size.width as f64 * zoom,
            size.height as f64 * zoom
        ],
        &c.draw_state, c.transform, g);
    let rect_border = graphics::Rectangle::new_border([0.0, 0.0, 1.0, 1.0], 1.0);
    rect_border.draw(
        [
            offset + size.width as f64 * zoom,
            offset,
            draw_size.width as f64 * zoom,
            draw_size.height as f64 * zoom
        ],
        &c.draw_state, c.transform, g);
}

fn draw_axis_values<G: Graphics>(
    axis_values: &mut AxisValues,
    window: &Window,
    c: &Context,
    g: &mut G
) {
    use piston::window::Window;

    let window_height = window.size().height as f64;
    let max_axis_height = 200.0;
    let offset = 10.0;
    let top = window_height - (max_axis_height + offset);
    let color = [1.0, 0.0, 0.0, 1.0];
    let width = 10.0;
    let mut draw = |i, v: f64| {
        let i = i as f64;
        let height = (v + 1.0) / 2.0 * max_axis_height;
        let rect = [offset + i * (width + offset),
            top + max_axis_height - height, width, height];
        graphics::rectangle(color, rect, c.transform, g);
    };
    for (i, &v) in axis_values.values().enumerate() {
        draw(i, v);
    }
}

fn draw_touch_values<G: Graphics>(
    touch_values: &mut TouchValues,
    window: &Window,
    c: &Context,
    g: &mut G
) {
    use piston::window::Window;

    let window_size = window.size();
    let window_size = [window_size.width as f64, window_size.height as f64];
    let color = [1.0, 0.0, 0.0, 0.4];
    let radius = 20.0;
    let mut draw = |pos: [f64; 2], pressure: f64| {
        let r = radius * pressure;
        let x = pos[0] * window_size[0] - r;
        let y = pos[1] * window_size[1] - r;
        let w = 2.0 * r;
        graphics::ellipse(color, [x, y, w, w], c.transform, g);
    };
    for &(pos, pressure) in touch_values.values() {
        draw(pos, pressure);
    }
}
