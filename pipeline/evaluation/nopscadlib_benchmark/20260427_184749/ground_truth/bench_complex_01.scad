// GT2 Belt Tensioner with 608 Bearing Idler
// Uses 608 bearing as idler, spring-loaded pivot arm
bearing_od = 22;  // 608 bearing
bearing_h = 7;
arm_length = 40;
arm_width = 15;
pivot_d = 5;
spring_d = 6;

// Pivot base
difference() {
    cube([25, 20, 10], center=true);

    // Pivot hole
    cylinder(d=pivot_d, h=15, center=true, $fn=32);

    // Mounting holes
    for (x = [-1, 1]) {
        translate([x * 8, 0, 0])
            cylinder(d=3.2, h=15, center=true, $fn=32);
    }
}

// Tensioner arm
translate([arm_length/2 + 5, 0, 0]) {
    difference() {
        union() {
            // Arm body
            cube([arm_length, arm_width, bearing_h + 2], center=true);

            // Bearing holder
            translate([arm_length/2 - bearing_od/2, 0, 0])
                cylinder(d=bearing_od + 4, h=bearing_h + 2, center=true, $fn=64);
        }

        // Pivot hole
        translate([-arm_length/2 + 8, 0, 0])
            cylinder(d=pivot_d, h=bearing_h + 5, center=true, $fn=32);

        // Bearing pocket
        translate([arm_length/2 - bearing_od/2, 0, 0])
            cylinder(d=bearing_od, h=bearing_h, center=true, $fn=64);

        // Bearing through hole
        translate([arm_length/2 - bearing_od/2, 0, 0])
            cylinder(d=8, h=bearing_h + 5, center=true, $fn=32);

        // Spring mount hole
        translate([-arm_length/2 + 25, arm_width/2 - 2, 0])
            cylinder(d=spring_d, h=bearing_h + 5, center=true, $fn=32);
    }
}
