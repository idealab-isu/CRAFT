$fn=64;

module hex_nut(af=7.0, thickness=2.2, hole_d=4.0, clearance=0.3){
    r = af / sqrt(3); // circumradius for across-flats dimension
    difference(){
        cylinder(h=thickness, r=r, center=true, $fn=6);
        cylinder(h=thickness+0.4, d=hole_d+clearance, center=true, $fn=64);
    }
}

hex_nut();