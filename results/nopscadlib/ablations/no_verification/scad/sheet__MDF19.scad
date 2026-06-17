// A generic sheet (single connected solid)

// Parameters
sheet_length = 200;      //[100:400:1]
sheet_width  = 150;      //[75:300:1]
sheet_thickness = 2;     //[1:6:0.5]

// Ensure non-zero, renderable thickness
min_th = 0.5;
t = max(sheet_thickness, min_th);

// Sheet
color("Silver")
cube([sheet_length, sheet_width, t], center=true);