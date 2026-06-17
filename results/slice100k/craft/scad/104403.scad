$fn = 96;

// Parameters (mm)
bbox_x = 22.0;
bbox_y = 22.0;
bbox_z = 37.6;

body_x = bbox_x;
body_y = bbox_y;
body_z = bbox_z;

bore_d = 10.0;

tab_x = 8.0;
tab_y = 4.0;
tab_z = 2.0;

side_key_x = 2.0;
side_key_y = 8.0;
side_key_z = 10.0;

connect_overlap = 0.6;   // small overlap to guarantee connectivity
bore_chamfer_h = 1.0;
bore_chamfer_d = 12.0;

// ---- Base solids ----
module outer_body_block() {
  cube([body_x, body_y, body_z], center=true);
}

module top_center_tab() {
  translate([0, 0, body_z/2 + tab_z/2 - connect_overlap])
    cube([tab_x, tab_y, tab_z], center=true);
}

module bottom_center_tab() {
  translate([0, 0, -body_z/2 - tab_z/2 + connect_overlap])
    cube([tab_x, tab_y, tab_z], center=true);
}

module left_side_key() {
  translate([-body_x/2 - side_key_x/2 + connect_overlap, 0, 0])
    cube([side_key_x, side_key_y, side_key_z], center=true);
}

module right_side_key() {
  translate([ body_x/2 + side_key_x/2 - connect_overlap, 0, 0])
    cube([side_key_x, side_key_y, side_key_z], center=true);
}

// ---- Bore cutters ----
module central_through_bore() {
  cylinder(h=body_z + 2*connect_overlap, r=bore_d/2, center=true);
}

module bore_chamfer_top() {
  // frustum: larger at top face, smaller into bore
  translate([0, 0, body_z/2 - bore_chamfer_h/2 + connect_overlap])
    cylinder(h=bore_chamfer_h, r1=bore_chamfer_d/2, r2=bore_d/2, center=true);
}

module bore_chamfer_bottom() {
  translate([0, 0, -body_z/2 + bore_chamfer_h/2 - connect_overlap])
    cylinder(h=bore_chamfer_h, r1=bore_d/2, r2=bore_chamfer_d/2, center=true);
}

// ---- Final model ----
difference() {
  union() {
    outer_body_block();
    top_center_tab();
    bottom_center_tab();
    left_side_key();
    right_side_key();
  }

  union() {
    central_through_bore();
    bore_chamfer_top();
    bore_chamfer_bottom();
  }
}