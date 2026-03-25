$fn=64;

module hex_prism(af=8.0, h=2.7){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module clearance_hole(d=5.0, h=2.7){
    cylinder(h=h+0.4, d=d+0.3, center=true, $fn=64);
}

module thin_hex_nut(af=8.0, thickness=2.7, screw_d=5.0){
    difference(){
        hex_prism(af=af, h=thickness);
        clearance_hole(d=screw_d, h=thickness);
    }
}

thin_hex_nut(af=8.0, thickness=2.7, screw_d=5.0);