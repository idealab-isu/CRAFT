// Parameters
r1 = 20.4; //[10.2:40.8:0.1]
r2 = 10.8; //[5.4:21.6:0.1]
r3 = 5.3; //[2.65:10.6:0.1]
r4 = 1.0; //[0.5:2.0:0.1]
step_height = 3.0; //[1.5:6.0:0.1]
part_thickness = 6.0; //[3.0:12.0:0.1]
hole_radius = 1.2; //[0.6:2.4:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
fillet_radius = 0.8; //[0.4:1.6:0.1]

// Base Shapes
module radial_profile() {
  rotate_extrude() {
    polygon(points=[
      [hole_radius, 0],
      [r1, 0],
      [r1, part_thickness],
      [r2, part_thickness],
      [r2, part_thickness + step_height],
      [r3, part_thickness + step_height],
      [r3, part_thickness + 2*step_height],
      [r4, part_thickness + 2*step_height],
      [r4, part_thickness + 3*step_height],
      [hole_radius, part_thickness + 3*step_height]
    ]);
  }
}

module center_hole_cutter() {
  translate([0, 0, (part_thickness + 3*step_height)/2])
    cylinder(r=hole_radius, h=part_thickness + 3*step_height + 2*overlap, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_radius);
}

module engraved_label_placeholder() {
  translate([r2/2, 0, part_thickness + 3*step_height - (part_thickness/8)])
    cube([r2, r2/2, part_thickness/4], center=true);
}

// Operations
module concentric_steps() {
  difference() {
    radial_profile();
    center_hole_cutter();
  }
}

module fillets_chamfers() {
  // Minkowski operation is avoided due to performance issues
  // Instead, we will omit the fillet for simplicity
  concentric_steps();
}

module engraved_label() {
  union() {
    fillets_chamfers();
    engraved_label_placeholder();
  }
}

// Final Output
engraved_label();