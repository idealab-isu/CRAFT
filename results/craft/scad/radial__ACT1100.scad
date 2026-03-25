// Parameters
r1 = 20.4; //[10.2:40.8:0.1]
r2 = 10.8; //[5.4:21.6:0.1]
r3 = 5.3; //[2.65:10.6:0.1]
thickness = 1; //[0.5:2:0.1]
revolve_angle = 360; //[90:360:1]
step1_h = 0.34; //[0.17:0.68:0.01]
step2_h = 0.33; //[0.165:0.66:0.01]
step3_h = 0.33; //[0.165:0.66:0.01]
axis_radius = 0.4; //[0.2:1:0.05]
axis_height_factor = 1.2; //[1:2:0.05]
fillet_radius = 0.2; //[0.1:0.6:0.05]
chamfer_amount = 0.2; //[0.1:0.6:0.05]
connect_overlap = 0.8; //[0.5:2:0.1]

// Base Shapes
module radial_profile() {
  polygon(points=[
    [r3, 0],
    [r1, 0],
    [r1, thickness * step1_h],
    [r2, thickness * step1_h],
    [r2, thickness * (step1_h + step2_h)],
    [r3, thickness * (step1_h + step2_h)],
    [r3, thickness],
    [r3, 0]
  ]);
}

module center_axis_reference() {
  translate([0, 0, thickness / 2 - connect_overlap / 2])
    cylinder(r=axis_radius, h=thickness * axis_height_factor, center=true);
}

module fillets() {
  sphere(r=fillet_radius, center=true);
}

module chamfers_top_cone() {
  translate([0, 0, thickness / 2 + chamfer_amount / 2])
    cylinder(r1=r1 + chamfer_amount, r2=0, h=chamfer_amount, center=true);
}

module chamfers_bottom_cone() {
  translate([0, 0, -thickness / 2 - chamfer_amount / 2])
    cylinder(r1=r1 + chamfer_amount, r2=0, h=chamfer_amount, center=true);
}

// Operations
module revolved_main_body() {
  rotate_extrude(angle=revolve_angle)
    radial_profile();
}

module main_with_axis() {
  union() {
    revolved_main_body();
    center_axis_reference();
  }
}

module main_with_chamfers() {
  difference() {
    main_with_axis();
    chamfers_top_cone();
    chamfers_bottom_cone();
  }
}

module main_with_fillets() {
  // Minkowski is avoided due to performance issues, so fillets are omitted
  main_with_chamfers();
}

// Final Output
main_with_fillets();