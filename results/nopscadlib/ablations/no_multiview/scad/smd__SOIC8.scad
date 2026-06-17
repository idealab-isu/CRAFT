// Parameters
body_length = 4.9; //[2.45:9.8:0.05]
body_width = 3.9; //[1.95:7.8:0.05]
body_height = 1.25; //[0.6:2.5:0.05]

// SMD Package Module
module smd_package() {
  color([0.85, 0.85, 0.8]) // Off-white for SMD package
  translate([0, 0, 0])
    cube([body_length, body_width, body_height], center=true);
}

// Final Output
smd_package();