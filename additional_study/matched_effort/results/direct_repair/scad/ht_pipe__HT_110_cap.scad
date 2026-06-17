$fn = 180;

// HT 110 cap (approximation)
// Dimensions in mm
id_nominal = 110;          // nominal pipe OD
pipe_od = 110.0;           // mating pipe outer diameter
clearance = 0.6;           // radial clearance for slip fit
wall = 3.2;                // cap wall thickness
bottom_th = 4.0;           // closed-end thickness
insert_depth = 35.0;       // depth of socket
outer_lip = 6.0;           // extra radial thickness at rim
rim_height = 10.0;         // height of thickened rim
chamfer_h = 2.0;           // lead-in chamfer height
chamfer_extra = 1.2;       // chamfer radial extra

// Derived
inner_d = pipe_od + 2*clearance;
outer_d = inner_d + 2*wall;
outer_d_rim = outer_d + 2*outer_lip;
total_h = bottom_th + insert_depth + rim_height;

module ht110_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(h = total_h, d = outer_d);

            // Thickened rim
            translate([0,0,total_h - rim_height])
                cylinder(h = rim_height, d = outer_d_rim);

            // Small outer rounding at top edge (simple torus-like via hull)
            translate([0,0,total_h - 0.8])
                hull() {
                    cylinder(h=0.8, d=outer_d_rim);
                    translate([0,0,0.8])
                        cylinder(h=0.01, d=outer_d_rim - 1.2);
                }
        }

        // Inner cavity (socket)
        translate([0,0,bottom_th])
            cylinder(h = total_h - bottom_th + 0.2, d = inner_d);

        // Lead-in chamfer at opening
        translate([0,0,total_h - chamfer_h])
            cylinder(h = chamfer_h + 0.2, d1 = inner_d + 2*chamfer_extra, d2 = inner_d);

        // Slight inner relief near bottom to avoid sharp corner
        translate([0,0,bottom_th - 0.01])
            cylinder(h = 1.2, d1 = inner_d - 1.0, d2 = inner_d);

        // Optional outer chamfer at bottom edge
        cylinder(h = 1.2, d1 = outer_d - 1.0, d2 = outer_d + 0.6);
    }
}

ht110_cap();