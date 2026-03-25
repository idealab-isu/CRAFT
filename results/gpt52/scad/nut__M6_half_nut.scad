$fn=96;

module hex_prism_across_flats(af=11.5, h=3.0){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module clearance_hole(d=6.6, h=3.0){
    cylinder(h=h+0.4, d=d, center=true, $fn=96);
}

module hex_nut_m6(af=11.5, thickness=3.0, hole_d=6.6){
    difference(){
        hex_prism_across_flats(af=af, h=thickness);
        clearance_hole(d=hole_d, h=thickness);
    }
}

hex_nut_m6(af=11.5, thickness=3.0, hole_d=6.6);