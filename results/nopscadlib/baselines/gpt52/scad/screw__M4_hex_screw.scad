$fn=64;

module hex_prism(flat_d, h){
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module screw_shank(d, l){
    cylinder(h=l, d=d, $fn=64);
}

module hex_head(head_d, head_h){
    hex_prism(head_d, head_h);
}

module hex_head_screw(shank_d=4.0, head_d=8.1, head_h=2.925, total_l=10.0){
    shank_l = max(0, total_l - head_h);
    union(){
        translate([0,0,-total_l/2])
            screw_shank(shank_d, shank_l);
        translate([0,0,-total_l/2 + shank_l])
            hex_head(head_d, head_h);
    }
}

hex_head_screw(4.0, 8.1, 2.925, 10.0);