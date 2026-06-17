// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]

// Robust thickness to avoid blank/empty renders (e.g., too-thin preview artifacts)
min_thickness = 1.0;
t = max(sheet_thickness, min_thickness);

// Geometry (one connected solid)
color([0.85, 0.85, 0.8])
cube([sheet_length, sheet_width, t], center=true);