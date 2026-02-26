EPS = 0.01;

module sketch0() {
    translate([0, -0.0390625, -0.15625])
    rotate([0, 90, 0])
    linear_extrude(height=0.75 + EPS, center=true)
    polygon(points=[
        [0.0352796052631579, 0.0],
        [0.03754746418308187, 0.0009393779221812848],
        [0.03848684210526316, 0.003207236842105263],
        [0.03848684210526316, 0.3014802631578947],
        [0.03754746418308187, 0.3037481220778187],
        [0.0352796052631579, 0.3046875],
        [0.0, 0.3046875],
        [0.0, 0.29827302631578945],
        [0.032072368421052634, 0.29827302631578945],
        [0.032072368421052634, 0.006414473684210526],
        [0.0, 0.006414473684210526],
        [0.0, 0.0]
    ]);
}

module sketch1() {
    translate([0.75, 0, 0.125])
    rotate([0, 90, 0])
    linear_extrude(height=-0.0234375 - EPS)
    circle(r=0.011842105263157895);
}

module sketch2() {
    translate([0.75, 0, -0.125])
    rotate([0, 90, 0])
    linear_extrude(height=-0.0234375 - EPS)
    circle(r=0.011842105263157895);
}

module sketch3() {
    translate([-0.7265625, 0, 0.125])
    rotate([0, 90, 0])
    linear_extrude(height=-0.0234375 - EPS)
    circle(r=0.011842105263157895);
}

module sketch4() {
    translate([-0.7265625, 0, -0.125])
    rotate([0, 90, 0])
    linear_extrude(height=-0.0234375 - EPS)
    circle(r=0.011842105263157895);
}

difference() {
    sketch0();
    sketch1();
    sketch2();
    sketch3();
    sketch4();
}