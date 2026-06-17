$fn=64;

screw_d = 3.0;
across_flats = 6.0;
thickness = 2.75;

clearance = 0.3;
hole_d = screw_d + clearance;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module tslot_nut(){
    difference(){
        hex_prism(across_flats, thickness);
        cylinder(h=thickness + 0.6, d=hole_d, center=true, $fn=64);
    }
}

tslot_nut();