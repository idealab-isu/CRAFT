// SG90 Micro Servo Bracket
// SG90: 23mm x 12.2mm x 22mm, mounting tabs
servo_length = 23;
servo_width = 12.2;
servo_height = 22;
tab_width = 32;  // Including mounting tabs
wall = 2;

difference() {
    union() {
        // Main bracket body
        cube([servo_length + wall*2, servo_width + wall*2, servo_height/2], center=true);

        // Top plate for horn clearance
        translate([0, 0, servo_height/4])
            cube([tab_width, servo_width + wall*2, wall], center=true);
    }

    // Servo pocket
    translate([0, 0, wall])
        cube([servo_length, servo_width, servo_height], center=true);

    // Horn slot
    translate([0, 0, servo_height/4])
        cylinder(d=8, h=wall+1, center=true, $fn=32);

    // Mounting holes on tabs
    for (x = [-1, 1]) {
        translate([x * (tab_width/2 - 3), 0, servo_height/4])
            cylinder(d=2.2, h=wall+1, center=true, $fn=32);
    }
}
