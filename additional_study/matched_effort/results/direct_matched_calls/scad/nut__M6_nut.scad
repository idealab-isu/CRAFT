$fn = 120;

across_flats = 11.5;   // mm
thickness    = 5.0;    // mm
hole_d       = 6.0;    // mm (clearance hole as specified)

module hex_prism_af(af, h){
    // For a regular hexagon: across flats = 2 * apothem
    // circumradius R = apothem / cos(30°) = (af/2) / cos(30°)
    R = (af/2) / cos(30);
    linear_extrude(height=h)
        polygon(points=[for(i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

difference(){
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.1])
        cylinder(d=hole_d, h=thickness+0.2);
}