// Miniature linear guide rail (MGN9-style approximation)
// Target overall size: 9.0mm wide (X) x 6.0mm tall (Z) x 100mm long (Y)

// ---------- Parameters ----------
rail_width_mm  = 9.0;    //[4.5:18.0:0.1]
rail_height_mm = 6.0;    //[3.0:12.0:0.1]
rail_length_mm = 100.0;  //[50.0:200.0:1]

mounting_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
mounting_hole_count = 4;         //[2:10:1]
mounting_hole_end_offset_mm = 10.0; //[5.0:20.0:0.5]

// Countersink (simple conical)
countersink_top_diameter_mm = 5.6; //[4.0:7.0:0.1]
countersink_depth_mm = 1.6;        //[0.8:2.5:0.1]

// Raceway/groove approximation (two side grooves)
groove_radius_mm = 1.0;     //[0.5:1.5:0.05]
groove_depth_mm  = 0.7;     //[0.3:1.2:0.05]
groove_z_mm = 0.0;          // centered vertically

// Edge chamfer approximation (small bevels)
chamfer_mm = 0.35; //[0.0:1.0:0.05]

// Robust boolean overlap
eps = 0.02;

// ---------- Derived ----------
mounting_hole_spacing_mm =
    (mounting_hole_count > 1)
    ? (rail_length_mm - 2*mounting_hole_end_offset_mm) / (mounting_hole_count - 1)
    : 0;

// Keep features valid for small parameter changes
cs_depth = min(countersink_depth_mm, rail_height_mm/2 - eps);
cs_top_r = countersink_top_diameter_mm/2;
hole_r   = mounting_hole_diameter_mm/2;

// Groove placement: keep within side walls
groove_center_x = rail_width_mm/2 - groove_depth_mm - groove_radius_mm;
groove_center_x_safe = max(groove_radius_mm + eps, groove_center_x);

// ---------- Modules ----------
module rail_blank() {
    // Base solid: exact overall dimensions
    cube([rail_width_mm, rail_length_mm, rail_height_mm], center=true);
}

module mounting_holes_and_countersinks() {
    for (i = [0:mounting_hole_count-1]) {
        y = -rail_length_mm/2 + mounting_hole_end_offset_mm + i*mounting_hole_spacing_mm;

        // Through hole (along Z)
        translate([0, y, 0])
            cylinder(h=rail_height_mm + 2*(eps+1), r=hole_r, center=true, $fn=48);

        // Top countersink (conical frustum)
        // Positioned so its top is flush with rail top surface
        translate([0, y, rail_height_mm/2 - cs_depth/2 + eps])
            cylinder(h=cs_depth + 2*eps, r1=cs_top_r, r2=hole_r, center=true, $fn=64);
    }
}

module side_raceway_grooves() {
    // Two long grooves along Y, approximated by subtracting cylinders oriented along Y.
    // They cut into the sides by groove_depth_mm.
    for (sx = [-1, 1]) {
        translate([sx*groove_center_x_safe, 0, groove_z_mm])
            rotate([90, 0, 0])  // make cylinder axis along Y
                cylinder(h=rail_length_mm + 2*(eps+1), r=groove_radius_mm, center=true, $fn=64);
    }
}

module edge_chamfers() {
    // Subtract small wedges along the four long edges to suggest chamfering.
    // Implemented as rotated long rectangular prisms that intersect the edges.
    if (chamfer_mm > 0) {
        // Top edges
        translate([ rail_width_mm/2 - chamfer_mm/2, 0,  rail_height_mm/2 - chamfer_mm/2])
            rotate([0, 45, 0])
                cube([chamfer_mm, rail_length_mm + 2*(eps+1), chamfer_mm], center=true);

        translate([-rail_width_mm/2 + chamfer_mm/2, 0,  rail_height_mm/2 - chamfer_mm/2])
            rotate([0,-45, 0])
                cube([chamfer_mm, rail_length_mm + 2*(eps+1), chamfer_mm], center=true);

        // Bottom edges
        translate([ rail_width_mm/2 - chamfer_mm/2, 0, -rail_height_mm/2 + chamfer_mm/2])
            rotate([0,-45, 0])
                cube([chamfer_mm, rail_length_mm + 2*(eps+1), chamfer_mm], center=true);

        translate([-rail_width_mm/2 + chamfer_mm/2, 0, -rail_height_mm/2 + chamfer_mm/2])
            rotate([0, 45, 0])
                cube([chamfer_mm, rail_length_mm + 2*(eps+1), chamfer_mm], center=true);
    }
}

module rail() {
    // ONE connected solid: base minus connected cut features
    difference() {
        rail_blank();
        mounting_holes_and_countersinks();
        side_raceway_grooves();
        edge_chamfers();
    }
}

// ---------- Build ----------
rail();