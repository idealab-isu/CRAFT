// Dimension-calibrated (target: 0.03 x 0.03 x 0.02 mm)
scale([0.866066, 0.833367, 1.100079])
{
// Flanged bushing/spacer: cylindrical sleeve + hex flange, no holes/recesses

// Parameters (meters as given)
bbox_X = 0.03; //[0.015:0.06:0.001]
bbox_Y = 0.03; //[0.015:0.06:0.001]
bbox_Z = 0.02; //[0.01:0.04:0.001]

body_d = 0.018; //[0.009:0.036:0.001]
body_h = 0.012; //[0.006:0.024:0.001]

flange_hex_flat_to_flat = 0.03; //[0.015:0.06:0.001]
flange_h = 0.008; //[0.004:0.016:0.001]

interface_overlap_h = 0.001; //[0.0005:0.002:0.0005]
eps = 0.0005; //[0.0001:0.001:0.0001]

// Derived
total_h = body_h + flange_h;
hex_R = flange_hex_flat_to_flat / sqrt(3); // circumradius for flat-to-flat dimension

// Main solids (one connected solid)
module cyl_sleeve_body() {
  // Body sits below flange; overlap ensures watertight union
  translate([0, 0, -total_h/2 + body_h/2 + interface_overlap_h/2])
    cylinder(r=body_d/2, h=body_h + interface_overlap_h, center=true, $fn=96);
}

module hex_flange_collar() {
  // Flange at top
  translate([0, 0, total_h/2 - flange_h/2])
    cylinder(r=hex_R, h=flange_h, center=true, $fn=6);
}

union() {
  cyl_sleeve_body();
  hex_flange_collar();
}
}
