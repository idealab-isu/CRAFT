EPS = 0.01;

module circle_extrude(radius, height) {
    translate([0, 0, -height/2])
        linear_extrude(height=height)
            circle(r=radius);
}

module rectangle_with_circle_extrude(x, y, circle_radius, height) {
    translate([0, 0, -height/2])
        difference() {
            square([x, y]);
            translate([x/2, y/2])
                circle(r=circle_radius);
        }
    linear_extrude(height=height);
}

union() {
    translate([-0.5546875, 0.5234375, 0])
        circle_extrude(0.08684210526315789, 0.03125 + EPS);
    translate([-0.2109375, 0.5234375, 0])
        circle_extrude(0.08684210526315789, 0.03125 + EPS);
    translate([0.171875, 0.546875, 0])
        circle_extrude(0.08684210526315789, 0.03125 + EPS);
    translate([-0.5703125, 0.421875, 0])
        rectangle_with_circle_extrude(0.203125, 0.203125, 0.08552631578947369, 0.046875 + EPS);
    translate([-0.21875, 0.3203125, 0])
        rectangle_with_circle_extrude(0.20526315789473687, 0.40625, 0.08552631578947369, 0.046875 + EPS);
    translate([0.0625, 0.34375, 0])
        rectangle_with_circle_extrude(0.40625, 0.40625, 0.08552631578947369, 0.046875 + EPS);
}