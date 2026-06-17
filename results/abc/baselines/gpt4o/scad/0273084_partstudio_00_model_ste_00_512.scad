module hex_hole(radius, height) {
    translate([0, 0, -height/2])
        cylinder(r=radius, h=height, $fn=6);
}

module boss(diameter, thickness, hex_radius) {
    difference() {
        translate([0, 0, -thickness/2])
            cylinder(d=diameter, h=thickness, $fn=64);
        hex_hole(hex_radius, thickness + 1);
    }
}

module offset_link() {
    union() {
        translate([-25, 0, 0])
            boss(10, 5, 2);
        translate([25, 0, 0])
            boss(8, 3, 1.5);
        translate([-25, -1, -0.5])
            cube([50, 2, 1]);
    }
}

scale([0.1/50, 0.1/10, 0.1/5])
    offset_link();