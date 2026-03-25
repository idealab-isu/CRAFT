// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]

// Robust minimum thickness to avoid degenerate/blank renders
min_t = 0.5;
t = max(sheet_thickness, min_t);

// Geometry (one connected solid)
color([0.85, 0.85, 0.8])
cube([sheet_length, sheet_width, t], center=true);