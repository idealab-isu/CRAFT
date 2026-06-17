$fn = 128;

// HT 40 cap (approximation)
// Dimensions in mm (typical HT DN40: OD ~ 50, wall ~ 1.8-2.0, socket depth ~ 35-40)
od = 50.0;          // outer diameter of cap body
wall = 2.0;         // wall thickness
id = od - 2*wall;   // inner diameter
cap_height = 45.0;  // total height
bottom_thickness = 3.0; // closed end thickness

// Small external lip/rim
rim_od = 54.0;
rim_height = 3.0;

// Slight internal lead-in chamfer
chamfer_h = 2.0;
chamfer_delta = 1.0;

module ht40_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(h = cap_height, d = od);

            // Outer rim at open end
            translate([0,0,cap_height - rim_height])
                cylinder(h = rim_height, d = rim_od);
        }

        // Hollow interior (open at top)
        translate([0,0,bottom_thickness])
            cylinder(h = cap_height - bottom_thickness + 0.2, d = id);

        // Internal chamfer/lead-in at opening
        translate([0,0,cap_height - chamfer_h])
            cylinder(h = chamfer_h + 0.2, d1 = id + 2*chamfer_delta, d2 = id);
    }
}

ht40_cap();