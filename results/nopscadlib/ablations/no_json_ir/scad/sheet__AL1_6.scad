// Aluminium tooling plate (single connected solid, visible geometry)

length = 200;     // X (mm)
width  = 100;     // Y (mm)
thickness = 10;   // Z (mm)

// Optional edge treatment (set to 0 for sharp corners)
corner_radius = 0;  // mm

$fn = 96;

module rounded_plate(L, W, T, R) {
    r = min(max(R, 0), L/2, W/2);

    if (r <= 0) {
        cube([L, W, T], center=true);
    } else {
        // Robust rounded-rectangle prism using hull of corner cylinders
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - r), sy*(W/2 - r), 0])
                    cylinder(r=r, h=T, center=true);
        }
    }
}

// Neutral metallic-looking color (helps identify "aluminum" in renders)
color([0.78, 0.80, 0.82])
    rounded_plate(length, width, thickness, corner_radius);