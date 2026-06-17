// Parameters (thin sheet with sharp corners)
sheet_length = 100;
sheet_width  = 50;
sheet_thickness = 0.6;   // thinner to read as a sheet
corner_radius = 0;       // sharp corners

// Main sheet (ONE connected solid)
cube([sheet_length, sheet_width, sheet_thickness], center=true);