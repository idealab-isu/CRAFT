$fn = 128;

// HT 75 cap (approximation)
// Dimensions in mm
d_outer = 75;          // nominal outer diameter
wall   = 2.7;          // wall thickness
cap_depth = 45;        // insertion depth
top_thickness = 4;     // closed end thickness

// Small lead-in chamfer
chamfer_h = 1.2;
chamfer_delta = 1.0;

// External grip ring
ring_h = 6;
ring_over = 2.0;       // radial overbuild beyond outer diameter
ring_z = 10;           // distance from open end

// Internal stop lip (optional)
lip_h = 2.0;
lip_th = 1.2;          // radial thickness inward
lip_z = cap_depth - 10;

module ht75_cap() {
    difference() {
        union() {
            // Main outer body (closed end)
            cylinder(h = cap_depth + top_thickness, d = d_outer);

            // External grip ring
            translate([0,0,ring_z])
                cylinder(h = ring_h, d = d_outer + 2*ring_over);

            // Small outer chamfer at open end
            cylinder(h = chamfer_h, d1 = d_outer + 2*chamfer_delta, d2 = d_outer);
        }

        // Hollow interior (leave top_thickness)
        translate([0,0,0])
            cylinder(h = cap_depth, d = d_outer - 2*wall);

        // Inner lead-in chamfer
        translate([0,0,0])
            cylinder(h = chamfer_h, d1 = (d_outer - 2*wall), d2 = (d_outer - 2*wall) + 2*chamfer_delta);

        // Optional internal stop lip (creates a slight restriction)
        translate([0,0,lip_z])
            cylinder(h = lip_h, d = (d_outer - 2*wall) - 2*lip_th);
    }
}

ht75_cap();