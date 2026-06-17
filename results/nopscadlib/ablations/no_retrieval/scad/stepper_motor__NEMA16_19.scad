// Parameters
face_W = 39.5; //[20:80:0.1]
face_th = 3; //[1.5:8:0.1]
body_W = 39.5; //[20:80:0.1]
body_H = 39.5; //[20:80:0.1]
body_L = 19.2; //[10:60:0.1]
shaft_d = 5; //[2:12:0.1]
shaft_L = 20; //[5:60:0.1]
boss_d = 22; //[10:40:0.1]
boss_th = 2; //[1:6:0.1]
rear_cap_th = 2; //[1:6:0.1]
mount_spacing = 31; //[15:60:0.1]
mount_hole_d = 3.5; //[2:6:0.1]
mount_hole_depth = 6; //[2:20:0.1]
overlap = 1; //[0.5:2:0.1]
shaft_flat_depth = 0.6; //[0.2:2:0.1]
shaft_flat_L = 12; //[4:40:0.1]
connector_W = 12; //[6:25:0.1]
connector_H = 8; //[4:20:0.1]
connector_L = 6; //[3:20:0.1]
label_W = 18; //[8:40:0.1]
label_H = 12; //[6:30:0.1]
label_th = 0.8; //[0.4:3:0.1]
fillet_r = 1; //[0.5:3:0.1]

// Base Shapes
module motor_body() {
  color("Black")
  cube([body_W, body_H, body_L], center=true);
}

module front_face() {
  color("DimGray")
  translate([0, 0, body_L/2 + face_th/2 - overlap])
    cube([face_W, face_W, face_th], center=true);
}

module front_boss() {
  color("Silver")
  translate([0, 0, body_L/2 + face_th + boss_th/2 - overlap])
    cylinder(r=boss_d/2, h=boss_th, center=true);
}

module rear_cap() {
  color("DimGray")
  translate([0, 0, -body_L/2 - rear_cap_th/2 + overlap])
    cube([body_W, body_H, rear_cap_th], center=true);
}

module output_shaft() {
  color("Silver")
  translate([0, 0, body_L/2 + face_th + boss_th + shaft_L/2 - overlap])
    cylinder(r=shaft_d/2, h=shaft_L, center=true);
}

module mounting_hole(x, y) {
  translate([x, y, body_L/2 + face_th/2 - overlap])
    cylinder(r=mount_hole_d/2, h=mount_hole_depth, center=true);
}

module shaft_flat_cut() {
  translate([shaft_d/2 - shaft_flat_depth/2, 0, body_L/2 + face_th + boss_th + shaft_flat_L/2 - overlap])
    cube([shaft_d, shaft_d, shaft_flat_L], center=true);
}

module connector_bump() {
  color("DimGray")
  translate([0, 0, -body_L/2 - rear_cap_th - connector_L/2 + overlap])
    cube([connector_W, connector_H, connector_L], center=true);
}

module label_plate() {
  color("DimGray")
  translate([body_W/2 + label_th/2 - overlap, 0, 0])
    cube([label_th, label_H, label_W], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module mounting_holes() {
  union() {
    mounting_hole(mount_spacing/2, mount_spacing/2);
    mounting_hole(-mount_spacing/2, mount_spacing/2);
    mounting_hole(-mount_spacing/2, -mount_spacing/2);
    mounting_hole(mount_spacing/2, -mount_spacing/2);
  }
}

module motor_union_raw() {
  union() {
    motor_body();
    front_face();
    front_boss();
    rear_cap();
    output_shaft();
    connector_bump();
    label_plate();
  }
}

module motor_with_mount_holes() {
  difference() {
    motor_union_raw();
    mounting_holes();
  }
}

module motor_with_shaft_flat() {
  difference() {
    motor_with_mount_holes();
    shaft_flat_cut();
  }
}

// Final Output
minkowski() {
  motor_with_shaft_flat();
  fillet_sphere();
}