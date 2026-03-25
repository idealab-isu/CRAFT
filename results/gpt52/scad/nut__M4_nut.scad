$fn=64;

nut_thickness = 3.2;
across_flats = 8.1;
hole_diameter = 4.0;
clearance = 0.2;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module nut(af, h, hole_d){
    difference(){
        hex_prism(af, h);
        cylinder(h=h+0.6, d=hole_d+clearance, center=true, $fn=64);
    }
}

nut(across_flats, nut_thickness, hole_diameter);