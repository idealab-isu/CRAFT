// Parameters
across_flats = 5.5; //[2.75:11:0.05]
thickness = 1.8; //[0.9:3.6:0.05]
hole_diameter = 3.2; //[2.6:4.2:0.05]
chamfer = 0.2; //[0.1:0.6:0.05]
overlap = 0.6; //[0.2:1.5:0.05]
hex_radius = 3.175; //[1.5:6.5:0.01]
chamfer_radius_delta = 0.231; //[0.05:1:0.001]
thread_detail_diameter = 3.0; //[2.5:3.6:0.05]
thread_detail_height = 0.6; //[0.2:1.2:0.05]
fillet_radius = 0.15; //[0.05:0.4:0.05]

// Base Shapes
module hex_nut_body() {
  rotate([0, 0, 30])
    cylinder(r=hex_radius, h=thickness, center=true, $fn=6);
}

module hex_nut_body_chamfered_outer() {
  rotate([0, 0, 30])
    cylinder(r=hex_radius - chamfer_radius_delta, h=thickness - 2*chamfer, center=true, $fn=6);
}

module center_hole() {
  cylinder(r=hole_diameter/2, h=thickness + 2*overlap, center=true);
}

module threaded_hole_detail() {
  cylinder(r=thread_detail_diameter/2, h=thread_detail_height, center=true);
}

module fillets_sphere() {
  sphere(r=fillet_radius);
}

module engraved_markings() {
  translate([0, 0, thickness/2 - chamfer/2])
    cube([across_flats*0.6, across_flats*0.2, chamfer], center=true);
}

// Operations
module edge_chamfers() {
  hull() {
    hex_nut_body();
    hex_nut_body_chamfered_outer();
  }
}

module nut_with_hole() {
  difference() {
    edge_chamfers();
    center_hole();
  }
}

module nut_with_thread_detail() {
  difference() {
    nut_with_hole();
    threaded_hole_detail();
  }
}

module nut_with_fillets() {
  minkowski() {
    nut_with_thread_detail();
    fillets_sphere();
  }
}

module final_nut() {
  difference() {
    nut_with_fillets();
    engraved_markings();
  }
}

// Final Output
color("Silver") final_nut();