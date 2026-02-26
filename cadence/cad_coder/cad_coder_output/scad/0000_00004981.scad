EPS = 0.01;

translate([-0.625, -0.625, 0.0])
rotate([0, 0, 0])
linear_extrude(height=0.75)
difference() {
    polygon(points=[[1.25, 0.0], [1.25, 1.25], [0.0, 1.25], [0.0, 0.0]]);
    translate([0, 0, EPS])
    polygon(points=[[1.0, 0.25], [1.0, 1.0], [0.25, 1.0], [0.25, 0.25]]);
}