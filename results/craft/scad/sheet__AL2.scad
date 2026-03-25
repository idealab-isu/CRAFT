// Aluminium tooling plate sheet (no holes, no labels)

// Parameters
plate_length    = 300;   //[150:600:1]
plate_width     = 200;   //[100:400:1]
plate_thickness = 12;    //[6:24:1]

// Optional edge treatment
corner_chamfer_leg = 0;  //[0:6:1]

eps = 0.01;

// Base plate
module tooling_plate_body() {
  cube([plate_length, plate_width, plate_thickness], center=true);
}

// Corner chamfer cutter (triangular prism) positioned to remove material at each corner
module corner_chamfer_cut() {
  // Extrude along Z, centered, so it fully spans the plate thickness
  linear_extrude(height=plate_thickness + 2*eps, center=true)
    polygon(points=[[0,0],[corner_chamfer_leg,0],[0,corner_chamfer_leg]]);
}

module corner_chamfers() {
  // Place each cutter so its right-angle vertex sits exactly at the plate corner.
  // Use formulas derived from plate dimensions; no arbitrary offsets.
  translate([ plate_length/2 - corner_chamfer_leg,  plate_width/2 - corner_chamfer_leg, 0])
    corner_chamfer_cut();

  translate([-plate_length/2 + corner_chamfer_leg,  plate_width/2 - corner_chamfer_leg, 0])
    rotate([0,0, 90]) corner_chamfer_cut();

  translate([-plate_length/2 + corner_chamfer_leg, -plate_width/2 + corner_chamfer_leg, 0])
    rotate([0,0,180]) corner_chamfer_cut();

  translate([ plate_length/2 - corner_chamfer_leg, -plate_width/2 + corner_chamfer_leg, 0])
    rotate([0,0,-90]) corner_chamfer_cut();
}

// Final model: one connected solid
color([0.78, 0.78, 0.80])  // aluminium-like silver/grey
difference() {
  tooling_plate_body();
  if (corner_chamfer_leg > 0)
    corner_chamfers();
}