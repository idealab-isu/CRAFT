// Parameters
body_diameter = 12.6; //[6.3:25.2:0.1]
body_height = 13.1; //[6.55:26.2:0.1]
eps = 0.8; //[0.5:2:0.1]
top_face_thickness = 0.8; //[0.4:2:0.1]
bottom_face_thickness = 0.8; //[0.4:2:0.1]
lever_diameter = 3.5; //[2:7:0.1]
lever_height = 18; //[8:36:0.5]
thread_diameter = 6.35; //[3:12.7:0.05]
thread_height = 8; //[4:16:0.5]
nut_flat_width = 10; //[6:20:0.5]
nut_thickness = 2.5; //[1.5:5:0.1]
washer_diameter = 12; //[8:24:0.5]
washer_thickness = 1; //[0.5:2.5:0.1]
lug_width = 4; //[2:8:0.1]
lug_thickness = 1.2; //[0.6:3:0.1]
lug_length = 6; //[3:12:0.5]
lug_drop = 6; //[3:12:0.5]
anti_flat_depth = 1; //[0.5:2.5:0.1]
anti_flat_height = 6; //[3:12:0.5]
fillet_radius = 0.6; //[0.2:2:0.1]

// Base Shapes
module switch_body_cylinder() {
  translate([0, 0, 0])
    cylinder(r=body_diameter/2, h=body_height, center=true);
}

module top_face() {
  translate([0, 0, body_height/2 - top_face_thickness/2])
    cylinder(r=body_diameter/2, h=top_face_thickness, center=true);
}

module bottom_face() {
  translate([0, 0, -body_height/2 + bottom_face_thickness/2])
    cylinder(r=body_diameter/2, h=bottom_face_thickness, center=true);
}

module toggle_lever() {
  translate([0, 0, body_height/2 + lever_height/2 - eps])
    cylinder(r=lever_diameter/2, h=lever_height, center=true);
}

module mounting_thread() {
  translate([0, 0, body_height/2 + thread_height/2 - eps])
    cylinder(r=thread_diameter/2, h=thread_height, center=true);
}

module mounting_nut_outer() {
  translate([0, 0, body_height/2 + washer_thickness + nut_thickness/2 - eps])
    cylinder(r=nut_flat_width/2, h=nut_thickness, center=true);
}

module mounting_nut_hole() {
  translate([0, 0, body_height/2 + washer_thickness + nut_thickness/2 - eps])
    cylinder(r=thread_diameter/2 + eps/4, h=nut_thickness + eps, center=true);
}

module washer_outer() {
  translate([0, 0, body_height/2 + washer_thickness/2 - eps])
    cylinder(r=washer_diameter/2, h=washer_thickness, center=true);
}

module washer_hole() {
  translate([0, 0, body_height/2 + washer_thickness/2 - eps])
    cylinder(r=thread_diameter/2 + eps/4, h=washer_thickness + eps, center=true);
}

module terminal_lug_1() {
  translate([body_diameter/2 + lug_length/2 - eps, 0, -body_height/2 + lug_drop])
    cube([lug_length, lug_width, lug_thickness], center=true);
}

module terminal_lug_2() {
  translate([-(body_diameter/2 + lug_length/2 - eps), 0, -body_height/2 + lug_drop])
    cube([lug_length, lug_width, lug_thickness], center=true);
}

module terminal_lug_3() {
  translate([0, body_diameter/2 + lug_length/2 - eps, -body_height/2 + lug_drop])
    cube([lug_length, lug_width, lug_thickness], center=true);
}

module anti_rotation_flat_cut() {
  translate([body_diameter/2 - anti_flat_depth, 0, body_height/2 - anti_flat_height/2])
    cube([anti_flat_depth*2, body_diameter*2, anti_flat_height], center=true);
}

module fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_radius, center=true);
}

// Operations
module mounting_nut() {
  difference() {
    mounting_nut_outer();
    mounting_nut_hole();
  }
}

module washer() {
  difference() {
    washer_outer();
    washer_hole();
  }
}

module body_with_faces() {
  union() {
    switch_body_cylinder();
    top_face();
    bottom_face();
  }
}

module body_with_flat() {
  difference() {
    body_with_faces();
    anti_rotation_flat_cut();
  }
}

module body_with_secondary_features() {
  union() {
    body_with_flat();
    mounting_thread();
    toggle_lever();
    mounting_nut();
    washer();
    terminal_lug_1();
    terminal_lug_2();
    terminal_lug_3();
  }
}

module fillets_chamfers() {
  minkowski() {
    body_with_secondary_features();
    fillet_sphere();
  }
}

// Final Output
fillets_chamfers();