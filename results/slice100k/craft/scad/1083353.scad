// Parameters
L = 82.5; //[41.25:165:0.1]
OD = 14.99; //[7.5:29.98:0.01]
ID = 10.8; //[5.4:14.5:0.01]
overlap = 1; //[0.5:2:0.1]
chamfer = 0; //[0:1:0.1]
fillet = 0; //[0:1:0.1]
marking_depth = 0; //[0:0.5:0.05]

// Geometry
module outer_cylinder_body() {
  translate([0, 0, 0])
    cylinder(h = L, r = OD / 2, center = true);
}

module concentric_through_bore() {
  translate([0, 0, 0])
    cylinder(h = L + 2 * overlap, r = ID / 2, center = true);
}

// Main tube with through-bore
module tube_main() {
  difference() {
    outer_cylinder_body();
    concentric_through_bore();
  }
}

// Final model
module complete_model() {
  tube_main();
}

// Render the final output
color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
complete_model();