$fn=64;

nut_thickness = 2.4;
across_flats = 6.4;
hole_d = 3.0;

module hex_prism(af, h){
    r = af / sqrt(3); // circumradius for given across-flats
    cylinder(h=h, r=r, center=true, $fn=6);
}

module nut(af, h, hole_d){
    difference(){
        hex_prism(af, h);
        cylinder(h=h+0.4, d=hole_d, center=true, $fn=64);
    }
}

nut(across_flats, nut_thickness, hole_d);