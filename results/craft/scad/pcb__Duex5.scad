$fn = 64;

// Board parameters (must match)
length = 123.0;
width  = 100.0;
thickness = 1.6;

// Small overlap to guarantee one connected solid
overlap = 0.4;

// ---------- Helpers ----------
module rounded_plate(l, w, h, r) {
    // Rounded rectangle prism using hull of corner cylinders
    r2 = min(r, min(l, w)/2);
    if (r2 <= 0) {
        cube([l, w, h], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(l/2 - r2), sy*(w/2 - r2), 0])
                    cylinder(r=r2, h=h, center=true);
        }
    }
}

module chip_body(l, w, h) {
    // Simple IC package with slight top bevel
    hull() {
        translate([0,0,-h/2]) cube([l, w, 0.2], center=true);
        translate([0,0, h/2]) cube([l*0.96, w*0.96, 0.2], center=true);
    }
}

module pin_row(n=8, pitch=2.54, pin_w=0.7, pin_l=3.0, pin_h=2.0) {
    // Pins extend outward from a header body; centered on origin
    for (i = [0:n-1]) {
        translate([(i-(n-1)/2)*pitch, 0, 0])
            cube([pin_w, pin_l, pin_h], center=true);
    }
}

// ---------- Main model ----------
module control_board() {
    // Corner radius for PCB outline
    pcb_r = 3.0;

    // Mounting holes (typical 4-corner pattern)
    hole_d = 3.2;
    hole_edge = 6.0; // distance from each edge to hole center

    // Z references
    pcb_z = 0;
    top_z = pcb_z + thickness/2;
    bottom_z = pcb_z - thickness/2;

    // Components (heights)
    mcu_h = 3.0;
    driver_h = 4.0;
    usb_h = 4.5;
    usb_w = 12.0;
    usb_l = 14.0;

    term_h = 10.0;
    term_w = 10.0;
    term_l = 14.0;

    header_h = 6.0;
    header_w = 6.0;
    header_l = 22.0;

    cap_h = 12.0;
    cap_r = 4.0;

    // Keep everything as ONE connected solid:
    // - PCB is the base
    // - All components overlap into PCB by "overlap"
    union() {
        // PCB with mounting holes cut out
        color([0.0, 0.4, 0.2])
        difference() {
            rounded_plate(length, width, thickness, pcb_r);

            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(length/2 - hole_edge), sy*(width/2 - hole_edge), pcb_z])
                    cylinder(d=hole_d, h=thickness + 2, center=true);
            }
        }

        // --- Major components on top side ---
        // MCU (center-ish)
        color([0.15, 0.15, 0.15])
        translate([0, 0, top_z + mcu_h/2 - overlap])
            chip_body(22, 22, mcu_h);

        // Stepper driver blocks (4x) along one long edge
        driver_l = 18;
        driver_w = 15;
        driver_spacing = 22;
        driver_y = (width/2 - 18);
        for (i = [0:3]) {
            x = (i - 1.5) * driver_spacing;
            color([0.10, 0.10, 0.10])
            translate([x, driver_y, top_z + driver_h/2 - overlap])
                cube([driver_l, driver_w, driver_h], center=true);

            // Small heatsink nub on each driver (still connected via overlap)
            hs_h = 2.0;
            hs_l = 12;
            hs_w = 10;
            color([0.25, 0.25, 0.25])
            translate([x, driver_y, top_z + driver_h + hs_h/2 - overlap])
                cube([hs_l, hs_w, hs_h], center=true);
        }

        // USB connector on one short edge
        usb_x = -(length/2 - usb_l/2);
        usb_y = 0;
        color([0.75, 0.75, 0.78])
        translate([usb_x, usb_y, top_z + usb_h/2 - overlap])
            cube([usb_l, usb_w, usb_h], center=true);

        // Power terminal blocks (2x) on opposite short edge
        term_x = (length/2 - term_l/2);
        for (sy = [-1, 1]) {
            term_y = sy*(width*0.22);
            color([0.0, 0.35, 0.75])
            translate([term_x, term_y, top_z + term_h/2 - overlap])
                cube([term_l, term_w, term_h], center=true);
        }

        // Long pin header along bottom long edge
        hdr_y = -(width/2 - header_w/2);
        color([0.05, 0.05, 0.05])
        translate([0, hdr_y, top_z + header_h/2 - overlap])
            cube([header_l, header_w, header_h], center=true);

        // Pins protruding outward from header (still connected to header body)
        pin_h = 3.0;
        pin_l = 4.0;
        pin_w = 0.7;
        n_pins = 10;
        pitch = 2.54;
        // Place pins so they extend beyond the board edge in -Y direction
        translate([0, hdr_y - (header_w/2 + pin_l/2 - 0.2), top_z + pin_h/2 - overlap])
            color([0.85, 0.75, 0.25])
            pin_row(n=n_pins, pitch=pitch, pin_w=pin_w, pin_l=pin_l, pin_h=pin_h);

        // Electrolytic capacitor (cylinder) near power side
        cap_x = (length/2 - 28);
        cap_y = 0;
        color([0.1, 0.1, 0.1])
        translate([cap_x, cap_y, top_z + cap_h/2 - overlap])
            cylinder(r=cap_r, h=cap_h, center=true);

        // Small regulator chip near USB
        reg_h = 2.2;
        color([0.12, 0.12, 0.12])
        translate([-(length/2 - 30), 18, top_z + reg_h/2 - overlap])
            chip_body(10, 8, reg_h);

        // --- A few bottom-side features (still connected via overlap into PCB) ---
        // Bottom SMD block
        smd_h = 1.2;
        color([0.2, 0.2, 0.2])
        translate([15, -10, bottom_z - smd_h/2 + overlap])
            cube([16, 10, smd_h], center=true);

        // Bottom connector stub (kept connected by overlapping into PCB)
        bcon_h = 5.0;
        bcon_l = 16.0;
        bcon_w = 10.0;
        color([0.6, 0.6, 0.6])
        translate([-(length/2 - bcon_l/2 - 10), -(width/2 - bcon_w/2 - 12), bottom_z - bcon_h/2 + overlap])
            cube([bcon_l, bcon_w, bcon_h], center=true);
    }
}

control_board();