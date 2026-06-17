// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 200; //[100:400:1]
sheet_T = 2;   //[1:6:0.5]

// Robust thickness to avoid blank renders (e.g., too-thin for viewer precision)
min_T = 0.5;
T = max(sheet_T, min_T);

// Geometry (one connected solid)
color([0.85, 0.85, 0.8])
    cube([sheet_L, sheet_W, T], center=true);