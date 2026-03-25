// Miniature linear guide rail (MGN7-style) — 7mm wide, 5mm tall, 100mm long
// One connected solid (holes are subtracted). All placements are formula-based.

rail_width_mm  = 7.0;    //[3.5:14.0:0.1]
rail_height_mm = 5.0;    //[2.5:10.0:0.1]
rail_length_mm = 100.0;  //[50.0:200.0:1]

mounting_holes_included      = 1;    //[0:1:1]
mounting_hole_diameter_mm    = 2.0;  //[1.0:4.0:0.1]
mounting_hole_spacing_mm     = 20.0; //[10.0:40.0:1]
mounting_hole_count          = 5;    //[2:10:1]
mounting_hole_countersink_mm = 3.6;  //[2.5:6.0:0.1]
countersink_depth_mm         = 1.2;  //[0.5:2.5:0.1]

edge_treatment   = 1;    //[0:1:1]  // 0 none, 1 chamfer
edge_chamfer_mm  = 0.4;  //[0.2:1.5:0.1]

overlap_mm           = 0.2; //[0.05:1.0:0.05]
hole_depth_extra_mm  = 2.0; //[1.0:5.0:0.5]

// Detail proportions (kept within 7x5 envelope)
raceway_depth_mm    = 0.7;  // side groove depth into rail
raceway_height_mm   = 2.2;  // vertical size of groove
raceway_z_center_mm = 0.0;  // centered vertically

$fn = 64;

// Utility
function clamp(x, a, b) = min(max(x, a), b);
function usable_span(L, margin) = max(0, L - 2*margin);
function actual_spacing(L, margin, desired, n) =
    (n <= 1) ? 0 : min(desired, usable_span(L, margin)/(n-1));

module rail_body() {
    // Ensure the rail is oriented along X (length), Y (width), Z (height)
    cube([rail_length_mm, rail_width_mm, rail_height_mm], center=true);
}

module side_raceways_cut() {
    // Two long side grooves along the length (X axis), cut into the Y side faces.
    groove_len = rail_length_mm + 2*overlap_mm;

    gh = min(raceway_height_mm, rail_height_mm - 2*min(edge_chamfer_mm, rail_height_mm/3));
    gd = min(raceway_depth_mm, rail_width_mm/2 - 0.6);

    // Groove center Y is at side face minus half depth (with slight overlap)
    y_center = rail_width_mm/2 - gd/2 + overlap_mm/2;

    for (sy = [-1, 1]) {
        translate([0, sy * y_center, raceway_z_center_mm])
            cube([groove_len, gd + overlap_mm, gh], center=true);
    }
}

module long_edge_chamfers_cut() {
    // Chamfer the four long edges (along X) by subtracting 45° rotated cutters.
    c = min(edge_chamfer_mm, min(rail_width_mm, rail_height_mm)/3);
    cutter_len = rail_length_mm + 2*overlap_mm;

    // Use a square cutter rotated 45° about X so it chamfers Y-Z edges along X.
    cutter_y = 2*c;
    cutter_z = 2*c;

    // Top-right ( +Y, +Z )
    translate([0,
               rail_width_mm/2  - c + overlap_mm/2,
               rail_height_mm/2 - c + overlap_mm/2])
        rotate([45, 0, 0])
            cube([cutter_len, cutter_y, cutter_z], center=true);

    // Top-left ( -Y, +Z )
    translate([0,
              -rail_width_mm/2 + c - overlap_mm/2,
               rail_height_mm/2 - c + overlap_mm/2])
        rotate([-45, 0, 0])
            cube([cutter_len, cutter_y, cutter_z], center=true);

    // Bottom-right ( +Y, -Z )
    translate([0,
               rail_width_mm/2  - c + overlap_mm/2,
              -rail_height_mm/2 + c - overlap_mm/2])
        rotate([-45, 0, 0])
            cube([cutter_len, cutter_y, cutter_z], center=true);

    // Bottom-left ( -Y, -Z )
    translate([0,
              -rail_width_mm/2 + c - overlap_mm/2,
              -rail_height_mm/2 + c - overlap_mm/2])
        rotate([45, 0, 0])
            cube([cutter_len, cutter_y, cutter_z], center=true);
}

module mounting_holes_cut() {
    // Through holes along the length (X axis), drilled along Z.
    // Includes shallow countersink on the top face.
    n = max(2, mounting_hole_count);

    // Keep holes away from ends; ensure margin is valid for short rails
    margin_x_nom = max(mounting_hole_diameter_mm*1.2, 6);
    margin_x = clamp(margin_x_nom, 0, rail_length_mm/2 - mounting_hole_diameter_mm);

    span = usable_span(rail_length_mm, margin_x);
    sp = actual_spacing(rail_length_mm, margin_x, mounting_hole_spacing_mm, n);

    for (i = [0:n-1]) {
        x = (n==1) ? 0 : (-span/2 + i*sp);

        // Through hole
        translate([x, 0, 0])
            cylinder(d=mounting_hole_diameter_mm,
                     h=rail_height_mm + hole_depth_extra_mm,
                     center=true);

        // Countersink (top)
        cs_d = max(mounting_hole_diameter_mm, mounting_hole_countersink_mm);
        cs_h = min(countersink_depth_mm, rail_height_mm/2);

        translate([x, 0, rail_height_mm/2 - cs_h/2 + overlap_mm/2])
            cylinder(d1=cs_d, d2=mounting_hole_diameter_mm,
                     h=cs_h + overlap_mm,
                     center=true);
    }
}

module MGN7_rail() {
    color("DimGray")
    difference() {
        rail_body();

        side_raceways_cut();

        if (edge_treatment == 1)
            long_edge_chamfers_cut();

        if (mounting_holes_included)
            mounting_holes_cut();
    }
}

MGN7_rail();