$fn = 64;

// PCB overall dimensions (must match request)
length = 50.0;
width  = 26.0;
thickness = 1.6;

// Structural overlap to guarantee one connected solid (1–2mm as required)
overlap = 1.2;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1, center=true) {
    rr = min(r, min(size[0], size[1]) / 2 - 0.01);
    if (rr <= 0) {
        cube(size, center=center);
    } else {
        minkowski() {
            cube([size[0]-2*rr, size[1]-2*rr, size[2]], center=center);
            cylinder(r=rr, h=0.01, center=true);
        }
    }
}

// Place a top-mounted part so it *intersects* the PCB by `overlap`
function z_on_pcb(part_h) = thickness/2 + part_h/2 - overlap;

module pcb_with_holes() {
    hole_d = 3.2;
    hole_r = hole_d/2;

    edge_x = 3.0;
    edge_y = 3.0;

    x_off = length/2 - edge_x;
    y_off = width/2  - edge_y;

    difference() {
        color([0.0, 0.4, 0.2])
            cube([length, width, thickness], center=true);

        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*x_off, sy*y_off, 0])
                cylinder(h=thickness + 0.6, r=hole_r, center=true);
    }
}

module relay_block() {
    rb_l = 19.0;
    rb_w = 15.5;
    rb_h = 15.0;

    // Keep same general location, but ensure Z overlap into PCB
    x_pos = -length/2 + 6.0 + rb_l/2;
    z_pos = z_on_pcb(rb_h);

    // Add a subtle "foot" that penetrates into PCB to guarantee fusion
    foot_t = overlap + 0.6;
    foot_z = thickness/2 - foot_t/2; // inside PCB volume

    union() {
        color([0.05, 0.2, 0.85])
            translate([x_pos, 0, z_pos])
                rounded_box([rb_l, rb_w, rb_h], r=1.0, center=true);

        color([0.05, 0.2, 0.85])
            translate([x_pos, 0, foot_z])
                rounded_box([rb_l-2.0, rb_w-2.0, foot_t], r=0.8, center=true);
    }
}

module terminal_block() {
    tb_l = 15.0;
    tb_w = 10.0;
    tb_h = 12.0;

    x_pos = length/2 - 2.0 - tb_l/2;
    z_pos = z_on_pcb(tb_h);

    // Add a subtle "foot" that penetrates into PCB to guarantee fusion
    foot_t = overlap + 0.6;
    foot_z = thickness/2 - foot_t/2; // inside PCB volume

    union() {
        // Main green block (overlaps PCB)
        color([0.0, 0.55, 0.25])
            translate([x_pos, 0, z_pos])
                rounded_box([tb_l, tb_w, tb_h], r=0.8, center=true);

        // Foot into PCB (ensures no floating/disconnected terminal block)
        color([0.0, 0.55, 0.25])
            translate([x_pos, 0, foot_z])
                rounded_box([tb_l-1.6, tb_w-1.6, foot_t], r=0.6, center=true);

        // Screw "recesses" as shallow posts that intersect the terminal block
        screw_d = 3.2;
        screw_r = screw_d/2;
        pitch = tb_l/3;

        screw_h = 3.0;
        z_screw = (thickness/2 + tb_h) - screw_h/2 - 0.6; // inside the block

        for (i = [-1, 0, 1]) {
            color([0.15, 0.15, 0.15])
                translate([x_pos + i*pitch, 0, z_screw])
                    cylinder(h=screw_h, r=screw_r, center=true);
        }
    }
}

module pin_header() {
    pins = 3;
    pitch = 2.54;

    ph_l = (pins-1)*pitch + 2.5;
    ph_w = 5.0;
    ph_h = 8.0;

    // Same intended placement near terminal side, offset in Y
    x_pos = length/2 - 2.0 - 15.0 - 2.0 - ph_l/2;
    y_pos = -width/2 + 4.0 + ph_w/2;
    z_pos = z_on_pcb(ph_h);

    union() {
        // Black plastic (overlaps PCB)
        color([0.05, 0.05, 0.05])
            translate([x_pos, y_pos, z_pos])
                rounded_box([ph_l, ph_w, ph_h], r=0.6, center=true);

        // Add a small base "skirt" that penetrates into PCB to guarantee fusion
        skirt_t = overlap + 0.6;
        skirt_z = thickness/2 - skirt_t/2; // inside PCB volume
        color([0.05, 0.05, 0.05])
            translate([x_pos, y_pos, skirt_z])
                rounded_box([ph_l-0.8, ph_w-0.8, skirt_t], r=0.4, center=true);

        // Pins: extend through header and into PCB (guaranteed overlap)
        pin_w = 0.7;
        extra_below = 2.0;
        pin_h = ph_h + thickness + extra_below;

        // Center pins so they pass through header and into PCB
        z_pin = z_pos - ph_h/2 + pin_h/2 - overlap;

        for (i = [0:pins-1]) {
            px = x_pos - ph_l/2 + 1.25 + i*pitch;

            color([0.75, 0.65, 0.2])
                translate([px, y_pos, z_pin])
                    cube([pin_w, pin_w, pin_h], center=true);

            // Through-hole boss intersects PCB to make pin-to-PCB joint unambiguous
            boss_r = 0.9;
            boss_h = thickness + 0.8;
            color([0.75, 0.65, 0.2])
                translate([px, y_pos, 0])
                    cylinder(h=boss_h, r=boss_r, center=true);
        }
    }
}

module small_components() {
    // LED + resistor-like part; both must overlap PCB by `overlap`
    led_l = 3.2; led_w = 2.0; led_h = 1.6;
    r_l   = 6.0; r_w   = 2.2; r_h   = 2.2;

    x_led = length/2 - 18.0;
    y_led = width/2 - 5.0;
    z_led = z_on_pcb(led_h);

    x_r = x_led - 6.0;
    y_r = y_led - 3.0;
    z_r = z_on_pcb(r_h);

    union() {
        // Components (overlap into PCB via z_on_pcb)
        color([0.8, 0.1, 0.1])
            translate([x_led, y_led, z_led])
                rounded_box([led_l, led_w, led_h], r=0.4, center=true);

        color([0.75, 0.65, 0.45])
            translate([x_r, y_r, z_r])
                rounded_box([r_l, r_w, r_h], r=0.6, center=true);

        // Solder-pad "feet" that intersect PCB to guarantee attachment
        pad_t = overlap + 0.6;                 // 1.8mm -> solid overlap into PCB
        pad_z = thickness/2 - pad_t/2;         // inside PCB volume
        color([0.65, 0.55, 0.2])
            translate([x_led, y_led, pad_z])
                cube([led_l+0.8, led_w+0.8, pad_t], center=true);

        color([0.65, 0.55, 0.2])
            translate([x_r, y_r, pad_z])
                cube([r_l+1.0, r_w+0.8, pad_t], center=true);
    }
}

// ---------- Assembly (ONE connected solid) ----------
module assembly() {
    union() {
        pcb_with_holes();
        relay_block();
        terminal_block();
        pin_header();
        small_components();
    }
}

assembly();