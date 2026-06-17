$fn=128;

// Brushless DC motor (approximate) with 42.5mm stator diameter and 48.0mm height
// Model includes: main can, front face, rear cap, shaft, mounting flange, and simple wire exit.

stator_d = 42.5;
motor_h  = 48.0;

// Assumed/typical proportions for a 42mm-class BLDC motor
can_wall = 1.2;
can_d    = stator_d + 2*can_wall;     // outer can diameter
front_face_th = 2.0;
rear_cap_th   = 2.5;

shaft_d  = 5.0;
shaft_len_front = 18.0;
shaft_len_rear  = 2.0;

flange_d = can_d + 6.0;
flange_th = 2.5;

mount_hole_d = 3.2;
mount_hole_circle_d = 31.0; // typical for 42mm motors
mount_hole_count = 4;

wire_exit_w = 8.0;
wire_exit_h = 5.0;
wire_exit_len = 10.0;

module bolt_circle_holes(count, circle_d, hole_d, th){
  for(i=[0:count-1]){
    a = 360*i/count;
    translate([circle_d/2*cos(a), circle_d/2*sin(a), -0.1])
      cylinder(d=hole_d, h=th+0.2);
  }
}

module motor_body(){
  // Main can (hollow)
  difference(){
    cylinder(d=can_d, h=motor_h);
    translate([0,0,front_face_th])
      cylinder(d=can_d-2*can_wall, h=motor_h-front_face_th-rear_cap_th);
  }

  // Front face plate (solid)
  cylinder(d=can_d, h=front_face_th);

  // Rear cap (solid)
  translate([0,0,motor_h-rear_cap_th])
    cylinder(d=can_d, h=rear_cap_th);

  // Front mounting flange with holes
  difference(){
    translate([0,0,0])
      cylinder(d=flange_d, h=flange_th);
    bolt_circle_holes(mount_hole_count, mount_hole_circle_d, mount_hole_d, flange_th);
    // center bore for shaft clearance
    translate([0,0,-0.1]) cylinder(d=shaft_d+2.0, h=flange_th+0.2);
  }

  // Shaft (front + slight rear stub)
  translate([0,0,-shaft_len_front])
    cylinder(d=shaft_d, h=shaft_len_front + front_face_th);

  translate([0,0,motor_h])
    cylinder(d=shaft_d, h=shaft_len_rear);

  // Simple wire exit block on rear side
  translate([can_d/2 - wire_exit_w/2, 0, motor_h - rear_cap_th - wire_exit_h])
    rotate([0,0,0])
      cube([wire_exit_len, wire_exit_w, wire_exit_h], center=false);
}

motor_body();