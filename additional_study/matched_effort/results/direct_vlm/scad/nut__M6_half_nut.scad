$fn = 96;

across_flats = 11.5;   // mm
thickness    = 3.0;    // mm
hole_d       = 6.0;    // mm (clearance hole as specified)

module hex_prism_af(af, h){
    // For a regular hexagon: across flats = 2 * apothem
    // Circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height = h)
        polygon(points = [ for (i = [0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(d = hole_d, h = thickness + 0.4);
}