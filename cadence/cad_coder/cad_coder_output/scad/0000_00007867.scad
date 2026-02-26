EPS = 0.01;

module loop0() {
    translate([0.7578947368421053, 0.0, 0])
    circle(r=0.7578947368421053 + EPS);
}

module loop1() {
    translate([0.7578947368421053, 0.4736842105263158, 0])
    circle(r=0.15789473684210525 + EPS);
}

difference() {
    union() {
        loop0();
    }
    loop1();
}

linear_extrude(height=0.1015625 + EPS)
difference() {
    union() {
        loop0();
    }
    loop1();
}