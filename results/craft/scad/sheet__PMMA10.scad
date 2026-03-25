// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:4:0.5]

// Robust thickness to avoid degenerate/blank renders
t = (sheet_thickness > 0) ? sheet_thickness : 0.2;

// Geometry (one connected solid)
color([0.85, 0.85, 0.8])
cube([sheet_length, sheet_width, t], center=true);