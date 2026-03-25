$fn = 64;

// Board dimensions (mm)
length = 78.0;
width  = 47.0;
thickness = 1.6;

// Overlap to guarantee connectivity between parts (1–2mm as required)
overlap = 1.0;

// ---------- Helpers ----------
module rounded_plate(l, w, h, r) {
    // Rounded rectangle prism using hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r), 0])
                cylinder(r=r, h=h, center=true);
    }
}

module chip_body(l, w, h) {
    cube([l, w, h], center=true);
}

module pin_row(n=6, pitch=2.54, pin_w=0.6, pin_l=3.0, pin_h=1.2) {
    // Simple rectangular pins in a row, centered about origin in X
    for (i = [0:n-1]) {
        translate([(i-(n-1)/2)*pitch, 0, 0])
            cube([pin_w, pin_l, pin_h], center=true);
    }
}

module terminal_block(block_l, block_w, block_h, pin_n=3, pin_pitch=5.0) {
    // Block with pins protruding downward (connected via overlap)
    union() {
        cube([block_l, block_w, block_h], center=true);

        // Pins: placed along X, near the inner edge of the block
        pin_w = 1.0;
        pin_l = 2.0;
        pin_h = 3.0;
        for (i = [0:pin_n-1]) {
            translate([(i-(pin_n-1)/2)*pin_pitch, 0, -(block_h/2 + pin_h/2 - overlap)])
                cube([pin_w, pin_l, pin_h], center=true);
        }
    }
}

module inductor(r=7.5, h=6.0) {
    // Simple drum inductor
    union() {
        cylinder(r=r, h=h, center=true);
        // Slight top cap
        translate([0,0,h/2 - 0.6])
            cylinder(r=r*0.92, h=1.2, center=true);
    }
}

module electrolytic_cap(r=4.0, h=10.0) {
    union() {
        cylinder(r=r, h=h, center=true);
        translate([0,0,h/2 - 0.5])
            cylinder(r=r*0.95, h=1.0, center=true);
    }
}

module standoff(r=2.8, h=3.0, hole_r=1.6) {
    difference() {
        cylinder(r=r, h=h, center=true);
        cylinder(r=hole_r, h=h+1, center=true);
    }
}

// Three small pins/legs near center (ensure they are ATTACHED, not floating)
module center_legs(pin_n=3, pin_pitch=2.0, pin_w=0.8, pin_l=1.6, pin_h=2.0) {
    // Oriented so "pin_l" runs along Y, row along X
    for (i = [0:pin_n-1]) {
        translate([(i-(pin_n-1)/2)*pin_pitch, 0, 0])
            cube([pin_w, pin_l, pin_h], center=true);
    }
}

// ---------- Main model ----------
module dcdc_module() {
    pcb_r = 2.5;

    top_z = thickness/2;

    // Terminal blocks
    term_h = 10.0;
    term_w = 10.0;
    term_l = 16.0;

    // Place terminal blocks along the two short edges (width direction)
    term_y = width/2 - term_w/2;

    // Inductor
    ind_r = 7.5;
    ind_h = 6.0;

    // Heatsink-ish block (power IC)
    hs_l = 18.0;
    hs_w = 14.0;
    hs_h = 8.0;

    // Small IC
    ic_l = 10.0;
    ic_w = 8.0;
    ic_h = 2.0;

    // Capacitors
    cap_r = 4.0;
    cap_h = 10.0;

    // Mounting holes/standoffs near corners
    hole_off_x = 5.0;
    hole_off_y = 5.0;
    st_h = 3.0;

    // Center legs (the previously floating/disconnected feature)
    leg_n = 3;
    leg_pitch = 2.0;
    leg_w = 0.8;
    leg_l = 1.6;
    leg_h = 2.0;

    // Place legs near center, under the controller IC area (as seen in views)
    legs_x = 0;
    legs_y = -width*0.02;

    union() {
        // PCB (centered at origin, thickness centered on Z=0)
        color([0.0, 0.4, 0.2])
            rounded_plate(length, width, thickness, pcb_r);

        // Standoffs (connected to PCB with overlap)
        color([0.1, 0.1, 0.1])
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(length/2 - hole_off_x), sy*(width/2 - hole_off_y),
                       top_z + st_h/2 - overlap])
                standoff(r=2.8, h=st_h, hole_r=1.6);
        }

        // Terminal blocks on both short edges (connected to PCB)
        color([0.15, 0.15, 0.15]) {
            // Top edge (+Y)
            translate([0, term_y, top_z + term_h/2 - overlap])
                terminal_block(term_l, term_w, term_h, pin_n=3, pin_pitch=5.0);

            // Bottom edge (-Y)
            translate([0, -term_y, top_z + term_h/2 - overlap])
                terminal_block(term_l, term_w, term_h, pin_n=3, pin_pitch=5.0);
        }

        // Inductor (connected)
        color([0.2, 0.2, 0.2])
            translate([-(length*0.18), 0, top_z + ind_h/2 - overlap])
                inductor(r=ind_r, h=ind_h);

        // Heatsink/power stage block (connected)
        color([0.25, 0.25, 0.25])
            translate([length*0.18, 0, top_z + hs_h/2 - overlap])
                chip_body(hs_l, hs_w, hs_h);

        // Small controller IC with pins (connected)
        color([0.05, 0.05, 0.05]) {
            ic_z = top_z + ic_h/2 - overlap;
            ic_x = 0;
            ic_y = -width*0.18;

            translate([ic_x, ic_y, ic_z])
                chip_body(ic_l, ic_w, ic_h);

            // Pins on two sides (connected via overlap into body)
            pin_h = 1.0;
            pin_z = top_z + pin_h/2 - overlap;

            // Left side pins
            translate([ic_x, ic_y - (ic_w/2 + 1.2/2 - overlap), pin_z])
                rotate([0,0,90])
                    pin_row(n=6, pitch=1.27, pin_w=0.5, pin_l=1.2, pin_h=pin_h);

            // Right side pins
            translate([ic_x, ic_y + (ic_w/2 + 1.2/2 - overlap), pin_z])
                rotate([0,0,90])
                    pin_row(n=6, pitch=1.27, pin_w=0.5, pin_l=1.2, pin_h=pin_h);
        }

        // --- FIX: Add/attach the three small center pins/legs (no floating, no gap) ---
        // These legs are modeled as through-hole style pins that:
        // 1) overlap into the PCB by 'overlap'
        // 2) extend below the PCB (visible in bottom view)
        // 3) also overlap slightly upward to ensure union robustness
        color([0.05, 0.05, 0.05]) {
            // Center the legs so their top is slightly inside the PCB (guaranteed connection)
            // PCB top surface is at +top_z. Set leg center so leg top = top_z - overlap.
            legs_z = (top_z - overlap) - leg_h/2;

            translate([legs_x, legs_y, legs_z])
                center_legs(pin_n=leg_n, pin_pitch=leg_pitch, pin_w=leg_w, pin_l=leg_l, pin_h=leg_h);
        }

        // Capacitors (connected)
        color([0.1, 0.1, 0.1]) {
            translate([length*0.30, width*0.18, top_z + cap_h/2 - overlap])
                electrolytic_cap(r=cap_r, h=cap_h);
            translate([length*0.30, -width*0.18, top_z + cap_h/2 - overlap])
                electrolytic_cap(r=cap_r, h=cap_h);
        }

        // A couple of small SMD blocks (connected)
        color([0.12, 0.12, 0.12]) {
            smd_h = 1.2;
            translate([-length*0.05, width*0.18, top_z + smd_h/2 - overlap])
                cube([8, 5, smd_h], center=true);
            translate([-length*0.05, -width*0.30, top_z + smd_h/2 - overlap])
                cube([6, 4, smd_h], center=true);
        }
    }
}

dcdc_module();