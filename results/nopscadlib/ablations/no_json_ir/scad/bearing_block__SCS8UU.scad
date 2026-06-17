$fn = 128;

// Linear bearing block for 6.0mm shaft
// Block size: 34.0mm x 30.0mm (X x Y). Thickness along Z is parameterized.

block_x = 34.0;   // X
block_y = 30.0;   // Y
block_z = 20.0;   // Z

shaft_d = 6.0;    // shaft bore diameter (along X)

mount_d = 3.0;    // mounting hole diameter (through Z)
mount_spacing_x = 20.0;
mount_spacing_y = 20.0;

clamp_slot_w = 2.0;     // slot width (Y direction)
clamp_screw_d = 3.0;    // clamp screw hole diameter (along Y)
clamp_screw_x = 20.0;   // spacing between clamp screws along X

// Make the shaft channel clearly visible and more "bearing-block-like"
seat_open_angle = 120;  // degrees removed from the top to create a visible open seat
seat_relief_d = 10.0;   // larger relief around the bore to resemble a bearing seat

eps = 0.25;

// Connectivity overlap (1-2mm) to guarantee attachment between any sub-solids
overlap = 1.5;

module bearing_block_solid() {
    // Single connected solid body (explicit union to avoid accidental splits)
    union() {
        // Main body
        cube([block_x, block_y, block_z], center=true);

        // Added "bearing block" feature: a small top cap/bridge that is physically attached.
        // This ensures the model remains one connected piece even with aggressive seat opening cuts.
        // It overlaps into the main body by `overlap`.
        cap_x = block_x;
        cap_y = block_y;
        cap_z = 4.0;

        // Place cap so it intersects the top of the main body by `overlap`
        translate([0, 0, block_z/2 + cap_z/2 - overlap])
            cube([cap_x, cap_y, cap_z], center=true);

        // Added side ribs (left/center/right) as connecting geometry.
        // These address the "three separate pieces" issue by guaranteeing continuous material
        // across X, and they overlap into the main body by `overlap`.
        rib_z = block_z;
        rib_y = 6.0;
        rib_x = 6.0;

        // Center rib
        translate([0, 0, 0])
            cube([rib_x, rib_y, rib_z], center=true);

        // Left rib (attached to main body with overlap)
        translate([-(block_x/2 - rib_x/2 + overlap), 0, 0])
            cube([rib_x, rib_y, rib_z], center=true);

        // Right rib (attached to main body with overlap)
        translate([(block_x/2 - rib_x/2 + overlap), 0, 0])
            cube([rib_x, rib_y, rib_z], center=true);
    }
}

module linear_bearing_block() {
    difference() {
        // Ensure everything is one connected solid before subtracting features
        bearing_block_solid();

        // Primary shaft bore (through X)
        rotate([0, 90, 0])
            cylinder(h = block_x + 2*eps, d = shaft_d, center=true);

        // Secondary relief seat (through X)
        rotate([0, 90, 0])
            cylinder(h = block_x + 2*eps, d = seat_relief_d, center=true);

        // Open-top seat cut (removes a wedge from the top so the channel is visible)
        // Keep as-is, but the added cap/bridge ensures the body remains connected.
        for (a = [-seat_open_angle/2, seat_open_angle/2]) {
            rotate([0, 0, a])
                translate([0, (block_y/2) - (seat_relief_d/2), 0])
                    cube([block_x + 2*eps, block_y, block_z + 2*eps], center=true);
        }

        // Mounting holes: 4 holes through Z
        for (x = [-mount_spacing_x/2, mount_spacing_x/2])
            for (y = [-mount_spacing_y/2, mount_spacing_y/2])
                translate([x, y, 0])
                    cylinder(h = block_z + 2*eps, d = mount_d, center=true);

        // Split clamp slot: from top face down to slightly past bore center
        slot_depth = (block_z/2) - (-shaft_d/2) + eps; // from top to just below bore center
        translate([0, 0, block_z/2 - slot_depth/2 + eps])
            cube([block_x + 2*eps, clamp_slot_w, slot_depth], center=true);

        // Clamp screw holes: along Y, placed in the upper half so they intersect the slot region
        screw_z = block_z/4;
        for (x = [-clamp_screw_x/2, clamp_screw_x/2])
            translate([x, 0, screw_z])
                rotate([90, 0, 0])
                    cylinder(h = block_y + 2*eps, d = clamp_screw_d, center=true);
    }
}

linear_bearing_block();