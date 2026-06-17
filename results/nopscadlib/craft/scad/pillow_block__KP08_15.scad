// Parameters
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
base_length_mm = 55.0; //[27.5:110.0:0.5]
base_width_mm = 42.0; //[21.0:84.0:0.5]
mounting_hole_diameter_mm = 6.5; //[3.0:10.0:0.1]
mounting_hole_center_spacing_mm = 42.0; //[25.0:80.0:0.5]
base_thickness_mm = 8.0; //[4.0:16.0:0.5]
overall_height_mm = 28.0; //[18.0:56.0:0.5]
housing_outer_diameter_mm = 28.0; //[18.0:56.0:0.5]
seat_height_mm = 6.0; //[3.0:12.0:0.5]
seat_diameter_mm = 22.0; //[14.0:40.0:0.5]
housing_length_y_mm = 18.0; //[10.0:36.0:0.5]
bore_clearance_mm = 0.2; //[0.0:0.6:0.05]
hole_edge_margin_x_mm = 6.5; //[4.0:12.0:0.5]
hole_offset_from_front_mm = 10.0; //[6.0:18.0:0.5]
trapezoid_height_mm = 10.0; //[6.0:20.0:0.5]
trapezoid_base_y_mm = 14.0; //[8.0:28.0:0.5]
trapezoid_top_y_mm = 6.0; //[3.0:18.0:0.5]
gusset_thickness_x_mm = 6.0; //[3.0:12.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// ---------- Helpers / derived Z positions (centered solids) ----------
base_top_z = base_thickness_mm/2;

// Seat sits on base with overlap into base
seat_center_z = base_top_z + seat_height_mm/2 - overlap_mm;

// Housing (circular ring) must intersect the seat (and thus the base) by overlap_mm
// Seat top surface Z:
seat_top_z = seat_center_z + seat_height_mm/2;
// Place housing so its bottom is overlap_mm below seat top:
housing_center_z = (seat_top_z - overlap_mm) + housing_outer_diameter_mm/2;

// Right Trapezoid
module right_trapezoid() {
  linear_extrude(height=gusset_thickness_x_mm, center=true) {
    polygon(points=[
      [0, 0],
      [trapezoid_base_y_mm, 0],
      [trapezoid_top_y_mm, trapezoid_height_mm],
      [0, trapezoid_height_mm]
    ]);
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  translate([mounting_hole_center_spacing_mm/2, base_width_mm/2 - hole_offset_from_front_mm, 0])
    cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
  mirror([1, 0, 0]) {
    translate([mounting_hole_center_spacing_mm/2, base_width_mm/2 - hole_offset_from_front_mm, 0])
      cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
  }
}

// KP Pillow Block (circular bearing housing/ring)
module kp_pillow_block() {
  // Positioned to overlap the seat by overlap_mm (guaranteed physical connection)
  translate([0, 0, housing_center_z])
    rotate([90, 0, 0])
    cylinder(r=housing_outer_diameter_mm/2, h=housing_length_y_mm, center=true);
}

// KP Pillow Block Assembly (seat + housing + gussets)
module kp_pillow_block_assembly() {
  union() {
    // Seat (overlaps base by overlap_mm)
    translate([0, 0, seat_center_z])
      cylinder(r=seat_diameter_mm/2, h=seat_height_mm, center=true);

    // Housing (overlaps seat by overlap_mm)  <-- FIXES FLOATING RING
    kp_pillow_block();

    // Gussets (kept as-is but already overlapping via -overlap_mm in Z)
    translate([base_length_mm/2 - gusset_thickness_x_mm/2 - overlap_mm,
               housing_outer_diameter_mm/2 - trapezoid_base_y_mm/2,
               base_thickness_mm/2 + trapezoid_height_mm/2 - overlap_mm])
      rotate([0, 90, 0]) right_trapezoid();

    mirror([1, 0, 0]) {
      translate([base_length_mm/2 - gusset_thickness_x_mm/2 - overlap_mm,
                 housing_outer_diameter_mm/2 - trapezoid_base_y_mm/2,
                 base_thickness_mm/2 + trapezoid_height_mm/2 - overlap_mm])
        rotate([0, 90, 0]) right_trapezoid();
    }
  }
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  difference() {
    union() {
      // Base
      cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);

      // Pillow block features (now physically connected to base via seat overlap)
      kp_pillow_block_assembly();
    }

    // Shaft bore (aligned with housing center; long enough to cut through)
    translate([0, 0, housing_center_z])
      rotate([90, 0, 0])
      cylinder(r=(shaft_diameter_mm + bore_clearance_mm)/2,
               h=base_width_mm + housing_length_y_mm + 2*overlap_mm,
               center=true);

    // Mounting holes
    kp_pillow_block_hole_positions();
  }
}

// Final Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();