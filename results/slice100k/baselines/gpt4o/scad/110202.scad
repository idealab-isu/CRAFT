module eyelet(radius, thickness) {
    difference() {
        cylinder(h=thickness, r=radius, $fn=64);
        translate([0, 0, -1])
            cylinder(h=thickness + 2, r=radius - 2, $fn=64);
    }
}

module diamond_frame() {
    polygon(points=[[0, 0], [48.3, 61.5], [0, 123], [-48.3, 61.5]]);
}

module linkage_frame() {
    union() {
        // Central spine
        translate([-1.5, 0, 0])
            cube([3, 19, 123]);

        // Diamond-shaped braced loop
        translate([0, 0, 0])
            linear_extrude(height=3)
                diamond_frame();

        // Eyelets at diamond corners
        translate([48.3, 61.5, 1.5])
            eyelet(4, 3);
        translate([-48.3, 61.5, 1.5])
            eyelet(4, 3);
        translate([0, 0, 1.5])
            eyelet(4, 3);
        translate([0, 123, 1.5])
            eyelet(4, 3);

        // Additional eyelets along the spine
        translate([0, 30, 1.5])
            eyelet(4, 3);
        translate([0, 92, 1.5])
            eyelet(4, 3);

        // Cylindrical boss/cap at one end of the spine
        translate([0, 123, 0])
            cylinder(h=10, r=5, $fn=64);
    }
}

translate([0, -9.5, -61.5])
    linkage_frame();