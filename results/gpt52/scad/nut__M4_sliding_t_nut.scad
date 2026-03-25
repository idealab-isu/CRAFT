$fn=64;

screw_d = 4.0;
across_flats = 6.0;
thickness = 3.7;

clearance = 0.4;
hole_d = screw_d + clearance;

corner_chamfer = 0.35;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=true);
}

module chamfered_hex(af, h, c){
    if (c <= 0)
        hex_prism(af, h);
    else
        minkowski(){
            hex_prism(af - 2*c, h - 2*c);
            sphere(r=c, $fn=32);
        }
}

difference(){
    chamfered_hex(across_flats, thickness, corner_chamfer);
    cylinder(h=thickness + 2, d=hole_d, center=true, $fn=64);
}