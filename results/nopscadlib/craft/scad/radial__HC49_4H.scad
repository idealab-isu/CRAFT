// Parameters
outer_diameter = 10.5; //[5.25:21:0.1]
inner_diameter = 3.5; //[1.75:7:0.1]
height = 3.7; //[1.85:7.4:0.1]
outer_radius = 5.25; //[2.625:10.5:0.1]
inner_radius = 1.75; //[0.875:3.5:0.1]
overlap = 0.8; //[0.5:2:0.1]
chamfer_size = 0.6; //[0.3:1.2:0.1]
fillet_radius = 0.5; //[0.25:1:0.05]

// Base Shapes
module radial_outer_cyl() {
  translate([0, 0, 0])
    cylinder(h=height, r=outer_diameter/2, center=true);
}

module radial_inner_hole_cyl() {
  translate([0, 0, 0])
    cylinder(h=height + 2*overlap, r=inner_diameter/2, center=true);
}

module edge_chamfer_cyl() {
  translate([0, 0, height/2 - chamfer_size/2 + overlap/2])
    cylinder(h=chamfer_size, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module edge_fillet_torus() {
  translate([0, 0, -height/2 + fillet_radius - overlap/2])
    rotate_extrude() 
      translate([outer_diameter/2 - fillet_radius, 0, 0])
        circle(r=fillet_radius);
}

// Operations
module radial_body() {
  difference() {
    radial_outer_cyl();
    radial_inner_hole_cyl();
  }
}

module edge_chamfer() {
  difference() {
    radial_body();
    edge_chamfer_cyl();
  }
}

module edge_fillet() {
  union() {
    edge_chamfer();
    edge_fillet_torus();
  }
}

// Final Output
color("Silver") edge_fillet();