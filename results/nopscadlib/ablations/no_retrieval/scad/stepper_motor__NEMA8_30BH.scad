// Parameters
face_W = 20.0; //[10.0:40.0:0.5]
face_H = 20.0; //[10.0:40.0:0.5]
body_L = 30.0; //[15.0:60.0:0.5]
body_W = 20.0; //[10.0:40.0:0.5]
body_H = 20.0; //[10.0:40.0:0.5]
face_thk = 2.0; //[1.0:6.0:0.25]
shaft_d = 5.0; //[2.5:10.0:0.25]
shaft_L = 15.0; //[7.5:30.0:0.5]
mount_spacing = 16.0; //[8.0:32.0:0.5]
mount_hole_d = 3.0; //[1.5:6.0:0.25]
boss_d = 10.0; //[5.0:20.0:0.5]
boss_thk = 2.0; //[1.0:6.0:0.25]
rear_cap_thk = 2.0; //[1.0:6.0:0.25]
wire_exit_d = 6.0; //[3.0:12.0:0.5]
wire_exit_L = 10.0; //[5.0:25.0:0.5]
fillet_r = 1.5; //[0.5:4.0:0.25]
nameplate_W = 12.0; //[6.0:24.0:0.5]
nameplate_H = 8.0; //[4.0:16.0:0.5]
nameplate_thk = 0.6; //[0.3:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module motor_body_raw() {
  cube([body_W, body_H, body_L], center=true);
}

module corner_fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module front_face() {
  cube([face_W, face_H, face_thk], center=true);
}

module shaft_boss() {
  cylinder(h=boss_thk, r=boss_d/2, center=true);
}

module output_shaft() {
  cylinder(h=shaft_L, r=shaft_d/2, center=true);
}

module rear_cap() {
  cube([body_W, body_H, rear_cap_thk], center=true);
}

module wire_exit() {
  cylinder(h=wire_exit_L, r=wire_exit_d/2, center=true);
}

module nameplate_detail() {
  cube([nameplate_W, nameplate_H, nameplate_thk], center=true);
}

module mount_hole() {
  cylinder(h=face_thk + boss_thk + overlap*2, r=mount_hole_d/2, center=true);
}

// Operations
module motor_body_fillet() {
  minkowski() {
    motor_body_raw();
    corner_fillet_sphere();
  }
}

module mounting_holes_pattern() {
  union() {
    translate([mount_spacing/2, mount_spacing/2, 0]) mount_hole();
    translate([-mount_spacing/2, mount_spacing/2, 0]) mount_hole();
    translate([-mount_spacing/2, -mount_spacing/2, 0]) mount_hole();
    translate([mount_spacing/2, -mount_spacing/2, 0]) mount_hole();
  }
}

module motor_solid_preholes() {
  union() {
    motor_body_fillet();
    translate([0, 0, body_L/2 + face_thk/2 - overlap]) front_face();
    translate([0, 0, body_L/2 + face_thk + boss_thk/2 - overlap]) shaft_boss();
    translate([0, 0, body_L/2 + face_thk + boss_thk + shaft_L/2 - overlap]) output_shaft();
    translate([0, 0, -body_L/2 - rear_cap_thk/2 + overlap]) rear_cap();
    translate([0, 0, -body_L/2 - rear_cap_thk - wire_exit_L/2 + overlap]) wire_exit();
    translate([0, 0, -body_L/2 + nameplate_thk/2 - overlap]) nameplate_detail();
  }
}

module motor_complete() {
  difference() {
    motor_solid_preholes();
    translate([0, 0, body_L/2 + face_thk/2 - overlap]) mounting_holes_pattern();
  }
}

// Final Output
motor_complete();