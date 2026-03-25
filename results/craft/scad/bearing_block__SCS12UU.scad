// Linear bearing block for 8.0mm shaft
// Block size: 42.0mm x 36.0mm x 28.0mm
// One connected solid (single part) with through shaft bore, bearing pocket, and 4 mounting holes.

$fn = 128;

// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
block_length_mm = 42; //[21:84:0.5]   // X
block_width_mm  = 36; //[18:72:0.5]   // Y
block_height_mm = 28; //[14:56:0.5]   // Z

bearing_outer_diameter_mm = 15; //[10:30:0.1]
bearing_length_mm = 24; //[12:48:0.5]
bearing_fit_clearance_mm = 0.2; //[0:0.6:0.05]
shaft_clearance_mm = 0.3; //[0:0.8:0.05]

mounting_hole_diameter_mm = 5; //[3:8:0.1]
mounting_hole_spacing_x_mm = 30; //[18:38:0.5]
mounting_hole_spacing_y_mm = 24; //[16:32:0.5]

edge_chamfer_mm = 1.5; //[0:4:0.1]
op_overlap_mm = 1; //[0.5:2:0.1]

// Derived
bearing_seat_r = (bearing_outer_diameter_mm + bearing_fit_clearance_mm)/2;
shaft_r        = (shaft_diameter_mm + shaft_clearance_mm)/2;

// Keep some wall thickness around the bearing seat
min_wall_mm = 2.0;
seat_len = min(bearing_length_mm, block_length_mm - 2*min_wall_mm);

// Chamfered block (hull of corner posts)
module chamfered_block(L, W, H, c) {
  c2 = max(0, min(c, min(L, W)/4));
  hull() {
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*(L/2 - c2), sy*(W/2 - c2), 0])
        cube([2*c2, 2*c2, H], center=true);
    }
  }
}

module linear_bearing_block_8mm() {
  difference() {
    // Main body
    chamfered_block(block_length_mm, block_width_mm, block_height_mm, edge_chamfer_mm);

    // Shaft through-bore (X axis, full length)
    rotate([0, 90, 0])
      cylinder(r=shaft_r, h=block_length_mm + 2*op_overlap_mm, center=true);

    // Bearing seat pocket (X axis, limited length, centered)
    // NOTE: subtract AFTER shaft bore so it is visible as a larger counterbore region.
    rotate([0, 90, 0])
      cylinder(r=bearing_seat_r, h=seat_len + 2*op_overlap_mm, center=true);

    // Mounting holes (Z axis, through)
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*mounting_hole_spacing_x_mm/2,
                 sy*mounting_hole_spacing_y_mm/2,
                 0])
        cylinder(r=mounting_hole_diameter_mm/2,
                 h=block_height_mm + 2*op_overlap_mm,
                 center=true);
    }
  }
}

linear_bearing_block_8mm();