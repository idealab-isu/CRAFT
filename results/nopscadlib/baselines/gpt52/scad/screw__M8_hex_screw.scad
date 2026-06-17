$fn=96;

module hex_prism(flat_d, h){
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module screw_shank(d=8.0, L=10.0){
    translate([0,0,-L/2])
        cylinder(h=L, d=d, $fn=96);
}

module screw_head(hex_flat_d=15.0, head_h=5.65){
    translate([0,0,head_h/2])
        hex_prism(hex_flat_d, head_h);
}

module hex_head_screw(shank_d=8.0, shank_L=10.0, head_flat_d=15.0, head_h=5.65){
    union(){
        screw_shank(shank_d, shank_L);
        translate([0,0,shank_L/2])
            screw_head(head_flat_d, head_h);
    }
}

hex_head_screw(8.0, 10.0, 15.0, 5.65);