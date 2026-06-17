module c_shaped_segment() {
    $fn = 64;
    outer_radius = 1.75;
    inner_radius = outer_radius - 0.35;
    height = 9.1;
    angle = 120;

    difference() {
        // Outer faceted cylinder
        rotate([0, 90, 0])
        rotate([0, 0, -angle/2])
        cylinder(r=outer_radius, h=height, $fn=6);

        // Inner smooth cylinder
        rotate([0, 90, 0])
        rotate([0, 0, -angle/2])
        cylinder(r=inner_radius, h=height, $fn=64);
    }
}

translate([0, 0, -4.55])
c_shaped_segment();