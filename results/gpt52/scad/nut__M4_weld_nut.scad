$fn=64;

af = 5.3;          // across flats
thickness = 6.3;   // nut thickness
hole_d = 4.0;      // screw diameter (clearance as specified)

module hex_prism(af, h){
    r = af / sqrt(3); // circumradius for given across-flats
    cylinder(h=h, r=r, center=true, $fn=6);
}

difference(){
    hex_prism(af, thickness);
    cylinder(h=thickness + 0.4, d=hole_d, center=true, $fn=64);
}