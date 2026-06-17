$fn = 180;

inner_d = 5.0;
outer_d = 20.0;
thickness = 1.4;

difference() {
    cylinder(d = outer_d, h = thickness);
    translate([0, 0, -0.1])
        cylinder(d = inner_d, h = thickness + 0.2);
}