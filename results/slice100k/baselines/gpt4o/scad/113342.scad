module tapered_arm() {
    // Main tapered arm
    translate([-11.55, -5.15, -36.2])
    linear_extrude(height=72.4, scale=1.0)
    polygon(points=[[0, 0], [23.1, 0], [20.1, 10.3], [3.0, 10.3]]);
}

module triangular_fin() {
    // Triangular fin attached at an angle
    translate([0, 0, 36.2])
    rotate([45, 0, 0])
    linear_extrude(height=10)
    polygon(points=[[0, 0], [10, 0], [5, 5]]);
}

tapered_arm();
triangular_fin();