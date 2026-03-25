// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:4:0.5]

// Ensure non-zero printable thickness to avoid "blank" renders
min_th = 0.2;
th = max(sheet_thickness, min_th);

// Geometry
module sheet_body() {
  color([0.85, 0.85, 0.8])
    cube([sheet_length, sheet_width, th], center=true);
}

// Final Output (one connected solid)
sheet_body();