$fn=96;

bbox_xy = 16.8;
h = 6.3;

core_d = 12.0;

lug_len = (bbox_xy - core_d)/2;   // radial protrusion beyond core radius
lug_w = 4.0;                      // tangential width of lug

module lug(angle=0){
    rotate([0,0,angle])
        translate([core_d/2 + lug_len/2, 0, 0])
            cube([lug_len, lug_w, h], center=true);
}

module part(){
    union(){
        cylinder(d=core_d, h=h, center=true);
        lug(0);
        lug(90);
        lug(180);
        lug(270);
    }
}

part();