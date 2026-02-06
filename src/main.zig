const std = @import("std");

const zmk = @import("zigmkay");
const zigmkay = zmk.zigmkay;
const dk = zmk.keycodes.dk;
const core = zigmkay.core;
const us = zmk.keycodes.us;
const microzig = zmk.microzig;
const rp2xxx = microzig.hal;
const time = rp2xxx.time;
const gpio = rp2xxx.gpio;

const keymap = @import("keymap.zig");

// uart

const uart_tx_pin = gpio.num(0);
const uart_rx_pin = gpio.num(1);

// zig fmt: off
pub const pin_config = rp2xxx.pins.GlobalConfiguration{
    .GPIO17 = .{ .name = "led", .direction = .out },
    .GPIO1 =  .{ .name = "c4", .direction = .out },
    .GPIO6 =  .{ .name = "r7", .direction = .in },
    .GPIO7 =  .{ .name = "r6", .direction = .in },
    .GPIO8 =  .{ .name = "r5", .direction = .in },
    .GPIO9 =  .{ .name = "r4", .direction = .in },
    .GPIO21 = .{ .name = "r3", .direction = .in },
    .GPIO23 = .{ .name = "r2", .direction = .in },
    .GPIO20 = .{ .name = "r1", .direction = .in },
    .GPIO22 = .{ .name = "r0", .direction = .in },
    .GPIO26 = .{ .name = "c0", .direction = .out },
    .GPIO27 = .{ .name = "c1", .direction = .out },
    .GPIO28 = .{ .name = "c2", .direction = .out },
    .GPIO29 = .{ .name = "c3", .direction = .out },
};
pub const p = pin_config.pins();

pub const pin_mappings = [keymap.key_count]?[2]usize{
          .{0,0}, .{1,0}, .{2,0}, .{3,0}, .{4,0},          .{0,4},.{1,4},.{2,4},.{3,4},.{4,4},
  .{0,3}, .{0,1}, .{1,1}, .{2,1}, .{3,1}, .{4,1},          .{0,5},.{1,5},.{2,5},.{3,5},.{4,5},.{4,7},
          .{0,2}, .{1,2}, .{2,2}, .{3,2}, .{4,2},          .{0,6},.{1,6},.{2,6},.{3,6},.{4,6},
                            .{2,3}, .{3,3}, .{4, 3},   .{0, 7}, .{1,7}, .{2,7}
};

pub const scanner_settings = zigmkay.matrix_scanning.ScannerSettings{
    .debounce = .{ .ms = 50 },
};

// zig fmt: on
pub const clacky_pin_cols = [_]rp2xxx.gpio.Pin{ p.c0, p.c1, p.c2, p.c3, p.c4 };
pub const clacky_pin_rows = [_]rp2xxx.gpio.Pin{ p.r0, p.r1, p.r2, p.r3, p.r4, p.r5, p.r6, p.r7 };

pub fn main() !void {

    // Init pins
    pin_config.apply(); // dont know how this could be done inside the module, but it needs to be done for things to work
    blink_led(1, 300);
    zigmkay.run_primary(
        keymap.dimensions,
        clacky_pin_cols[0..],
        clacky_pin_rows[0..],
        scanner_settings,
        keymap.combos[0..],
        &keymap.custom_functions,
        pin_mappings,
        &keymap.keymap,
        keymap.sides,
        null,
    ) catch {
        blink_led(100000, 50);
    };
}

pub fn blink_led(blink_count: u32, interval_ms: u32) void {
    var counter = blink_count;
    while (counter > 0) : (counter -= 1) {
        p.led.put(1);
        time.sleep_us(interval_ms * 1000);
        p.led.put(0);
        time.sleep_us(interval_ms * 1000);
    }
}
