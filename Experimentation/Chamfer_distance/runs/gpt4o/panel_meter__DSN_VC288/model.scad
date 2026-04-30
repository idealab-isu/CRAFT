$fn = 64;

// Main body of the meter
module meter_body() {
    cube([45.3, 26, 17.4], center = true);
}

// Bezel of the meter
module meter_bezel() {
    difference() {
        cube([47.8, 28.8, 2], center = true);
        translate([0, 0, -1])
            cube([36, 18, 3], center = true);
    }
}

// Assemble the meter
module panel_mount_meter() {
    union() {
        translate([0, 0, -7.2])
            meter_body();
        translate([0, 0, 8.7])
            meter_bezel();
    }
}

// Render the meter
panel_mount_meter();