EPS = 0.01;

module loop0() {
    translate([0.035526315789473684, 0, 0])
    circle(r=0.034786184210526316);
}

module loop1() {
    translate([0.035526315789473684, 0, 0])
    circle(r=0.011842105263157895);
}

module loop2() {
    translate([0.011842105263157895, 0, 0])
    circle(r=0.011842105263157895);
}

module solid0() {
    difference() {
        linear_extrude(height=0.75 + EPS)
        loop0();
        linear_extrude(height=0.75 + EPS)
        loop1();
    }
}

module solid1() {
    linear_extrude(height=0.75 + EPS)
    loop2();
}

translate([-0.03125, 0, 0])
union() {
    solid0();
    translate([0.015625 - (-0.03125), 0, 0])
    solid1();
}