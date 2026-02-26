EPS = 0.01;

module solid0() {
    translate([-0.28125, 0.0, 0.0])
    rotate([90, 0, 0])
    linear_extrude(height=0.75 + EPS)
    circle(r=0.28421052631578947);
}

module solid1() {
    translate([-0.109375, 0.0, 0.75])
    rotate([90, 0, 0])
    linear_extrude(height=-0.328125 - EPS)
    circle(r=0.11052631578947367);
}

difference() {
    solid0();
    solid1();
}