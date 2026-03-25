$fn=64;

screw_d = 3.0;
across_flats = 6.0;
thickness = 3.0;

clearance = 0.4;
hole_d = screw_d + clearance;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module tslot_nut(af, h, hole_d){
    difference(){
        hex_prism(af, h);
        cylinder(h=h+0.6, d=hole_d, center=true, $fn=64);
    }
}

tslot_nut(across_flats, thickness, hole_d);