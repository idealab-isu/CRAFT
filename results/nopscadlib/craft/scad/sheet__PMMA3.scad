// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:4:0.5]

// Safeguards to ensure visible, non-degenerate geometry
min_th = 0.5;   // keep at least 0.5mm so renders don't look blank
eps = 0.01;

// Geometry
module sheet_body() {
  color([0.85, 0.85, 0.8])
    cube([sheet_length, sheet_width, max(sheet_thickness, min_th) + eps], center=true);
}

// Final Output (single connected solid)
sheet_body();