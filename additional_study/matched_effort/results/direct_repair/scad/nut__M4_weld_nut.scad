$fn = 120;

screw_d = 4.0;          // mm
across_flats = 5.3;     // mm
thickness = 6.3;        // mm

clearance = 0.25;       // mm added to screw diameter for clearance
hole_d = screw_d + clearance;

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = apothem / cos(30) = (af/2) / cos(30)
    R = (af/2) / cos(30);
    linear_extrude(height = h)
        polygon(points = [for (i = [0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.1])
        cylinder(d = hole_d, h = thickness + 0.2);
}