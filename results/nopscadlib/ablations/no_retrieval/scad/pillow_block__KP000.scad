// Parameters
base_L = 67; //[33.5:134:0.5]
base_W = 53; //[26.5:106:0.5]
base_H = 12; //[6:24:0.5]
housing_L = 50; //[25:100:0.5]
housing_W = 36; //[18:72:0.5]
housing_H = 28; //[14:56:0.5]
bore_D = 10; //[5:20:0.1]
bore_axis_H = 22; //[11:44:0.5]
mount_hole_D = 8.5; //[4.25:17:0.1]
mount_hole_spacing_L = 50; //[25:100:0.5]
mount_hole_edge_margin_W = 10; //[5:20:0.5]
overlap = 1; //[0.5:2:0.1]
housing_top_r = 18; //[9:36:0.5]
grease_boss_D = 8; //[4:16:0.5]
grease_boss_H = 6; //[3:12:0.5]
set_screw_D = 5; //[2.5:10:0.1]
set_screw_spacing_Z = 10; //[5:20:0.5]
set_screw_axis_Y = 0; //[-10:10:0.5]
fillet_r = 2; //[0.5:6:0.5]

// Base block
module base_block() {
  color("Silver")
  translate([0, 0, 0])
    cube([base_L, base_W, base_H], center=true);
}

// Bearing housing block
module bearing_housing_block() {
  color("DimGray")
  translate([0, 0, base_H/2 + housing_H/2 - overlap])
    cube([housing_L, housing_W, housing_H], center=true);
}

// Housing top profile
module housing_top_profile() {
  color("DimGray")
  translate([0, 0, base_H/2 + housing_H - housing_top_r])
    rotate([0, 90, 0])
      cylinder(r=housing_top_r, h=housing_L, center=true);
}

// Grease nipple boss
module grease_nipple_boss() {
  color("DimGray")
  translate([0, 0, base_H/2 + housing_H + grease_boss_H/2 - overlap])
    cylinder(r=grease_boss_D/2, h=grease_boss_H, center=true);
}

// Shaft bore
module shaft_bore() {
  translate([0, 0, bore_axis_H - base_H/2])
    rotate([90, 0, 0])
      cylinder(r=bore_D/2, h=base_W + housing_W + 4*overlap, center=true);
}

// Mounting holes
module mounting_hole_1() {
  translate([-mount_hole_spacing_L/2, base_W/2 - mount_hole_edge_margin_W, 0])
    cylinder(r=mount_hole_D/2, h=base_H + 2*overlap, center=true);
}

module mounting_hole_2() {
  translate([mount_hole_spacing_L/2, -(base_W/2 - mount_hole_edge_margin_W), 0])
    cylinder(r=mount_hole_D/2, h=base_H + 2*overlap, center=true);
}

// Set screw holes
module set_screw_hole_1() {
  translate([0, set_screw_axis_Y, bore_axis_H - base_H/2 + set_screw_spacing_Z/2])
    rotate([90, 0, 0])
      cylinder(r=set_screw_D/2, h=housing_W + 2*overlap, center=true);
}

module set_screw_hole_2() {
  translate([0, set_screw_axis_Y, bore_axis_H - base_H/2 - set_screw_spacing_Z/2])
    rotate([90, 0, 0])
      cylinder(r=set_screw_D/2, h=housing_W + 2*overlap, center=true);
}

// Fillet kernel sphere
module fillets_kernel_sphere() {
  sphere(r=fillet_r);
}

// Bearing housing
module bearing_housing() {
  union() {
    bearing_housing_block();
    housing_top_profile();
    grease_nipple_boss();
  }
}

// Raw body union
module raw_body_union() {
  union() {
    base_block();
    bearing_housing();
  }
}

// Mounting holes 2x
module mounting_holes_2x() {
  union() {
    mounting_hole_1();
    mounting_hole_2();
  }
}

// Set screw holes 2x
module set_screw_holes_2x() {
  union() {
    set_screw_hole_1();
    set_screw_hole_2();
  }
}

// Body with holes
module body_with_holes() {
  difference() {
    raw_body_union();
    shaft_bore();
    mounting_holes_2x();
    set_screw_holes_2x();
  }
}

// Final output with fillets
module fillets_chamfers() {
  // Minkowski is avoided due to performance issues, so fillets are omitted
  body_with_holes();
}

// Render the final output
fillets_chamfers();