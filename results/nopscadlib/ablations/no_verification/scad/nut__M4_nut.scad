// Hex nut for 4.0mm screws, 8.1mm across flats, 3.2mm thick
thread_diameter = 4.0;          // mm
across_flats    = 8.1;          // mm
thickness       = 3.2;          // mm

// Printing/fit controls
hole_clearance  = 0.4;          // mm added to diameter (clearance hole)
eps             = 0.02;         // small overlap for robust boolean ops

// Optional washer (kept disabled to ensure single connected solid by default)
washer_enabled        = 0;      // 0/1
washer_outer_diameter = 9.0;    // mm
washer_thickness      = 0.8;    // mm
washer_overlap        = 0.6;    // mm overlap into nut to guarantee connection if enabled

$fn = 96;

// Derived
hex_R = across_flats / (2 * cos(30));                 // circumradius for $fn=6 cylinder
hole_d = thread_diameter + hole_clearance;            // clearance hole diameter
hole_r = hole_d / 2;

module hex_nut_body() {
    difference() {
        // Hex prism
        cylinder(r = hex_R, h = thickness, center = true, $fn = 6);

        // Through-hole (extend beyond thickness to ensure clean cut)
        cylinder(r = hole_r, h = thickness + 2*eps, center = true, $fn = 96);
    }
}

module washer_body() {
    difference() {
        cylinder(r = washer_outer_diameter/2, h = washer_thickness, center = true, $fn = 128);
        cylinder(r = hole_r, h = washer_thickness + 2*eps, center = true, $fn = 96);
    }
}

module assembly() {
    if (washer_enabled) {
        union() {
            hex_nut_body();
            // Place washer directly under nut with calculated overlap to ensure connectivity
            translate([0, 0, -(thickness/2 + washer_thickness/2 - washer_overlap)])
                washer_body();
        }
    } else {
        hex_nut_body();
    }
}

assembly();