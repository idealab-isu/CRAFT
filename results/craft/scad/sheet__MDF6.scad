// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]

// Robust minimums to avoid "blank" renders from degenerate geometry
min_thickness = 0.8;
min_xy = 1;

L = max(sheet_length, min_xy);
W = max(sheet_width,  min_xy);
t = max(sheet_thickness, min_thickness);

// Geometry (one connected solid)
color([0.85, 0.85, 0.8])
cube([L, W, t], center=true);