EPS = 0.01;

module sketch0() {
    translate([-0.75, -0.1875, 0])
    linear_extrude(height=0.2890625 + EPS)
    polygon(points=[[1.5, 0], [1.5, 0.37894736842105264], [0, 0.37894736842105264], [0, 0]]);
}

module sketch1() {
    translate([-0.0859375, 0, 0.2890625])
    linear_extrude(height=0.2890625 + EPS)
    circle(r=0.08289473684210526);
}

module sketch2() {
    translate([0.2578125, 0, 0.2890625])
    linear_extrude(height=0.2890625 + EPS)
    circle(r=0.11595394736842105);
}

module sketch3() {
    translate([-0.4765625, 0, 0.2890625])
    linear_extrude(height=0.2890625 + EPS)
    circle(r=0.07894736842105263);
}

union() {
    sketch0();
    sketch1();
    sketch2();
    sketch3();
}