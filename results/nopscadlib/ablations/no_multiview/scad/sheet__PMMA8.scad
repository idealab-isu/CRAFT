// Parameters
sheet_length = 100; //[50:200:1]
sheet_width = 100; //[50:200:1]
sheet_thickness = 7.94; //[3.97:15.88:0.01]

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