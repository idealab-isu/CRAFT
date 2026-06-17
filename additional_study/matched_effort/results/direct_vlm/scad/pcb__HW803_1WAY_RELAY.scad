$fn = 64;

// Relay module overall PCB size (mm)
length = 50.0;
width  = 26.0;
thick  = 1.6;

eps = 0.2; // small overlap to guarantee connectivity

module rounded_rect_2d(l, w, r) {
    r2 = min(r, min(l, w)/2);
    offset(r=r2) offset(delta=-r2) square([l, w], center=true);
}

module relay_module(l=length, w=width, t=thick) {

    // --- PCB ---
    pcb_r = 1.5;

    // --- Mounting holes (4-corner) ---
    hole_d = 3.2;
    hole_edge_x = 3.0;
    hole_edge_y = 3.0;
    hole_x = l/2 - hole_edge_x;
    hole_y = w/2 - hole_edge_y;

    // --- Relay body (approx) ---
    relay_l = 19.0;
    relay_w = 15.5;
    relay_h = 15.0;
    relay_x = -l/2 + 6.0 + relay_l/2; // near left side
    relay_y = 0;

    // --- Screw terminal block (approx) ---
    term_l = 15.0;
    term_w = 10.0;
    term_h = 12.0;
    term_x =  l/2 - 4.0 - term_l/2;   // near right edge
    term_y =  0;

    // --- Pin header block (approx, 3-pin) ---
    hdr_l = 8.0;
    hdr_w = 5.0;
    hdr_h = 8.0;
    hdr_x = -l/2 + 4.0 + hdr_l/2;     // near left edge
    hdr_y = -w/2 + 4.0 + hdr_w/2;     // near bottom edge

    // --- Small components (approx) ---
    comp_h = 3.0;
    comp1_l = 8.0; comp1_w = 4.0;
    comp2_l = 6.0; comp2_w = 3.5;

    comp1_x = 0;
    comp1_y =  w/2 - 5.0 - comp1_w/2;

    comp2_x =  l/2 - 18.0;
    comp2_y = -w/2 + 6.0;

    union() {
        // PCB with holes (centered in Z so orthographic views show thickness correctly)
        difference() {
            translate([0, 0, -t/2])
                linear_extrude(height=t)
                    rounded_rect_2d(l, w, pcb_r);

            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*hole_x, sy*hole_y, -t/2 - 1])
                    cylinder(d=hole_d, h=t+2);
        }

        // Place all top-side parts so their bottoms overlap slightly into the PCB top surface at z=+t/2
        translate([relay_x, relay_y, t/2 + relay_h/2 - eps])
            cube([relay_l, relay_w, relay_h], center=true);

        translate([term_x, term_y, t/2 + term_h/2 - eps])
            cube([term_l, term_w, term_h], center=true);

        translate([hdr_x, hdr_y, t/2 + hdr_h/2 - eps])
            cube([hdr_l, hdr_w, hdr_h], center=true);

        translate([comp1_x, comp1_y, t/2 + comp_h/2 - eps])
            cube([comp1_l, comp1_w, comp_h], center=true);

        translate([comp2_x, comp2_y, t/2 + comp_h/2 - eps])
            cube([comp2_l, comp2_w, comp_h], center=true);
    }
}

relay_module();