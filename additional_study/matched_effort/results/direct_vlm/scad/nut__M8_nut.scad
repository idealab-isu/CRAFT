$fn = 120;

screw_d = 8.0;          // clearance hole diameter
across_flats = 15.0;    // hex size across flats
thickness = 6.5;        // nut thickness

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = 2 * apothem
    // Circumradius R = apothem / cos(30°) = (af/2) / cos(30°)
    R = (af/2) / cos(30);
    linear_extrude(height = h)
        polygon(points = [ for (i = [0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.5])
        cylinder(d = screw_d, h = thickness + 1.0);
}