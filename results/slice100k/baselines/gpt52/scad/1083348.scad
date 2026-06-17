$fn=96;

module ring_body(od=22, id=16, h=82.5){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.4, center=true);
    }
}

module lug(radial_len=3, tangential_w=6, h=19, od=22){
    translate([od/2 + radial_len/2, 0, 0])
        cube([radial_len, tangential_w, h], center=true);
}

module collar_with_lug(){
    union(){
        ring_body(od=22, id=16, h=82.5);
        lug(radial_len=3, tangential_w=6, h=19, od=22);
    }
}

collar_with_lug();