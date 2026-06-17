// Parameters
body_L = 14.7; //[7.35:29.4:0.1]
body_W = 12.0; //[6.0:24.0:0.1]
body_H = 6.0; //[3.0:12.0:0.1]
shaft_D = 5.5; //[2.75:11.0:0.1]
shaft_L = 12.0; //[6.0:24.0:0.1]
gearbox_step_L = 4.0; //[2.0:8.0:0.1]
gearbox_step_H = 1.5; //[0.75:3.0:0.1]
mount_face_t = 1.0; //[0.5:2.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
mount_hole_D = 2.2; //[1.0:4.0:0.1]
mount_hole_edge_margin = 2.0; //[1.0:4.0:0.1]
shaft_flat_depth = 1.0; //[0.5:2.0:0.1]
shaft_flat_L = 8.0; //[4.0:16.0:0.1]
wire_D = 1.2; //[0.6:2.4:0.1]
wire_L = 10.0; //[5.0:20.0:0.1]
wire_spacing = 3.0; //[1.5:6.0:0.1]
label_L = 8.0; //[4.0:16.0:0.1]
label_W = 6.0; //[3.0:12.0:0.1]
label_t = 0.6; //[0.3:1.2:0.1]
fillet_r = 0.4; //[0.2:1.0:0.1]

// Base Shapes
module housing_body() {
  cube([body_L, body_W, body_H], center=true);
}

module gearbox_step() {
  cube([gearbox_step_L, body_W, body_H + gearbox_step_H], center=true);
}

module mounting_face() {
  cube([mount_face_t, body_W, body_H + gearbox_step_H], center=true);
}

module output_shaft() {
  rotate([0, 90, 0])
    cylinder(h=shaft_L, r=shaft_D/2, center=true);
}

module mount_hole() {
  rotate([0, 90, 0])
    cylinder(h=mount_face_t + 2*overlap, r=mount_hole_D/2, center=true);
}

module shaft_flat_cutter() {
  cube([shaft_flat_L, shaft_D, shaft_D], center=true);
}

module wire_lead() {
  rotate([0, 90, 0])
    cylinder(h=wire_L, r=wire_D/2, center=true);
}

module label_plate() {
  cube([label_L, label_W, label_t], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module housing_union_raw() {
  union() {
    translate([0, 0, 0]) housing_body();
    translate([body_L/2 + gearbox_step_L/2 - overlap, 0, 0]) gearbox_step();
    translate([body_L/2 + gearbox_step_L + mount_face_t/2 - overlap, 0, 0]) mounting_face();
  }
}

module fillets_chamfers() {
  minkowski() {
    housing_union_raw();
    fillet_sphere();
  }
}

module mounting_holes() {
  difference() {
    fillets_chamfers();
    translate([body_L/2 + gearbox_step_L + mount_face_t/2 - overlap, body_W/2 - mount_hole_edge_margin, body_H/2 + gearbox_step_H/2 - mount_hole_edge_margin]) mount_hole();
    translate([body_L/2 + gearbox_step_L + mount_face_t/2 - overlap, -(body_W/2 - mount_hole_edge_margin), body_H/2 + gearbox_step_H/2 - mount_hole_edge_margin]) mount_hole();
    translate([body_L/2 + gearbox_step_L + mount_face_t/2 - overlap, body_W/2 - mount_hole_edge_margin, -(body_H/2 + gearbox_step_H/2 - mount_hole_edge_margin)]) mount_hole();
    translate([body_L/2 + gearbox_step_L + mount_face_t/2 - overlap, -(body_W/2 - mount_hole_edge_margin), -(body_H/2 + gearbox_step_H/2 - mount_hole_edge_margin)]) mount_hole();
  }
}

module output_shaft_with_flat() {
  difference() {
    translate([body_L/2 + gearbox_step_L + mount_face_t + shaft_L/2 - overlap, 0, 0]) output_shaft();
    translate([body_L/2 + gearbox_step_L + mount_face_t + shaft_L - shaft_flat_L/2, shaft_D/2 - shaft_flat_depth/2, 0]) shaft_flat_cutter();
  }
}

module motor_complete() {
  union() {
    mounting_holes();
    output_shaft_with_flat();
    translate([-(body_L/2 + wire_L/2 - overlap), wire_spacing/2, -(body_H/2 - wire_D)]) wire_lead();
    translate([-(body_L/2 + wire_L/2 - overlap), -wire_spacing/2, -(body_H/2 - wire_D)]) wire_lead();
    translate([0, 0, body_H/2 + label_t/2 - overlap]) label_plate();
  }
}

// Final Output
motor_complete();