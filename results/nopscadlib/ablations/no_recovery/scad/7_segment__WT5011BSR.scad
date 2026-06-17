// Parameters
body_W = 12.7; //[6.35:25.4:0.1]
body_H = 19.0; //[9.5:38.0:0.1]
body_D = 8.2; //[4.1:16.4:0.1]
recess_depth = 0.8; //[0.4:1.6:0.1]
recess_margin = 0.6; //[0.3:1.2:0.1]
segment_relief_depth = 0.4; //[0.2:1.0:0.1]
segment_thickness = 1.6; //[0.8:3.2:0.1]
segment_gap = 0.6; //[0.3:1.2:0.1]
dp_diameter = 2.0; //[1.0:4.0:0.1]
pin_diameter = 0.8; //[0.5:1.6:0.1]
pin_length = 3.0; //[1.5:6.0:0.1]
pin_inset = 1.6; //[0.8:3.2:0.1]
rear_cavity_depth = 4.5; //[2.0:7.5:0.1]
rear_wall = 1.2; //[0.6:2.4:0.1]
chamfer_size = 0.6; //[0.3:1.2:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Base Shapes
module display_body() {
  cube([body_W, body_H, body_D], center=true);
}

module front_face_recess() {
  translate([0, 0, body_D/2 - (recess_depth + overlap)/2])
    cube([body_W - 2*recess_margin, body_H - 2*recess_margin, recess_depth + overlap], center=true);
}

module seg_top() {
  translate([0, (body_H - 2*recess_margin)/2 - segment_gap - segment_thickness/2, body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cube([(body_W - 2*recess_margin) - 2*segment_gap, segment_thickness, segment_relief_depth + overlap], center=true);
}

module seg_mid() {
  translate([0, 0, body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cube([(body_W - 2*recess_margin) - 2*segment_gap, segment_thickness, segment_relief_depth + overlap], center=true);
}

module seg_bot() {
  translate([0, -((body_H - 2*recess_margin)/2 - segment_gap - segment_thickness/2), body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cube([(body_W - 2*recess_margin) - 2*segment_gap, segment_thickness, segment_relief_depth + overlap], center=true);
}

module seg_ul() {
  translate([-((body_W - 2*recess_margin)/2 - segment_gap - segment_thickness/2), ((body_H - 2*recess_margin)/4), body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cube([segment_thickness, ((body_H - 2*recess_margin) - 3*segment_thickness - 4*segment_gap)/2, segment_relief_depth + overlap], center=true);
}

module seg_ur() {
  translate([((body_W - 2*recess_margin)/2 - segment_gap - segment_thickness/2), ((body_H - 2*recess_margin)/4), body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cube([segment_thickness, ((body_H - 2*recess_margin) - 3*segment_thickness - 4*segment_gap)/2, segment_relief_depth + overlap], center=true);
}

module seg_ll() {
  translate([-((body_W - 2*recess_margin)/2 - segment_gap - segment_thickness/2), -((body_H - 2*recess_margin)/4), body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cube([segment_thickness, ((body_H - 2*recess_margin) - 3*segment_thickness - 4*segment_gap)/2, segment_relief_depth + overlap], center=true);
}

module seg_lr() {
  translate([((body_W - 2*recess_margin)/2 - segment_gap - segment_thickness/2), -((body_H - 2*recess_margin)/4), body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cube([segment_thickness, ((body_H - 2*recess_margin) - 3*segment_thickness - 4*segment_gap)/2, segment_relief_depth + overlap], center=true);
}

module decimal_point() {
  translate([(body_W - 2*recess_margin)/2 - segment_gap - dp_diameter/2, -((body_H - 2*recess_margin)/2 - segment_gap - dp_diameter/2), body_D/2 - recess_depth + (segment_relief_depth + overlap)/2 - overlap])
    cylinder(r=dp_diameter/2, h=segment_relief_depth + overlap, center=true);
}

module rear_cavity() {
  translate([0, 0, -body_D/2 + (rear_cavity_depth + overlap)/2])
    cube([body_W - 2*rear_wall, body_H - 2*rear_wall, rear_cavity_depth + overlap], center=true);
}

module pin(position) {
  translate(position)
    cylinder(r=pin_diameter/2, h=pin_length, center=true);
}

module chamfer_cut(position) {
  translate(position)
    cube([chamfer_size, chamfer_size, recess_depth + chamfer_size + overlap], center=true);
}

// Operations
module individual_segments() {
  union() {
    seg_top();
    seg_mid();
    seg_bot();
    seg_ul();
    seg_ur();
    seg_ll();
    seg_lr();
  }
}

module mounting_pins() {
  union() {
    pin([-(body_W/2 - pin_inset), -(body_H/2 - pin_inset), -body_D/2 - pin_length/2 + overlap]);
    pin([(body_W/2 - pin_inset), -(body_H/2 - pin_inset), -body_D/2 - pin_length/2 + overlap]);
    pin([-(body_W/2 - pin_inset), (body_H/2 - pin_inset), -body_D/2 - pin_length/2 + overlap]);
    pin([(body_W/2 - pin_inset), (body_H/2 - pin_inset), -body_D/2 - pin_length/2 + overlap]);
  }
}

module bezel_chamfers() {
  union() {
    chamfer_cut([body_W/2 - chamfer_size/2, body_H/2 - chamfer_size/2, body_D/2 - (recess_depth + chamfer_size + overlap)/2]);
    chamfer_cut([-(body_W/2 - chamfer_size/2), body_H/2 - chamfer_size/2, body_D/2 - (recess_depth + chamfer_size + overlap)/2]);
    chamfer_cut([body_W/2 - chamfer_size/2, -(body_H/2 - chamfer_size/2), body_D/2 - (recess_depth + chamfer_size + overlap)/2]);
    chamfer_cut([-(body_W/2 - chamfer_size/2), -(body_H/2 - chamfer_size/2), body_D/2 - (recess_depth + chamfer_size + overlap)/2]);
  }
}

module body_with_pins() {
  union() {
    display_body();
    mounting_pins();
  }
}

module front_detail_cuts() {
  union() {
    front_face_recess();
    individual_segments();
    decimal_point();
    bezel_chamfers();
  }
}

module housing_with_front_details() {
  difference() {
    body_with_pins();
    front_detail_cuts();
  }
}

module complete_model() {
  difference() {
    housing_with_front_details();
    rear_cavity();
  }
}

// Final Output
complete_model();