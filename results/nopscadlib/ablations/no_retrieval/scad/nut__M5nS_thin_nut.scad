// Thin hex nut for 5.0mm screw
// 8.0mm across flats, 2.7mm thick

$fn = 128;

// Parameters
across_flats   = 8.0;   // mm
thickness      = 2.7;   // mm
hole_diameter  = 5.0;   // mm (clearance/through hole)
chamfer_size   = 0.3;   // mm (edge break)
overlap        = 0.2;   // mm (boolean robustness)

// Derived geometry
apothem = across_flats / 2;          // center to flat
hex_R   = apothem / cos(30);         // center to vertex (circumradius)

// 2D hex profile with flat-to-flat = across_flats
module hex2d(R) {
    polygon(points = [
        [ R, 0],
        [ R/2,  R*sqrt(3)/2],
        [-R/2,  R*sqrt(3)/2],
        [-R, 0],
        [-R/2, -R*sqrt(3)/2],
        [ R/2, -R*sqrt(3)/2]
    ]);
}

// Main model: one connected solid (nut body with through-hole and chamfers)
module hex_nut() {
    difference() {
        // Outer hex body (correct orientation: Z is thickness)
        linear_extrude(height = thickness, center = true, convexity = 10)
            hex2d(hex_R);

        // Through hole for screw (no threading modeled)
        cylinder(d = hole_diameter, h = thickness + 2*overlap, center = true);

        // Chamfers: use 6-sided cones so the edge break follows the hex, not a circle
        translate([0, 0, thickness/2 - chamfer_size/2])
            cylinder(h = chamfer_size + overlap,
                     r1 = hex_R + overlap,
                     r2 = max(hex_R - chamfer_size, 0.01),
                     center = true, $fn = 6);

        translate([0, 0, -thickness/2 + chamfer_size/2])
            cylinder(h = chamfer_size + overlap,
                     r1 = max(hex_R - chamfer_size, 0.01),
                     r2 = hex_R + overlap,
                     center = true, $fn = 6);
    }
}

hex_nut();