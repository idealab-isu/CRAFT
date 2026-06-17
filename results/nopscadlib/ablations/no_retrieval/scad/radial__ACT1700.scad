// Parameters
outer_radius = 10.8; //[5.4:21.6:0.1]
inner_radius = 8.0; //[4.0:16.0:0.1]
height = 5.3; //[2.65:10.6:0.1]
resolution_factor = 1; //[0.5:2:0.1]
overlap = 1; //[0.5:2:0.1]
chamfer_size = 0.6; //[0.3:1.2:0.05]
fillet_radius = 0.6; //[0.3:1.2:0.05]

// Base Shapes
module outer_cylinder() {
  cylinder(h=height, r=outer_radius, center=true);
}

module inner_bore() {
  cylinder(h=height + 2*overlap, r=inner_radius, center=true);
}

module edge_chamfer() {
  translate([0, 0, height/2 - (chamfer_size*resolution_factor)/2 + overlap/2])
    cylinder(h=chamfer_size*resolution_factor, r1=outer_radius, r2=outer_radius - chamfer_size*resolution_factor, center=true);
}

module edge_fillet() {
  translate([0, 0, height/2 - fillet_radius*resolution_factor + overlap/2])
    rotate_extrude() 
      translate([outer_radius - fillet_radius*resolution_factor, 0, 0])
        circle(r=fillet_radius*resolution_factor);
}

// Operations
module ring_body() {
  difference() {
    outer_cylinder();
    inner_bore();
  }
}

module ring_minus_chamfer() {
  difference() {
    ring_body();
    edge_chamfer();
  }
}

module final_ring() {
  union() {
    ring_minus_chamfer();
    edge_fillet();
  }
}

// Final Output
final_ring();