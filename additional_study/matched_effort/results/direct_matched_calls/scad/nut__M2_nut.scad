$fn = 120;

across_flats = 4.9;   // mm
thickness    = 1.6;   // mm
hole_d       = 2.0;   // mm (clearance/nominal as requested)

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = apothem / cos(30°) = (af/2) / cos(30°)
    R = (af/2) / cos(30);
    linear_extrude(height = h)
        polygon(points = [for (i = [0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(d = hole_d, h = thickness + 0.4);
}