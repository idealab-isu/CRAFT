$fn=64;

screw_d = 5.0;
across_flats = 6.0;
thickness = 3.7;

clearance = 0.4;
hole_d = screw_d + clearance;

corner_r = 0.4;
chamfer = 0.35;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module rounded_hex(af, h, r){
    if (r <= 0)
        hex_prism(af, h);
    else
        minkowski(){
            hex_prism(af - 2*r, h - 2*r);
            sphere(r=r, $fn=48);
        }
}

module tslot_nut(){
    difference(){
        union(){
            rounded_hex(across_flats, thickness, corner_r);
        }
        cylinder(h=thickness + 2, d=hole_d, center=true, $fn=64);

        translate([0,0, thickness/2 - chamfer/2])
            cylinder(h=chamfer, d1=hole_d + 1.2, d2=hole_d, center=true, $fn=64);

        translate([0,0,-thickness/2 + chamfer/2])
            cylinder(h=chamfer, d1=hole_d, d2=hole_d + 1.2, center=true, $fn=64);
    }
}

tslot_nut();