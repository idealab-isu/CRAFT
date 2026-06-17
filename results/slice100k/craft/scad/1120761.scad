$fn = 64;

// Target bounding box (mm)
bbox_x = 26.4;
bbox_y = 26.4;
thickness_z = 5.6;

// Cross profile parameters (mm)
core_size = 10;      // central square size
arm_width = 8;       // arm thickness
corner_radius = 2;   // outer corner rounding radius

// Derived
half_extent = min(bbox_x, bbox_y) / 2;
arm_length = half_extent - core_size/2;  // ensures overall size matches bbox

module cross_2d() {
    union() {
        square([core_size, core_size], center=true);

        // +X / -X arms
        translate([ core_size/2 + arm_length/2, 0])
            square([arm_length, arm_width], center=true);
        translate([-core_size/2 - arm_length/2, 0])
            square([arm_length, arm_width], center=true);

        // +Y / -Y arms
        translate([0,  core_size/2 + arm_length/2])
            square([arm_width, arm_length], center=true);
        translate([0, -core_size/2 - arm_length/2])
            square([arm_width, arm_length], center=true);
    }
}

// Rounded outer corners via 2D offset (keeps uniform extrusion, no extra parts)
module rounded_cross_2d() {
    offset(r=corner_radius) offset(delta=-corner_radius) cross_2d();
}

linear_extrude(height=thickness_z, center=true, convexity=10)
    rounded_cross_2d();