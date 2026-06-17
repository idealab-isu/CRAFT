// Hex head screw (connected solid) with cylindrical shank + simple helical thread
// Target dimensions:
// - Shank major diameter: 4.0 mm
// - Head across flats: 8.1 mm
// - Head height: 2.925 mm
// - Under-head length: 10.0 mm

$fn = 96;

// Parameters
shaft_diameter = 4.0;          // major diameter
shaft_length   = 10.0;         // under-head length
head_af        = 8.1;          // across flats
head_height    = 2.925;

// Simple thread approximation (visual)
thread_pitch   = 0.7;          // mm (approx for M4)
thread_depth   = 0.25;         // mm radial depth (kept small)
thread_starts  = 1;

// Derived
shaft_r = shaft_diameter/2;
head_R  = head_af / sqrt(3);   // cylinder(d=2*R, $fn=6) gives across-flats = sqrt(3)*R

module hex_head() {
    // Head sits on top of shank; slight overlap ensures watertight union
    overlap = 0.05;
    translate([0,0,shaft_length - overlap])
        cylinder(h=head_height + overlap, r=head_R, $fn=6);
}

module threaded_shank() {
    // Core cylinder slightly under major diameter so thread ridge defines major OD
    core_r = max(0.01, shaft_r - thread_depth);

    union() {
        // Core
        cylinder(h=shaft_length, r=core_r);

        // Helical ridge (approx thread)
        // Use linear_extrude with twist; place a thin rectangular ridge at radius core_r
        turns = shaft_length / thread_pitch;
        for (s = [0:thread_starts-1]) {
            rotate([0,0, s*360/thread_starts])
                linear_extrude(height=shaft_length, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
                    translate([core_r, 0, 0])
                        square([thread_depth, thread_pitch*0.45], center=true);
        }
    }
}

module screw() {
    union() {
        threaded_shank();
        hex_head();
    }
}

screw();