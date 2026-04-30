// Parameters
total_length = 42; //[21:84:1]
plate_width = 42; //[21:84:1]
plate_height = 42; //[21:84:1]
plate_thickness = 5; //[2.5:10:0.5]
center_bore_diameter = 22; //[11:44:0.5]
hole_pattern_spacing = 31; //[15.5:62:0.5]
mount_hole_diameter = 3.5; //[1.75:7:0.1]
hole_pattern_rotation_deg = 0; //[-45:45:1]
corner_radius = 0; //[0:6:0.5]
edge_margin_min = 3; //[1.5:6:0.5]
overlap = 0.8; //[0.5:2:0.1]

// Base Shapes
module plate_outer_profile() {
  color("Silver")
  cube([plate_width, plate_height, plate_thickness], center=true);
}

module center_bore() {
  cylinder(r=center_bore_diameter/2, h=plate_thickness + 2*overlap, center=true);
}

module mount_hole_cyl() {
  cylinder(r=mount_hole_diameter/2, h=plate_thickness + 2*overlap, center=true);
}

// Operations
module mounting_holes_clearance_unrot() {
  union() {
    translate([hole_pattern_spacing/2, hole_pattern_spacing/2, 0]) mount_hole_cyl();
    translate([-hole_pattern_spacing/2, hole_pattern_spacing/2, 0]) mount_hole_cyl();
    translate([-hole_pattern_spacing/2, -hole_pattern_spacing/2, 0]) mount_hole_cyl();
    translate([hole_pattern_spacing/2, -hole_pattern_spacing/2, 0]) mount_hole_cyl();
  }
}

module mounting_hole_pattern_31mm() {
  rotate([0, 0, hole_pattern_rotation_deg])
  mounting_holes_clearance_unrot();
}

module mounting_holes_clearance() {
  union() {
    center_bore();
    mounting_hole_pattern_31mm();
  }
}

// Final Output
difference() {
  plate_outer_profile();
  mounting_holes_clearance();
}