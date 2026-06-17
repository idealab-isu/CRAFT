$fn = 96;

across_flats = 8.0;     // mm
thickness    = 2.7;     // mm
hole_d       = 5.2;     // mm (clearance for 5.0mm screw)

module hex_prism_af(af, h){
    // Regular hex with given across-flats (distance between opposite sides)
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height=h)
        polygon(points=[
            [ R, 0],
            [ R/2,  R*sqrt(3)/2],
            [-R/2,  R*sqrt(3)/2],
            [-R, 0],
            [-R/2, -R*sqrt(3)/2],
            [ R/2, -R*sqrt(3)/2]
        ]);
}

difference(){
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.1])
        cylinder(d=hole_d, h=thickness+0.2);
}