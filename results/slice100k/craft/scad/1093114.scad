// Dimension-calibrated (target: 47.81 x 47.81 x 14.35 mm)
scale([1.100439, 1.098558, 0.812434])
{
// Parameters
bbox_X = 47.81; //[23.905:95.62:0.01]
bbox_Y = 47.81; //[23.905:95.62:0.01]
bbox_Z = 14.35; //[7.175:28.7:0.01]
plate_t = 6.0; //[3.0:12.0:0.1]
hub_d = 18.0; //[9.0:36.0:0.1]
junction_L = 12.0; //[6.0:24.0:0.1]
junction_W = 12.0; //[6.0:24.0:0.1]
arm_len = 21.9; //[10.95:43.8:0.1]
arm_outer_W = 12.0; //[6.0:24.0:0.1]
arm_tip_R = 6.0; //[3.0:12.0:0.1]
arm_inner_cutout_L = 14.5; //[7.25:29.0:0.1]
arm_inner_cutout_W = 7.0; //[3.5:14.0:0.1]
arm_inner_tip_R = 3.5; //[1.75:7.0:0.1]
arm_wall_min = 2.0; //[1.0:4.0:0.1]
peg_d = 6.0; //[3.0:12.0:0.1]
peg_h = 8.35; //[4.175:16.7:0.01]
overlap = 1.0; //[0.5:2.0:0.1]
rounding_r = 0.8; //[0.4:1.6:0.1]
arm_center_offset = 14.0; //[7.0:28.0:0.1]
arm_outer_R = 10.0; //[5.0:20.0:0.1]
arm_inner_R = 6.5; //[3.25:13.0:0.1]

// Base Shapes
module central_hub_junction() {
  translate([0, 0, 0])
    cylinder(r=hub_d/2, h=plate_t, center=true);
}

module central_rectangular_junction_block() {
  translate([0, 0, 0])
    cube([junction_L, junction_W, plate_t], center=true);
}

module arm_1_loop_outer() {
  translate([arm_center_offset, 0, 0])
    cylinder(r=arm_outer_R, h=plate_t, center=true);
}

module arm_1_loop_inner() {
  translate([arm_center_offset, 0, 0])
    cylinder(r=arm_inner_R, h=plate_t + 2*overlap, center=true);
}

module arm_1_outer_clip() {
  translate([arm_center_offset - arm_outer_R + (junction_L/2 + overlap), 0, 0])
    cube([2*arm_outer_R, 2*arm_outer_R, plate_t + 2*overlap], center=true);
}

module arm_1_inner_clip() {
  translate([arm_center_offset - arm_inner_R + (junction_L/2 + overlap), 0, 0])
    cube([2*arm_inner_R, 2*arm_inner_R, plate_t + 4*overlap], center=true);
}

module arm_1_root_blend_sphere() {
  translate([junction_L/2 - overlap, 0, 0])
    sphere(r=arm_outer_W/2);
}

module arm_2_root_blend_sphere() {
  translate([0, junction_W/2 - overlap, 0])
    sphere(r=arm_outer_W/2);
}

module arm_3_root_blend_sphere() {
  translate([-(junction_L/2 - overlap), 0, 0])
    sphere(r=arm_outer_W/2);
}

module arm_4_root_blend_sphere() {
  translate([0, -(junction_W/2 - overlap), 0])
    sphere(r=arm_outer_W/2);
}

module center_peg_boss() {
  translate([0, 0, plate_t/2 + peg_h/2 - overlap])
    cylinder(r=peg_d/2, h=peg_h, center=true);
}

module outer_edge_rounding_sphere() {
  sphere(r=rounding_r);
}

// Operations
module arm_1_loop_outer_clipped() {
  intersection() {
    arm_1_loop_outer();
    arm_1_outer_clip();
  }
}

module arm_1_loop_inner_clipped() {
  intersection() {
    arm_1_loop_inner();
    arm_1_inner_clip();
  }
}

module arm_1_loop() {
  difference() {
    arm_1_loop_outer_clipped();
    arm_1_loop_inner_clipped();
  }
}

module arm_1_cutout() {
  intersection() {
    arm_1_loop_inner();
    arm_1_inner_clip();
  }
}

module arm_2_loop() {
  rotate([0, 0, 90]) arm_1_loop();
}

module arm_3_loop() {
  rotate([0, 0, 180]) arm_1_loop();
}

module arm_4_loop() {
  rotate([0, 0, 270]) arm_1_loop();
}

module arm_2_cutout() {
  rotate([0, 0, 90]) arm_1_cutout();
}

module arm_3_cutout() {
  rotate([0, 0, 180]) arm_1_cutout();
}

module arm_4_cutout() {
  rotate([0, 0, 270]) arm_1_cutout();
}

module arm_root_blends_rounding() {
  hull() {
    central_hub_junction();
    arm_1_root_blend_sphere();
    arm_2_root_blend_sphere();
    arm_3_root_blend_sphere();
    arm_4_root_blend_sphere();
  }
}

module plate_core_union() {
  union() {
    central_hub_junction();
    central_rectangular_junction_block();
    arm_1_loop();
    arm_2_loop();
    arm_3_loop();
    arm_4_loop();
    arm_root_blends_rounding();
  }
}

module plate_with_cutouts() {
  difference() {
    plate_core_union();
    arm_1_cutout();
    arm_2_cutout();
    arm_3_cutout();
    arm_4_cutout();
  }
}

module plate_with_peg() {
  union() {
    plate_with_cutouts();
    center_peg_boss();
  }
}

module fillets_chamfers_detail() {
  minkowski() {
    plate_with_peg();
    outer_edge_rounding_sphere();
  }
}

// Final Output
fillets_chamfers_detail();
}
