// Parameters
sheet_length = 200; //[100:400:1]
sheet_width  = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]

$fn = 64;

// Final Output: simple rectangular sheet (no holes)
cube([sheet_length, sheet_width, sheet_thickness], center=true);