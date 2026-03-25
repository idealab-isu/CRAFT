$fn=96;

module tubing_segment(od=8, id=6, len=120) {
    difference() {
        cylinder(h=len, d=od, center=true);
        cylinder(h=len+0.2, d=id, center=true);
    }
}

module tubing_bend(od=8, id=6, bend_r=30, angle=90) {
    rotate_extrude(angle=angle, convexity=10)
        translate([bend_r, 0, 0])
            difference() {
                circle(d=od);
                circle(d=id);
            }
}

module aquarium_tubing(od=8, id=6, straight_len=120, bend_r=30, bend_angle=90) {
    union() {
        translate([0, 0, 0])
            tubing_segment(od=od, id=id, len=straight_len);

        translate([0, 0, straight_len/2])
            rotate([0, 90, 0])
                tubing_bend(od=od, id=id, bend_r=bend_r, angle=bend_angle);

        translate([bend_r, 0, straight_len/2 + bend_r])
            rotate([90, 0, 0])
                tubing_segment(od=od, id=id, len=straight_len*0.6);
    }
}

aquarium_tubing(od=8, id=6, straight_len=140, bend_r=35, bend_angle=90);