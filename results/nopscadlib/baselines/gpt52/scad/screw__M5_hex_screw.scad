$fn=64;

d_shaft = 5.0;
len_shaft = 10.0;

head_flat_d = 9.2;
head_h = 3.65;

module hex_prism(flat_d, h){
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module screw(){
    union(){
        translate([0,0,-len_shaft/2])
            cylinder(h=len_shaft, d=d_shaft, $fn=64);
        translate([0,0,len_shaft/2])
            hex_prism(head_flat_d, head_h);
    }
}

screw();