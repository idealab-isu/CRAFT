$fn = 64;

// Battery charger module (PCB + major features) as ONE connected solid
module battery_charger_module(L=26.2, W=17.5, T=1.0) {

    // PCB corner radius
    corner_r = 1.2;

    // Micro-USB connector (on +Y short edge)
    usb_w = 7.6;
    usb_d = 5.8;
    usb_h = 2.6;

    // Battery pads (on -Y short edge, top)
    pad_len = 4.2;
    pad_w   = 2.0;
    pad_h   = 0.25;

    // Pin header / solder block (near -Y edge, top)
    header_w = 10.0;
    header_d = 3.0;
    header_h = 2.2;

    // Main IC (top)
    chip_l = 6.0;
    chip_w = 5.0;
    chip_h = 1.0;

    // Inductor / large component (top)
    inductor_d = 6.0;
    inductor_h = 2.0;

    // LEDs (top, near +Y edge)
    led_d = 1.6;
    led_h = 0.6;

    // Small overlap to guarantee watertight union connections
    ov = 0.15;

    // Rounded PCB base (exact L x W footprint, thickness T)
    module rounded_pcb(l, w, t, r) {
        linear_extrude(height=t, center=false)
            offset(r=r)
                square([l - 2*r, w - 2*r], center=true);
    }

    // Clamp helper to keep features within board outline where needed
    function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

    union() {
        // PCB: bottom at z=0, top at z=T
        translate([0, 0, 0])
            rounded_pcb(L, W, T, corner_r);

        // Micro-USB connector: sits on top of PCB and protrudes beyond +Y edge
        // Ensure it overlaps into PCB by ov in both Y and Z.
        translate([0,
                   W/2 + usb_d/2 - ov,
                   T + usb_h/2 - ov])
            cube([usb_w, usb_d, usb_h], center=true);

        // Battery pads (B+ / B-) on top near -Y edge, kept within board
        pad_y = -W/2 + pad_w/2 + 0.8;
        pad_x_off = clamp(pad_len/2 + 1.2, 0, L/2 - pad_len/2 - 0.6);
        for (sx = [-1, 1]) {
            translate([sx*pad_x_off,
                       pad_y,
                       T + pad_h/2 - ov])
                cube([pad_len, pad_w, pad_h], center=true);
        }

        // Header/solder block near -Y edge on top, kept within board
        header_y = -W/2 + header_d/2 + 3.0;
        translate([0,
                   header_y,
                   T + header_h/2 - ov])
            cube([header_w, header_d, header_h], center=true);

        // Main charger IC on top center
        translate([0, 0, T + chip_h/2 - ov])
            cube([chip_l, chip_w, chip_h], center=true);

        // Inductor on top, offset but within board
        ind_x = clamp(L*0.22, -L/2 + inductor_d/2 + 0.6, L/2 - inductor_d/2 - 0.6);
        ind_y = clamp(W*0.12, -W/2 + inductor_d/2 + 0.6, W/2 - inductor_d/2 - 0.6);
        translate([ind_x, ind_y, T + inductor_h/2 - ov])
            cylinder(d=inductor_d, h=inductor_h, center=true);

        // Two LEDs near +Y edge on top, kept within board
        led_y = W/2 - 3.0;
        led_x_off = clamp(3.0, 0, L/2 - led_d/2 - 0.6);
        for (sx = [-1, 1]) {
            translate([sx*led_x_off,
                       led_y,
                       T + led_h/2 - ov])
                cylinder(d=led_d, h=led_h, center=true);
        }
    }
}

battery_charger_module();