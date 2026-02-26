EPS = 0.01;

module loop0() {
    translate([0.7578947368421053, 0.0, 0])
    circle(r=0.7421052631578947);
}

module loop1() {
    translate([0.7578947368421053, 0.0, 0])
    circle(r=0.09473684210526316);
}

difference() {
    linear_extrude(height=0.3515625 + EPS)
    loop0();
    linear_extrude(height=0.3515625 + EPS)
    loop1();
}