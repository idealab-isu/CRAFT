// Parameters
clip_length = 50;
clip_width = 10;
clip_thickness = 2;
hook_length = 15;
hook_height = 5;
hinge_radius = 3;
arm_length = 20;
arm_width = 5;
spigot_diameter = 4;
spigot_length = 10;
mounting_hole_diameter = 3;
mounting_hole_depth = 5;

// Clip Body
module clip_body() {
    translate([0, 0, clip_thickness/2])
    cube([clip_length, clip_width, clip_thickness]);
}

// Hook Section
module hook_section() {
    translate([clip_length - hook_length, clip_width/2 - hook_height/2, clip_thickness])
    rotate([0, 90, 0])
    cylinder(h = hook_length, r = hook_height/2);
}

// Hinge Bend
module hinge_bend() {
    translate([0, clip_width/2 - hinge_radius, clip_thickness])
    rotate([90, 0, 0])
    cylinder(h = clip_width, r = hinge_radius);
}

// Arms
module arms() {
    translate([0, 0, clip_thickness])
    cube([arm_length, arm_width, clip_thickness]);
}

// Spigot
module spigot() {
    translate([clip_length - spigot_length, clip_width/2 - spigot_diameter/2, clip_thickness])
    rotate([90, 0, 0])
    cylinder(h = spigot_length, r = spigot_diameter/2);
}

// Mounting Hole Feature
module mounting_hole_feature() {
    translate([clip_length/2, clip_width/2, clip_thickness/2])
    rotate([90, 0, 0])
    cylinder(h = mounting_hole_depth, r = mounting_hole_diameter/2);
}

// Swiss Clip
module swiss_clip() {
    clip_body();
    hook_section();
    hinge_bend();
    translate([clip_length - arm_length, 0, 0]) arms();
    spigot();
}

// Swiss Clip with Hole
module swiss_clip_hole() {
    difference() {
        swiss_clip();
        mounting_hole_feature();
    }
}

// Render the Swiss Clip with Hole
swiss_clip_hole();