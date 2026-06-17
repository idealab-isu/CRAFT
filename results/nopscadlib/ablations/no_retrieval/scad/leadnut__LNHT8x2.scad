// Parameters
block_x = 30; //[15:60:1]
block_y = 34; //[17:68:1]
block_z = 30; //[15:60:1]
leadscrew_bore_d = 12; //[6:24:1]
nut_capture_x = 18; //[10:28:1]
nut_capture_y = 22; //[12:32:1]
nut_capture_depth = 8; //[3:15:1]
mount_hole_d = 5; //[3:8:0.5]
mount_hole_spacing_x = 20; //[12:26:1]
mount_hole_spacing_y = 24; //[14:30:1]
counterbore_d = 9; //[6:14:0.5]
counterbore_depth = 4; //[2:10:0.5]
edge_fillet_r = 1; //[0.5:3:0.5]
op_overlap = 1; //[0.5:2:0.5]

// Base Shapes
module housing_block() {
  translate([0, 0, 0])
    cube([block_x, block_y, block_z], center=true);
}

module leadscrew_nut_bore() {
  translate([0, 0, 0])
    cylinder(h=block_z + 2*op_overlap, r=leadscrew_bore_d/2, center=true);
}

module nut_capture_pocket() {
  translate([0, 0, block_z/2 - (nut_capture_depth + op_overlap)/2])
    cube([nut_capture_x, nut_capture_y, nut_capture_depth + op_overlap], center=true);
}

module mount_hole(x, y) {
  translate([x, y, 0])
    cylinder(h=block_z + 2*op_overlap, r=mount_hole_d/2, center=true);
}

module counterbore(x, y) {
  translate([x, y, block_z/2 - (counterbore_depth + op_overlap)/2])
    cylinder(h=counterbore_depth + op_overlap, r=counterbore_d/2, center=true);
}

module fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=edge_fillet_r, center=true);
}

// Operations
module mounting_holes_union() {
  union() {
    mount_hole(mount_hole_spacing_x/2, mount_hole_spacing_y/2);
    mount_hole(-mount_hole_spacing_x/2, mount_hole_spacing_y/2);
    mount_hole(-mount_hole_spacing_x/2, -mount_hole_spacing_y/2);
    mount_hole(mount_hole_spacing_x/2, -mount_hole_spacing_y/2);
  }
}

module counterbores_countersinks_union() {
  union() {
    counterbore(mount_hole_spacing_x/2, mount_hole_spacing_y/2);
    counterbore(-mount_hole_spacing_x/2, mount_hole_spacing_y/2);
    counterbore(-mount_hole_spacing_x/2, -mount_hole_spacing_y/2);
    counterbore(mount_hole_spacing_x/2, -mount_hole_spacing_y/2);
  }
}

module all_cutters_union() {
  union() {
    leadscrew_nut_bore();
    nut_capture_pocket();
    mounting_holes_union();
    counterbores_countersinks_union();
  }
}

module housing_with_features() {
  difference() {
    housing_block();
    all_cutters_union();
  }
}

module chamfers_fillets() {
  minkowski() {
    housing_with_features();
    fillet_sphere();
  }
}

// Final Output
chamfers_fillets();