// Parameters
bbox_L = 92.71; //[46.355:185.42:0.01]
bbox_W = 67.7; //[33.85:135.4:0.01]
bbox_H = 10.79; //[5.395:21.58:0.01]
plate_t = 3.0; //[1.5:6.0:0.1]
boss_h = 7.79; //[3.895:15.58:0.01]
center_L = 26.0; //[13.0:52.0:0.1]
center_W = 18.0; //[9.0:36.0:0.1]
arm_w = 10.0; //[5.0:20.0:0.1]
lug_od = 16.0; //[8.0:32.0:0.1]
hole_d = 5.0; //[2.5:10.0:0.1]
lug_center_offset_x = 38.0; //[19.0:76.0:0.1]
lug_center_offset_y = 25.0; //[12.5:50.0:0.1]
arm_end_overlap = 2.0; //[0.5:4.0:0.1]
outer_edge_clearance = 0.0; //[0.0:2.0:0.1]
conn_overlap = 1.0; //[0.5:2.0:0.1]
open_margin = 1.0; //[0.5:4.0:0.1]
open_r = 12.0; //[6.0:24.0:0.1]
edge_round_r = 0.8; //[0.0:2.0:0.1]
csk_d = 9.0; //[6.0:14.0:0.1]
csk_h = 2.0; //[0.5:4.0:0.1]

// Central Plate
module central_plate() {
  translate([0, 0, 0])
    cube([center_L, center_W, plate_t], center=true);
}

// Arm Module
module arm(x_offset, y_offset, angle) {
  length = sqrt((lug_center_offset_x - center_L/2 + arm_end_overlap)^2 + (lug_center_offset_y - center_W/2 + arm_end_overlap)^2);
  translate([(center_L/2 + x_offset)/2, (center_W/2 + y_offset)/2, 0])
    rotate([0, 0, angle])
      cube([length, arm_w, plate_t], center=true);
}

// Lug Module
module lug(x_offset, y_offset) {
  translate([x_offset, y_offset, plate_t/2 + boss_h/2 - conn_overlap/2])
    cylinder(h=boss_h, r=lug_od/2, center=true);
}

// Hole Module
module hole(x_offset, y_offset) {
  translate([x_offset, y_offset, boss_h/2])
    cylinder(h=bbox_H + 2*conn_overlap, r=hole_d/2, center=true);
}

// Counterbore Module
module counterbore(x_offset, y_offset) {
  translate([x_offset, y_offset, plate_t/2 + boss_h - (csk_h + conn_overlap)/2])
    cylinder(h=csk_h + conn_overlap, r=csk_d/2, center=true);
}

// Open Area Module
module open_area(x_offset, y_offset) {
  translate([x_offset, y_offset, 0])
    cylinder(h=plate_t + 2*conn_overlap, r=open_r, center=true);
}

// Arm Root Blends
module arm_root_blends() {
  cylinder(h=plate_t, r=arm_w/2, center=true);
}

// Edge Rounding Sphere
module edge_rounding_sphere() {
  sphere(r=edge_round_r, center=true);
}

// Assemble Bracket
module bracket() {
  union() {
    central_plate();
    arm(lug_center_offset_x, lug_center_offset_y, atan2((lug_center_offset_y - center_W/2 + arm_end_overlap), (lug_center_offset_x - center_L/2 + arm_end_overlap)));
    arm(-lug_center_offset_x, lug_center_offset_y, 180 - atan2((lug_center_offset_y - center_W/2 + arm_end_overlap), (lug_center_offset_x - center_L/2 + arm_end_overlap)));
    arm(lug_center_offset_x, -lug_center_offset_y, -atan2((lug_center_offset_y - center_W/2 + arm_end_overlap), (lug_center_offset_x - center_L/2 + arm_end_overlap)));
    arm(-lug_center_offset_x, -lug_center_offset_y, 180 + atan2((lug_center_offset_y - center_W/2 + arm_end_overlap), (lug_center_offset_x - center_L/2 + arm_end_overlap)));
    lug(lug_center_offset_x, lug_center_offset_y);
    lug(-lug_center_offset_x, lug_center_offset_y);
    lug(lug_center_offset_x, -lug_center_offset_y);
    lug(-lug_center_offset_x, -lug_center_offset_y);
  }
}

// Weight Reduction Open Areas
module weight_reduction() {
  union() {
    open_area(0, center_W/2 + open_r + open_margin);
    open_area(0, -(center_W/2 + open_r + open_margin));
    open_area(center_L/2 + open_r + open_margin, 0);
    open_area(-(center_L/2 + open_r + open_margin), 0);
  }
}

// All Holes
module all_holes() {
  union() {
    hole(lug_center_offset_x, lug_center_offset_y);
    hole(-lug_center_offset_x, lug_center_offset_y);
    hole(lug_center_offset_x, -lug_center_offset_y);
    hole(-lug_center_offset_x, -lug_center_offset_y);
  }
}

// All Counterbores
module all_counterbores() {
  union() {
    counterbore(lug_center_offset_x, lug_center_offset_y);
    counterbore(-lug_center_offset_x, lug_center_offset_y);
    counterbore(lug_center_offset_x, -lug_center_offset_y);
    counterbore(-lug_center_offset_x, -lug_center_offset_y);
  }
}

// Final Bracket with Cutouts
module final_bracket() {
  difference() {
    bracket();
    weight_reduction();
    union() {
      all_holes();
      all_counterbores();
    }
  }
}

// Final Output
minkowski() {
  final_bracket();
  edge_rounding_sphere();
}