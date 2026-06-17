$fn = 120;

across_flats = 13.0;   // mm
thickness    = 4.0;    // mm
hole_d       = 8.0;    // mm (clearance as specified)

module hex_prism_af(af, h){
    // For a regular hexagon: across_flats = 2 * apothem = sqrt(3) * R
    // where R is circumradius (center to vertex)
    R = af / sqrt(3);
    linear_extrude(height = h)
        polygon([ for (i = [0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference(){
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(d = hole_d, h = thickness + 0.4);
}