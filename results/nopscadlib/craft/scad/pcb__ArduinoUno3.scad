$fn = 64;

// Board dimensions (requested)
pcb_length = 68.58;
pcb_width  = 53.34;
pcb_thickness = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.2;

// ---------- Helpers ----------
module rounded_rect_prism(l, w, h, r, center=true) {
    // Rounded rectangle prism using hull of corner cylinders
    translate(center ? [0,0,0] : [l/2, w/2, h/2])
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r), 0])
                cylinder(r=r, h=h, center=true);
    }
}

module hole_at(x, y, d, h) {
    translate([x, y, 0]) cylinder(d=d, h=h, center=true);
}

// ---------- Model ----------
module dev_board() {
    // Feature sizes (generic dev board look)
    corner_r = 3.0;

    // Mounting holes (generic 4-corner pattern)
    hole_d = 3.2;
    hole_edge_x = 4.0;
    hole_edge_y = 4.0;

    // Header rails (two long pin headers)
    header_w = 5.0;
    header_h = 8.5;
    header_inset = 2.2; // from PCB edge to header outer edge

    // Central MCU package
    mcu_l = 18.0;
    mcu_w = 18.0;
    mcu_h = 2.2;

    // USB connector (side-mounted)
    usb_w = 12.0;   // along Y
    usb_l = 8.0;    // protrusion along X
    usb_h = 4.0;

    // Power jack / large connector (opposite side, generic)
    jack_w = 10.0;  // along Y
    jack_l = 12.0;  // protrusion along X
    jack_h = 6.0;

    // A couple of small components (caps/regulators)
    comp1 = [8.0, 6.0, 2.5];
    comp2 = [6.0, 6.0, 2.0];
    comp3 = [10.0, 4.0, 2.0];

    union() {
        // PCB with mounting holes (holes are subtracted but model remains one connected solid)
        color([0.0, 0.4, 0.2])
        difference() {
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r, center=true);

            // 4 mounting holes near corners
            for (sx = [-1, 1], sy = [-1, 1]) {
                hole_at(
                    sx*(pcb_length/2 - hole_edge_x),
                    sy*(pcb_width/2  - hole_edge_y),
                    hole_d,
                    pcb_thickness + 2*ov
                );
            }
        }

        // Two long header blocks on top side (connected to PCB with slight overlap)
        color([0.1, 0.1, 0.1])
        for (sy = [-1, 1]) {
            translate([
                0,
                sy*(pcb_width/2 - header_inset - header_w/2),
                pcb_thickness/2 + header_h/2 - ov
            ])
                cube([pcb_length - 10.0, header_w, header_h], center=true);
        }

        // MCU package centered
        color([0.15, 0.15, 0.15])
        translate([0, 0, pcb_thickness/2 + mcu_h/2 - ov])
            cube([mcu_l, mcu_w, mcu_h], center=true);

        // USB connector on +X edge, centered in Y
        color([0.75, 0.75, 0.75])
        translate([
            pcb_length/2 + usb_l/2 - ov,
            0,
            pcb_thickness/2 + usb_h/2 - ov
        ])
            cube([usb_l, usb_w, usb_h], center=true);

        // Large jack on -X edge, offset in Y
        color([0.2, 0.2, 0.2])
        translate([
            -(pcb_length/2 + jack_l/2 - ov),
            pcb_width*0.22,
            pcb_thickness/2 + jack_h/2 - ov
        ])
            cube([jack_l, jack_w, jack_h], center=true);

        // A few small components (top side), placed with formula-based offsets
        color([0.25, 0.25, 0.25])
        translate([
            pcb_length*0.18,
            -(pcb_width*0.18),
            pcb_thickness/2 + comp1[2]/2 - ov
        ])
            cube(comp1, center=true);

        color([0.25, 0.25, 0.25])
        translate([
            -(pcb_length*0.22),
            -(pcb_width*0.10),
            pcb_thickness/2 + comp2[2]/2 - ov
        ])
            cube(comp2, center=true);

        color([0.25, 0.25, 0.25])
        translate([
            pcb_length*0.05,
            pcb_width*0.28,
            pcb_thickness/2 + comp3[2]/2 - ov
        ])
            cube(comp3, center=true);
    }
}

dev_board();