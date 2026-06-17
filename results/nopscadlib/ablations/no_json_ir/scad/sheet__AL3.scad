// Aluminium tooling plate (generic): single connected solid, no text, no holes/cutouts

plate_length    = 200;  // mm
plate_width     = 100;  // mm
plate_thickness = 10;   // mm

// Corner rounding radius (set to 0 for sharp corners)
corner_radius = 5;      // mm

$fn = 96;

// 2D rounded rectangle helper
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    if (R2 <= 0) {
        square([L, W], center=true);
    } else {
        minkowski() {
            square([L - 2*R2, W - 2*R2], center=true);
            circle(r=R2);
        }
    }
}

// Main plate
linear_extrude(height = plate_thickness, center = true, convexity = 10)
    rounded_rect_2d(plate_length, plate_width, corner_radius);