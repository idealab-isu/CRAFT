$fn = 64;

// Camera body
module camera_body() {
    difference() {
        // Main body
        cube([30, 30, 10], center = true);
        // Lens cutout
        translate([0, 0, 5])
            cylinder(h = 10, r1 = 5, r2 = 5, center = true);
    }
}

// Ribbon connector
module ribbon_connector() {
    translate([-7.5, -1.1, -0.5])
        cube([15, 2.2, 1], center = true);
}

// Assemble camera module
module camera_module() {
    union() {
        camera_body();
        translate([0, -15, 0])
            ribbon_connector();
    }
}

// Render the camera module
camera_module();