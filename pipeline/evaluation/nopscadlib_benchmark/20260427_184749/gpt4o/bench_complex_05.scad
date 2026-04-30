// Parameters
leadscrew_diameter = 8;
nut_diameter = 16;
nut_height = 10;
housing_width = 40;
housing_height = 40;
housing_depth = 20;
mount_hole_diameter = 5;
mount_hole_spacing = 30;
anti_backlash_spring_diameter = 12;
anti_backlash_spring_height = 5;

// Leadscrew nut housing
module leadscrew_nut_housing() {
    difference() {
        // Main housing block
        translate([-housing_width/2, -housing_depth/2, -housing_height/2])
            cube([housing_width, housing_depth, housing_height]);
        
        // Leadscrew hole
        translate([0, 0, -housing_height/2])
            cylinder(h=nut_height, d=nut_diameter, $fn=64);
        
        // Mounting holes
        for (x = [-mount_hole_spacing/2, mount_hole_spacing/2])
            translate([x, 0, -housing_height/2])
                cylinder(h=housing_height, d=mount_hole_diameter, $fn=64);
    }
}

// Anti-backlash spring housing
module anti_backlash_spring_housing() {
    translate([0, 0, nut_height/2])
        cylinder(h=anti_backlash_spring_height, d=anti_backlash_spring_diameter, $fn=64);
}

// Complete assembly
module leadscrew_nut_block() {
    union() {
        leadscrew_nut_housing();
        anti_backlash_spring_housing();
    }
}

// Render the leadscrew nut block
leadscrew_nut_block();