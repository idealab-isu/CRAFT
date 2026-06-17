$fn=64;

d_shank = 6.0;
len_shank = 10.0;

d_head = 11.5;
h_head = 4.15;

module hex_prism(flat_d, h){
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module screw(){
    union(){
        translate([0,0,-len_shank/2])
            cylinder(h=len_shank, d=d_shank, $fn=64);
        translate([0,0,len_shank/2])
            hex_prism(d_head, h_head);
    }
}

screw();