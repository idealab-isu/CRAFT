module rounded_rectangle_base(length, width, height, radius) {
    difference() {
        cube([length, width, height], center = true);
        translate([-length/2, -width/2, 0])
            cylinder(h = height, r = radius, center = false, $fn = 64);
        translate([length/2, -width/2, 0])
            cylinder(h = height, r = radius, center = false, $fn = 64);
        translate([-length/2, width/2, 0])
            cylinder(h = height, r = radius, center = false, $fn = 64);
        translate([length/2, width/2, 0])
            cylinder(h = height, r = radius, center = false, $fn = 64);
    }
}

module cantilever_arm(length, width, height, radius) {
    translate([0, 0, height/2])
        rotate([0, 90, 0])
            cylinder(h = length, r = radius, center = true, $fn = 64);
    translate([length/2 - radius, 0, height/2])
        cube([radius*2, width, height], center = true);
}

module end_pad(length, width, height) {
    translate([length/2, 0, height/2])
        cube([length, width, height], center = true);
}

module boss(width, height, depth) {
    cube([width, depth, height], center = true);
}

module mounting_bracket() {
    union() {
        translate([0, 0, -0.05])
            rounded_rectangle_base(0.2, 0.1, 0.02, 0.01);
        translate([0.05, 0, 0])
            cantilever_arm(0.05, 0.02, 0.02, 0.01);
        translate([0.1, 0, 0])
            end_pad(0.02, 0.02, 0.02);
        translate([0.05, 0, -0.01])
            boss(0.02, 0.01, 0.02);
        translate([0.1, 0, -0.01])
            boss(0.02, 0.01, 0.02);
    }
}

mounting_bracket();