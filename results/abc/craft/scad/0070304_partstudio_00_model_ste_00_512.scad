// Parameters
L = 0.09; //[0.045:0.18:0.001]
W = 0.04; //[0.02:0.08:0.001]
T = 0.04; //[0.02:0.08:0.001]
L_base = 0.05; //[0.025:0.1:0.001]
L_tongue = 0.04; //[0.02:0.08:0.001]
W_tongue = 0.024; //[0.012:0.048:0.001]
tip_r = 0.012; //[0.006:0.024:0.001]
step_x = 0.05; //[0.025:0.1:0.001]
hex_large_af = 0.016; //[0.008:0.032:0.001]
hex_large_x = 0.022; //[0.011:0.044:0.001]
hex_large_y = 0.0; //[-0.01:0.01:0.001]
hex_small_af = 0.008; //[0.004:0.016:0.001]
hex_small_center_x = 0.072; //[0.036:0.144:0.001]
hex_small_dx = 0.01; //[0.005:0.02:0.001]
hex_small_dy = 0.01; //[0.005:0.02:0.001]
hole_extra_h = 0.02; //[0.01:0.04:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
edge_fillet_r = 0.001; //[0.0:0.004:0.0005]

// Helper function to create a hexagonal hole
module hex_hole(radius, height) {
  rotate([0, 0, 30])
  cylinder(h=height, r=radius, $fn=6);
}

// Main body of the plate
module plate_main_body() {
  translate([L_base/2, 0, 0])
  cube([L_base, W, T], center=true);
}

// Tongue section with rounded tip
module plate_tongue_with_rounded_tip() {
  union() {
    translate([step_x + (L_tongue - tip_r)/2 - overlap, 0, 0])
    cube([L_tongue - tip_r, W_tongue, T], center=true);
    translate([step_x + (L_tongue - tip_r) - overlap, 0, 0])
    cylinder(r=tip_r, h=T, center=true);
  }
}

// Step transition shoulder
module step_transition_shoulder() {
  translate([step_x - overlap, 0, 0])
  cube([overlap*2, W, T], center=true);
}

// Large hexagonal hole
module hex_hole_large() {
  translate([hex_large_x, hex_large_y, 0])
  hex_hole(hex_large_af/1.7320508075688772, T + hole_extra_h);
}

// Small hexagonal holes in 2x2 pattern
module hex_hole_small_pattern() {
  for (x = [-hex_small_dx/2, hex_small_dx/2])
    for (y = [-hex_small_dy/2, hex_small_dy/2])
      translate([hex_small_center_x + x, y, 0])
      hex_hole(hex_small_af/1.7320508075688772, T + hole_extra_h);
}

// Edge fillets or chamfers
module edge_fillets_or_chamfers() {
  if (edge_fillet_r > 0) {
    minkowski() {
      plate_with_holes();
      sphere(r=edge_fillet_r, center=true);
    }
  } else {
    plate_with_holes();
  }
}

// Plate with holes
module plate_with_holes() {
  difference() {
    union() {
      plate_main_body();
      plate_tongue_with_rounded_tip();
      step_transition_shoulder();
    }
    hex_hole_large();
    hex_hole_small_pattern();
  }
}

// Final model
module final_model() {
  union() {
    edge_fillets_or_chamfers();
    translate([L_base/2, 0, 0])
    cube([overlap*2, overlap*2, overlap*2], center=true);
  }
}

// Render the final model
final_model();