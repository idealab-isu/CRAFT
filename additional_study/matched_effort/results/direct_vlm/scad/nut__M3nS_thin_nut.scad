$fn = 96;

screw_d = 3.0;          // mm
across_flats = 5.5;     // mm
thickness = 1.8;        // mm
clearance = 0.25;       // mm (typical for printed parts)

module hex_prism(af, h) {
    // For a regular hexagon: across_flats = 2 * apothem
    // circumradius R = apothem / cos(30) = (af/2) / cos(30)
    R = (af/2) / cos(30);
    linear_extrude(height = h)
        polygon([ for (i = [0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference() {
    hex_prism(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(d = screw_d + clearance, h = thickness + 0.4);
}