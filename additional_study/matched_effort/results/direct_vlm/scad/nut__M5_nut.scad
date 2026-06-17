$fn = 120;

screw_d      = 5.0;   // mm (nominal screw size)
across_flats = 9.2;   // mm
thickness    = 4.0;   // mm

// Clearance hole for 5.0mm screw (adjust as desired)
hole_d = 5.3;         // mm

module hex_prism_af(af, h, center=false) {
    // Regular hex: across_flats = sqrt(3) * R (circumradius)
    R = af / sqrt(3);
    linear_extrude(height=h, center=center, convexity=10)
        polygon(points=[for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

difference() {
    // Centered so the through-hole subtraction is symmetric and always visible
    hex_prism_af(across_flats, thickness, center=true);

    // Through-hole: extend beyond both faces to guarantee a clean cut
    cylinder(d=hole_d, h=thickness + 0.4, center=true);
}