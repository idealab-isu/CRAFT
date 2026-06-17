$fn=64;

nut_thickness = 5.0;
across_flats = 11.5;
hole_diameter = 6.0;
clearance = 0.4;

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

nut(across_flats, nut_thickness, hole_diameter + clearance);