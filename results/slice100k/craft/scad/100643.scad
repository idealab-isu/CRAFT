// Parameters
bbox_L = 85.07; //[42.535:170.14:0.01]
bbox_W = 22.45; //[11.225:44.9:0.01]
bbox_H = 10.44; //[5.22:20.88:0.01]
plate_L = 85.07; //[42.535:170.14:0.01]
plate_W = 22.45; //[11.225:44.9:0.01]
plate_T = 3.0; //[1.5:6.0:0.1]
end_chamfer_L = 4.0; //[2.0:8.0:0.1]
prong_W = 8.0; //[4.0:16.0:0.1]
prong_T = 4.0; //[2.0:8.0:0.1]
prong_H = 7.44; //[3.72:14.88:0.01]
prong1_center_from_left = 25.0; //[12.5:50.0:0.1]
prong2_center_from_left = 60.0; //[30.0:120.0:0.1]
prong_end_step_L = 2.5; //[1.25:5.0:0.1]
prong_end_step_drop = 1.5; //[0.75:3.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
relief_r = 1.0; //[0.5:2.0:0.1]
cosmetic_r = 0.6; //[0.3:1.2:0.1]

// Base shapes
module base_bar_plate() {
  cube([plate_L, plate_W, plate_T], center=true);
}

module end_chamfer_left() {
  translate([-plate_L/2 + end_chamfer_L/2, 0, 0])
    rotate([0, 0, 45])
    cube([end_chamfer_L, plate_W, plate_T + 2*overlap], center=true);
}

module end_chamfer_right() {
  translate([plate_L/2 - end_chamfer_L/2, 0, 0])
    rotate([0, 0, 45])
    cube([end_chamfer_L, plate_W, plate_T + 2*overlap], center=true);
}

module prong_1() {
  translate([-plate_L/2 + prong1_center_from_left, 0, plate_T/2 + prong_H/2 - overlap])
    cube([prong_T, prong_W, prong_H], center=true);
}

module prong_2() {
  translate([-plate_L/2 + prong2_center_from_left, 0, plate_T/2 + prong_H/2 - overlap])
    cube([prong_T, prong_W, prong_H], center=true);
}

module prong_1_end_shoulder_step() {
  translate([-plate_L/2 + prong1_center_from_left + prong_T/2 - prong_end_step_L/2, prong_W/2 - prong_end_step_drop/2, plate_T/2 + prong_H/2 - overlap])
    cube([prong_end_step_L, prong_W + 2*overlap, prong_H + 2*overlap], center=true);
}

module prong_2_end_shoulder_step() {
  translate([-plate_L/2 + prong2_center_from_left + prong_T/2 - prong_end_step_L/2, prong_W/2 - prong_end_step_drop/2, plate_T/2 + prong_H/2 - overlap])
    cube([prong_end_step_L, prong_W + 2*overlap, prong_H + 2*overlap], center=true);
}

module minor_relief_cuts() {
  translate([-plate_L/2 + prong1_center_from_left - prong_T/2 + relief_r, prong_W/2 - relief_r, 0])
    rotate([90, 0, 0])
    cylinder(r=relief_r, h=plate_T + 2*overlap, center=true);
}

module edge_fillets() {
  sphere(r=cosmetic_r, center=true);
}

// Operations
module plate_chamfered() {
  difference() {
    base_bar_plate();
    end_chamfer_left();
    end_chamfer_right();
  }
}

module prongs_union_raw() {
  union() {
    prong_1();
    prong_2();
  }
}

module prongs_stepped_1() {
  difference() {
    prongs_union_raw();
    prong_1_end_shoulder_step();
    prong_2_end_shoulder_step();
  }
}

module plate_plus_prongs() {
  union() {
    plate_chamfered();
    prongs_stepped_1();
  }
}

module with_reliefs() {
  difference() {
    plate_plus_prongs();
    minor_relief_cuts();
  }
}

module cosmetic_rounding() {
  minkowski() {
    with_reliefs();
    edge_fillets();
  }
}

// Final output
cosmetic_rounding();