// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 150; //[75:300:1]
sheet_T = 2;   //[1:4:0.5]

// Robust thickness to avoid blank/empty renders due to near-zero Z
min_T = 0.5;
t = max(sheet_T, min_T);

// Geometry (one connected solid)
color([0.85, 0.85, 0.8])
cube([sheet_L, sheet_W, t], center=true);