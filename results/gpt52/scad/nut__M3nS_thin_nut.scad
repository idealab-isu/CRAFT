$fn=64;

module hex_prism_across_flats(af=5.5, h=1.8){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module clearance_hole(d=3.2, h=1.8){
    cylinder(h=h+0.4, d=d, center=true, $fn=64);
}

module thin_hex_nut_m3(af=5.5, thickness=1.8, hole_d=3.2){
    difference(){
        hex_prism_across_flats(af=af, h=thickness);
        clearance_hole(d=hole_d, h=thickness);
    }
}

thin_hex_nut_m3(af=5.5, thickness=1.8, hole_d=3.2);