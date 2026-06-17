// Parameters
body_length = 3.0; //[1.5:6.0:0.05]
body_width = 1.6; //[0.8:3.2:0.05]
body_height = 1.05; //[0.5:2.1:0.05]

// Geometry
module smd_body() {
  color([0.85, 0.85, 0.8]) // Off-white for SMD component
  translate([0, 0, 0])
    cube([body_length, body_width, body_height], center=true);
}

// Final Output
smd_body();