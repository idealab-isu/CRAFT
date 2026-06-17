$fn = 96;

// Parameters (mm)
block_length = 30.0;   // X
block_width  = 25.0;   // Y
block_height = 15.0;   // Z

shaft_diameter         = 6.0;    // through bore for shaft (along X)
bearing_outer_diameter = 12.0;   // larger housing/bore feature (visual/fit)
bearing_length         = 20.0;   // length of larger bore along X (centered)

mounting_hole_diameter  = 3.0;
mounting_hole_spacing_x = 20.0;  // center-to-center along X
mounting_hole_spacing_y = 15.0;  // center-to-center along Y

counterbore_diameter = 6.0;
counterbore_depth    = 2.0;

eps = 0.02;

module linear_bearing_block_6mm() {

    // Clamp bearing_length to block_length (cannot exceed)
    bl = min(bearing_length, block_length);

    difference() {
        // Solid block
        cube([block_length, block_width, block_height], center=true);

        // Larger bearing housing bore (along X), limited to bearing_length
        rotate([0, 90, 0])
            cylinder(h = bl + 2*eps, d = bearing_outer_diameter, center=true);

        // Shaft bore (along X), through entire block
        rotate([0, 90, 0])
            cylinder(h = block_length + 2*eps, d = shaft_diameter, center=true);

        // Mounting through-holes (4x), through Z
        for (x = [-mounting_hole_spacing_x/2, mounting_hole_spacing_x/2])
            for (y = [-mounting_hole_spacing_y/2, mounting_hole_spacing_y/2])
                translate([x, y, 0])
                    cylinder(h = block_height + 2*eps, d = mounting_hole_diameter, center=true);

        // Counterbores from top face (Z+)
        for (x = [-mounting_hole_spacing_x/2, mounting_hole_spacing_x/2])
            for (y = [-mounting_hole_spacing_y/2, mounting_hole_spacing_y/2])
                translate([x, y, block_height/2 - counterbore_depth/2 + eps])
                    cylinder(h = counterbore_depth + 2*eps, d = counterbore_diameter, center=true);

        // Open the bearing/shaft channel to the top (creates visible linear-bearing "block" channel)
        // Slot width slightly larger than shaft diameter for clearance/printability.
        slot_w = shaft_diameter + 1.0;
        translate([0, 0, block_height/2])
            cube([block_length + 2*eps, slot_w, block_height + 2*eps], center=true);
    }
}

linear_bearing_block_6mm();