// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:4:0.5]

// Geometry
module sheet_body() {
  color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
  translate([0, 0, 0])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

// Final Output
union() {
  sheet_body();
}