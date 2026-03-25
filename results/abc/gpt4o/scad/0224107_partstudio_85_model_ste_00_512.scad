module hex_bore(size, depth) {
    translate([0, 0, -depth/2])
        linear_extrude(height = depth)
            polygon(points = [
                [size/2, 0],
                [size/4, size * sqrt(3)/4],
                [-size/4, size * sqrt(3)/4],
                [-size/2, 0],
                [-size/4, -size * sqrt(3)/4],
                [size/4, -size * sqrt(3)/4]
            ]);
}

module knurled_band(diameter, height, segments) {
    rotate([0, 0, 0])
        cylinder(d = diameter, h = height, $fn = segments);
}

module serrated_cylinder(diameter, height, serration_height, segments) {
    difference() {
        cylinder(d = diameter, h = height, $fn = segments);
        for (i = [0:segments-1]) {
            rotate([0, 0, i * 360/segments])
                translate([diameter/2, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(d = serration_height, h = diameter, $fn = 3);
        }
    }
}

module stepped_flange(diameter, height, step_diameter, step_height, segments) {
    difference() {
        cylinder(d = diameter, h = height, $fn = segments);
        translate([0, 0, height - step_height])
            cylinder(d = step_diameter, h = step_height, $fn = segments);
    }
}

module coupling() {
    union() {
        translate([0, 0, -10])
            stepped_flange(30, 10, 25, 3, 64);
        translate([0, 0, 0])
            serrated_cylinder(25, 10, 2, 12);
        translate([0, 0, 10])
            knurled_band(25, 5, 64);
        translate([0, 0, 15])
            serrated_cylinder(25, 10, 2, 12);
        translate([0, 0, 25])
            knurled_band(25, 5, 64);
        translate([0, 0, 30])
            serrated_cylinder(25, 10, 2, 12);
        translate([0, 0, 0])
            hex_bore(10, 40);
    }
}

coupling();