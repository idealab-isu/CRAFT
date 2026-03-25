$fn=64;

L = 0.1;
W = 0.1;
H = 0.1;

slot_w = 0.04;
slot_h = 0.06;
slot_len = 0.06;

end_round_r = 0.05;

chamfer_len = 0.02;

hex_flat = 0.02;
hex_r = hex_flat / sqrt(3);
hex_len = W + 0.02;

hex_x = -0.03;

module hex_prism(r, h){
    cylinder(r=r, h=h, $fn=6, center=true);
}

module body(){
    union(){
        translate([0,0,0]) cube([L, W, H], center=true);
        translate([-L/2, 0, 0])
            rotate([0,90,0])
                cylinder(r=end_round_r, h=0.0001, center=true);
    }
}

module chamfer_cut(){
    translate([L/2 - chamfer_len/2, 0, 0])
        rotate([0,45,0])
            cube([chamfer_len*2, W*1.2, H*1.2], center=true);
}

module slot_cut(){
    translate([L/2 - slot_len/2, 0, 0])
        cube([slot_len, slot_w, slot_h], center=true);
}

module hex_hole(){
    translate([hex_x, 0, 0])
        rotate([90,0,0])
            hex_prism(hex_r, hex_len);
}

difference(){
    body();
    slot_cut();
    chamfer_cut();
    hex_hole();
}