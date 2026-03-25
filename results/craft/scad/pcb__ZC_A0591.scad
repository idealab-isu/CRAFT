$fn = 48;

// Motor driver module: 35.0mm x 32.0mm x 1.6mm (overall thickness)
length = 35.0;
width  = 32.0;
thickness = 1.6;

// Small overlap to guarantee one connected solid
overlap = 0.2;

// ---------- Helpers ----------
module rounded_plate(l, w, h, r) {
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([l-2*r, w-2*r], center=true);
}

module pin_row(n=6, pitch=2.54, pin_d=0.7, pin_h=0.8) {
    for (i = [0:n-1]) {
        translate([(i-(n-1)/2)*pitch, 0, 0])
            cylinder(d=pin_d, h=pin_h, center=true);
    }
}

// ---------- Motor driver module (single connected solid, total Z = thickness) ----------
module motor_driver_module() {

    pcb_r = 1.2;
    hole_d = 3.0;
    hole_edge = 3.0; // distance from edges to hole center

    // Keep everything within overall thickness by splitting into top/bottom layers
    top_layer_h = thickness/2;
    bot_layer_h = thickness - top_layer_h;

    top_z =  thickness/2 - top_layer_h/2; // center of top layer
    bot_z = -thickness/2 + bot_layer_h/2; // center of bottom layer

    // --- PCB with holes (full thickness) ---
    difference() {
        rounded_plate(length, width, thickness, pcb_r);

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(length/2 - hole_edge), sy*(width/2 - hole_edge), 0])
                cylinder(d=hole_d, h=thickness + 2, center=true);
        }
    }

    // --- TOP-SIDE low-profile components (all within top_layer_h) ---
    // Main driver IC (center)
    ic_l = 12.0; ic_w = 12.0; ic_h = min(0.8, top_layer_h);
    translate([0, 0, top_z])
        cube([ic_l, ic_w, ic_h], center=true);

    // Screw terminal block on one short edge (motor outputs)
    term_l = 18.0; term_w = 8.5; term_h = min(0.8, top_layer_h);
    term_y = width/2 - term_w/2;
    translate([0, term_y, top_z])
        cube([term_l, term_w, term_h], center=true);

    // Pin header body on opposite short edge (logic)
    hdr_body_l = 18.0; hdr_body_w = 5.0; hdr_body_h = min(0.8, top_layer_h);
    hdr_y = -width/2 + hdr_body_w/2;
    translate([0, hdr_y, top_z])
        cube([hdr_body_l, hdr_body_w, hdr_body_h], center=true);

    // Pins (kept within top layer thickness)
    pins_n = 6;
    pins_pitch = 2.54;
    pins_h = min(0.8, top_layer_h);
    translate([0, hdr_y, top_z])
        pin_row(n=pins_n, pitch=pins_pitch, pin_d=0.7, pin_h=pins_h);

    // Two low-profile capacitors (discs) near terminal side
    cap_d = 6.5; cap_h = min(0.8, top_layer_h);
    cap_y = term_y - term_w/2 - cap_d/2 - 1.0;
    for (x = [-8.0, 8.0]) {
        translate([x, cap_y, top_z])
            cylinder(d=cap_d, h=cap_h, center=true);
    }

    // Small SMD parts cluster (very thin)
    smd_h = min(0.5, top_layer_h);
    for (p = [
        [-12, -4, 3.0, 1.6],
        [-12, -1, 3.0, 1.6],
        [-12,  2, 3.0, 1.6],
        [ 12, -4, 2.4, 1.2],
        [ 12, -1, 2.4, 1.2],
        [ 12,  2, 2.4, 1.2]
    ]) {
        translate([p[0], p[1], top_z])
            cube([p[2], p[3], smd_h], center=true);
    }

    // --- BOTTOM-SIDE pads (within bottom layer thickness) ---
    pad_d = 4.0; pad_h = min(0.6, bot_layer_h);
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(length/2 - hole_edge), sy*(width/2 - hole_edge), bot_z])
            cylinder(d=pad_d, h=pad_h, center=true);
    }

    // Ensure connectivity between top/bottom details and PCB via slight overlap
    // (All parts already intersect PCB volume; overlap not needed in Z, but kept conceptually)
}

// Assembly (single connected solid)
union() {
    motor_driver_module();
}