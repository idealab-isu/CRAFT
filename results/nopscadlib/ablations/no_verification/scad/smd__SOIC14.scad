// SMD body target envelope: 8.70 x 3.90 x 1.25 (L x W x H)

$fn = 48;

// Parameters
body_length = 8.70;   // X
body_width  = 3.90;   // Y
body_height = 1.25;   // Z

// Edge treatment (kept small so overall envelope remains the same)
chamfer = 0.20;       // visual edge break (must be < min dimension/2)

// Marking / pin1 (engraved, does not change outer envelope)
pin1_diameter  = 0.60;
pin1_depth     = 0.15;
marking_depth  = 0.05;
marking_margin = 0.80;

// Robust boolean overlap (small, avoids "blank" due to coplanar subtraction)
eps = 0.02;

// Base body
module smd_body() {
    cube([body_length, body_width, body_height], center=true);
}

// Chamfer cutters: remove small wedges from the 4 vertical edges
module chamfer_cutters() {
    // Make cutters long/tall enough to fully intersect the body
    cutter_y = body_width  + 2*chamfer + 2*eps;
    cutter_x = body_length + 2*chamfer + 2*eps;
    cutter_z = body_height + 2*chamfer + 2*eps;

    union() {
        // X+ edge
        translate([ body_length/2 - chamfer/2, 0, 0])
            rotate([0, 45, 0])
                cube([chamfer, cutter_y, cutter_z], center=true);

        // X- edge
        translate([-body_length/2 + chamfer/2, 0, 0])
            rotate([0,-45, 0])
                cube([chamfer, cutter_y, cutter_z], center=true);

        // Y+ edge
        translate([0, body_width/2 - chamfer/2, 0])
            rotate([45, 0, 0])
                cube([cutter_x, chamfer, cutter_z], center=true);

        // Y- edge
        translate([0,-body_width/2 + chamfer/2, 0])
            rotate([-45, 0, 0])
                cube([cutter_x, chamfer, cutter_z], center=true);
    }
}

// Top marking recess (engraved)
module top_marking_cut() {
    marking_l = max(0.01, body_length - 2*marking_margin);
    marking_w = max(0.01, body_width  - 2*marking_margin);

    translate([0, 0, body_height/2 - marking_depth/2 + eps/2])
        cube([marking_l, marking_w, marking_depth + eps], center=true);
}

// Pin1 indicator recess (engraved)
module pin1_indicator_cut() {
    translate([
        -body_length/2 + marking_margin,
         body_width/2  - marking_margin,
         body_height/2 - pin1_depth/2 + eps/2
    ])
        cylinder(h=pin1_depth + eps, r=pin1_diameter/2, center=true);
}

// Final connected solid
difference() {
    // Outer envelope exactly matches target dimensions
    smd_body();

    // Subtractions only (do not add external bars/features)
    chamfer_cutters();
    top_marking_cut();
    pin1_indicator_cut();
}