module rounded_rectangle_base(length, width, height, radius) {
    difference() {
        cube([length, width, height], center = true);
        translate([0, 0, -height/2])
            cylinder(h = height, r = radius, $fn = 64);
        translate([0, 0, height/2])
            cylinder(h = height, r = radius, $fn = 64);
        translate([-length/2, 0, 0])
            cylinder(h = height, r = radius, $fn = 64);
        translate([length/2, 0, 0])
            cylinder(h = height, r = radius, $fn = 64);
    }
}

module arm_with_rounded_end(length, width, height, neck_width, neck_height, end_radius) {
    union() {
        translate([0, 0, neck_height/2])
            cube([neck_width, width, neck_height], center = true);
        translate([length/2 - end_radius, 0, neck_height/2])
            cylinder(h = width, r = end_radius, $fn = 64);
        translate([0, 0, neck_height])
            rotate([90, 0, 0])
                cylinder(h = length, r1 = neck_width/2, r2 = end_radius, $fn = 64);
    }
}

module side_bosses(boss_width, boss_height, boss_depth) {
    translate([0, 0, boss_height/2])
        cube([boss_width, boss_depth, boss_height], center = true);
}

module mounting_bracket() {
    union() {
        rounded_rectangle_base(0.2, 0.1, 0.02, 0.01);
        translate([0, 0, 0.02])
            arm_with_rounded_end(0.15, 0.02, 0.02, 0.01, 0.01, 0.015);
        translate([-0.05, 0, 0.02])
            side_bosses(0.02, 0.01, 0.02);
        translate([0.05, 0, 0.02])
            side_bosses(0.02, 0.01, 0.02);
    }
}

mounting_bracket();