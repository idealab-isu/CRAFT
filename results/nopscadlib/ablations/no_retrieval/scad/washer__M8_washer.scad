// Parameters
id = 8.0; //[4.0:16.0:0.1]
od = 17.0; //[8.5:34.0:0.1]
thickness = 1.6; //[0.8:3.2:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
chamfer_size = 0.3; //[0.1:0.8:0.05]
fillet_radius = 0.2; //[0.1:0.6:0.05]

// Base Shapes
module washer_outer_cyl() {
  cylinder(r=od/2, h=thickness, center=true);
}

module washer_inner_hole_cyl() {
  cylinder(r=id/2, h=thickness + 2*overlap, center=true);
}

module chamfer_outer_top_cone() {
  translate([0, 0, thickness/2 - chamfer_size/2 + overlap/2])
    cylinder(r1=od/2, r2=0, h=chamfer_size, center=true);
}

module chamfer_outer_bottom_cone() {
  translate([0, 0, -thickness/2 + chamfer_size/2 - overlap/2])
    rotate([180, 0, 0])
    cylinder(r1=od/2, r2=0, h=chamfer_size, center=true);
}

module chamfer_inner_top_cone() {
  translate([0, 0, thickness/2 - chamfer_size/2 + overlap/2])
    rotate([180, 0, 0])
    cylinder(r1=id/2 + chamfer_size, r2=0, h=chamfer_size, center=true);
}

module chamfer_inner_bottom_cone() {
  translate([0, 0, -thickness/2 + chamfer_size/2 - overlap/2])
    cylinder(r1=id/2 + chamfer_size, r2=0, h=chamfer_size, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_radius, center=true);
}

// Operations
module washer_body() {
  difference() {
    washer_outer_cyl();
    washer_inner_hole_cyl();
  }
}

module edge_chamfers() {
  difference() {
    washer_body();
    chamfer_outer_top_cone();
    chamfer_outer_bottom_cone();
    chamfer_inner_top_cone();
    chamfer_inner_bottom_cone();
  }
}

// Final Output
module edge_fillets() {
  minkowski() {
    edge_chamfers();
    fillet_sphere();
  }
}

// Render the final washer with edge fillets
color("Silver") edge_fillets();