$fn=64;

screw_d = 6.0;
across_flats = 7.7;
thickness = 7.9;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module nut(af, h, hole_d){
    difference(){
        hex_prism(af, h);
        cylinder(h=h+0.4, d=hole_d, center=true, $fn=64);
    }
}

nut(across_flats, thickness, screw_d);