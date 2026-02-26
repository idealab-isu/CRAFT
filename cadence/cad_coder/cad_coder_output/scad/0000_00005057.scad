EPS = 0.01;

module loop0() {
    difference() {
        cylinder(h=0.5 + EPS, r=0.37894736842105264, center=true);
        translate([0, 0, -EPS/2])
            cylinder(h=0.5 + EPS, r=0.3157894736842105, center=true);
    }
}

module loop1() {
    difference() {
        cylinder(h=0.625 + EPS, r=0.5052631578947369, center=true);
        translate([0, 0, -EPS/2])
            cylinder(h=0.625 + EPS, r=0.37894736842105264, center=true);
    }
}

module loop2() {
    difference() {
        linear_extrude(height=0.25 + EPS) {
            polygon(points=[
                [0, 0],
                [1.25, 0],
                [1.25, 0.8289473684210525],
                [0, 0.8289473684210525],
                [0, 0]
            ], paths=[[0, 1, 2, 3, 4]]);
        }
        translate([0.631578947368421, 0.42105263157894735, -EPS/2])
            cylinder(h=0.25 + EPS, r=0.5, center=true);
    }
}

translate([-0.375, 0, 0])
    loop0();

translate([-0.5, 0, 0])
    loop1();

translate([-0.625, -0.4140625, 0])
    loop2();