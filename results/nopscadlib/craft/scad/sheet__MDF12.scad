// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]

// Robust, always-renderable thickness (avoid near-zero/blank renders)
t = max(sheet_thickness, 1);

// Geometry
module sheet_body() {
  cube([sheet_length, sheet_width, t], center=true);
}

// Final Output (one connected solid)
sheet_body();