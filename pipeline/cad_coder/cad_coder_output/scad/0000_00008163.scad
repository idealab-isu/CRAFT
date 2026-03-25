EPS = 0.01;

module loop0() {
    polygon(points=[[0.7109375, 0.0], [0.7109375, 0.7109375], [0.0, 0.7109375], [0.0, 0.0]]);
}

module loop1() {
    translate([0.4415296052631579, 0.3592105263157895, 0])
        circle(r=0.08980263157894737);
}

module loop2() {
    translate([0.04736842105263158, 0, 0])
        circle(r=0.04736842105263158);
}

module solid0() {
    linear_extrude(height=-0.75 - EPS)
        union() {
            loop0();
            loop1();
        }
}

module solid1() {
    translate([-0.3515625, -0.2734375, -0.1484375])
        rotate([90, 0, 0])
            linear_extrude(height=-0.421875 - EPS)
                loop2();
}

module solid2() {
    translate([-0.3515625, 0.171875, -0.1484375])
        rotate([90, 0, 0])
            linear_extrude(height=-0.421875 - EPS)
                loop2();
}

module solid3() {
    translate([-0.3515625, -0.2734375, -0.6015625])
        rotate([90, 0, 0])
            linear_extrude(height=-0.421875 - EPS)
                loop2();
}

difference() {
    solid0();
    solid1();
    solid2();
    solid3();
}