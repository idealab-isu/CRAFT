// Aluminium tooling plate (plain sheet, no holes/features)

// Parameters
plate_length = 300;      //[150:600:1]
plate_width  = 200;      //[100:400:1]
plate_thickness = 10;    //[5:20:1]
corner_radius = 12;      //[0:24:1]  // set 0 for sharp corners

$fn = 96;

// 2D rounded rectangle (robust, non-blank)
module rounded_rect_2d(L, W, R) {
    r = max(0, min(R, min(L, W)/2));
    if (r <= 0) {
        square([L, W], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - r), sy*(W/2 - r)])
                    circle(r=r);
        }
    }
}

// 3D plate
module tooling_plate_plain() {
    linear_extrude(height=plate_thickness, center=true, convexity=10)
        rounded_rect_2d(plate_length, plate_width, corner_radius);
}

// Render
color([0.75, 0.75, 0.78]) tooling_plate_plain();