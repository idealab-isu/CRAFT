// Sheet mild steel (single connected solid)

// Parameters
sheet_length = 300;      //[150:600:1]
sheet_width  = 200;      //[100:400:1]
sheet_thickness = 3;     //[1.5:6:0.5]

// Robustness (avoid blank/near-zero thickness renders)
min_th = 0.5;
t = max(sheet_thickness, min_th);

// Geometry (one connected solid)
module sheet_plate() {
    color([0.35, 0.35, 0.35])
        cube([sheet_length, sheet_width, t], center=true);
}

// Final Output
sheet_plate();