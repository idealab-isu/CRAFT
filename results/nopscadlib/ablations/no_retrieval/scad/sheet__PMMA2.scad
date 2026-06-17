// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.1]
corner_radius = 5;  //[0:20:0.5]
film_thickness = 0.1; //[0.05:0.3:0.01]
overlap = 0.2; //[0.05:1:0.01]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

min_dim = min(sheet_length, sheet_width);
cr = clamp(corner_radius, 0, min_dim/2 - 0.001);

// Ensure valid 2D core size for offset()
core_L = max(sheet_length - 2*cr, 0.01);
core_W = max(sheet_width  - 2*cr, 0.01);

// Keep overlap sane so film always intersects sheet
ov = clamp(overlap, 0.001, film_thickness - 0.001);

// 2D rounded rectangle (robust)
module rounded_rect_2d(L, W, R) {
  if (R <= 0)
    square([L, W], center=true);
  else
    offset(r=R) square([L, W], center=true);
}

// Acrylic sheet (single solid; film is fused into it via overlap)
module acrylic_with_film() {
  // Visual acrylic tint (translucent)
  color([0.85, 0.95, 1.0, 0.25])
  union() {
    // Main sheet
    linear_extrude(height=sheet_thickness, center=true, convexity=10)
      rounded_rect_2d(core_L, core_W, cr);

    // Protective film fused to top surface (overlaps into sheet)
    translate([0, 0, sheet_thickness/2 + film_thickness/2 - ov])
      linear_extrude(height=film_thickness, center=true, convexity=10)
        rounded_rect_2d(core_L, core_W, cr);
  }
}

// Final Model (ONE connected solid)
acrylic_with_film();