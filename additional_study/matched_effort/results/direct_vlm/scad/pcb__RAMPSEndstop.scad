$fn = 64;

// PCB dimensions (mm)
pcb_length = 40.0;
pcb_width  = 16.0;
pcb_thick  = 1.6;

// Visual detail thicknesses (kept small, but non-zero)
copper_t   = 0.08;
silk_t     = 0.05;

// Edge rounding (small fillet-like via hull of corner posts)
corner_r   = 0.8;

// Hole parameters
hole_d     = 2.2;
hole_edge  = 2.0; // distance from each edge to hole center

// Small overlap to guarantee connectivity between added surface details and board
overlap    = 0.02;

module rounded_plate(L, W, T, r) {
    // One connected solid, centered at origin
    hull() {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - r), sy*(W/2 - r), 0])
                cylinder(h=T, r=r, center=true);
        }
    }
}

module pcb_with_details(L, W, T) {
    difference() {
        union() {
            // FR4 board
            color([0.05, 0.45, 0.18])
                rounded_plate(L, W, T, corner_r);

            // Top copper traces (raised)
            color([0.80, 0.45, 0.10])
            translate([0, 0, T/2 + copper_t/2 - overlap])
            union() {
                // Main bus
                cube([L*0.78, W*0.12, copper_t], center=true);

                // A few branches (all connected to the bus)
                translate([-L*0.18,  W*0.18, 0]) cube([L*0.22, W*0.08, copper_t], center=true);
                translate([ 0,       -W*0.18, 0]) cube([L*0.30, W*0.08, copper_t], center=true);
                translate([ L*0.22,  W*0.10, 0]) cube([L*0.18, W*0.08, copper_t], center=true);

                // Small pads connected to traces
                translate([-L*0.30,  W*0.18, 0]) cylinder(h=copper_t, r=W*0.06, center=true);
                translate([ L*0.30,  W*0.10, 0]) cylinder(h=copper_t, r=W*0.06, center=true);
                translate([ 0,      -W*0.18, 0]) cylinder(h=copper_t, r=W*0.06, center=true);
            }

            // Top silkscreen (raised)
            color([0.95, 0.95, 0.95])
            translate([0, 0, T/2 + silk_t/2 - overlap])
            union() {
                // Border line near edge
                difference() {
                    cube([L*0.92, W*0.80, silk_t], center=true);
                    cube([L*0.88, W*0.76, silk_t + 2*overlap], center=true);
                }
                // A small "component outline" rectangle
                translate([L*0.18, 0, 0])
                difference() {
                    cube([L*0.28, W*0.40, silk_t], center=true);
                    cube([L*0.24, W*0.36, silk_t + 2*overlap], center=true);
                }
            }
        }

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - hole_edge), sy*(W/2 - hole_edge), 0])
                cylinder(h=T + 2*(copper_t + silk_t + 1), d=hole_d, center=true);
        }
    }
}

pcb_with_details(pcb_length, pcb_width, pcb_thick);