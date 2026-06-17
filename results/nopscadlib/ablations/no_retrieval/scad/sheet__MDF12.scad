// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:4:0.5]

// Ensure renderable thickness (avoid near-zero that can look blank in some viewers)
min_t = 0.5;
t = max(sheet_thickness, min_t);

// Geometry
module sheet_body() {
  cube([sheet_length, sheet_width, t], center=true);
}

// Final Output (one connected solid)
sheet_body();