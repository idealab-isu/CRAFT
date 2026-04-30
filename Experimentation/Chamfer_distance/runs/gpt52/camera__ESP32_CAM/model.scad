$fn = 64;

// Simple camera module representation with a lens body approximating FOV (41°x54°)
// and a ribbon connector sized 15 x 2.2 x 1 mm.

module camera_module(){
    // Base board/body (generic, centered)
    board_x = 25;
    board_y = 25;
    board_z = 1.6;

    // Lens barrel
    barrel_d = 12;
    barrel_h = 6;

    // FOV visualization frustum (not hollow, just a solid "view cone")
    // Using half-angles: 41° -> 20.5°, 54° -> 27°
    // At distance L, width = 2*L*tan(half_angle)
    L = 25;
    fov_w = 2 * L * tan(27);
    fov_h = 2 * L * tan(20.5);

    // Ribbon connector dimensions (given)
    ribbon_w = 15;   // along X
    ribbon_h = 2.2;  // along Y
    ribbon_t = 1;    // along Z

    union() {
        // Board
        translate([0, 0, 0])
            cube([board_x, board_y, board_z], center=true);

        // Lens barrel on top
        translate([0, 0, board_z/2 + barrel_h/2])
            cylinder(d=barrel_d, h=barrel_h, center=true);

        // Lens front rim
        translate([0, 0, board_z/2 + barrel_h + 0.8])
            cylinder(d=barrel_d*0.9, h=1.6, center=true);

        // FOV frustum protruding from lens front
        // Small end near lens, large end at distance L
        near_w = 2 * 1 * tan(27);
        near_h = 2 * 1 * tan(20.5);
        translate([0, 0, board_z/2 + barrel_h + 1.6])
            hull() {
                // near rectangle (slightly in front of lens)
                translate([0, 0, 0.5])
                    cube([max(near_w, 2), max(near_h, 2), 1], center=true);
                // far rectangle at distance L
                translate([0, 0, L + 0.5])
                    cube([fov_w, fov_h, 1], center=true);
            }

        // Ribbon connector from one edge of board (centered near origin overall)
        translate([0, -(board_y/2 + ribbon_h/2), -(board_z/2 - ribbon_t/2)])
            cube([ribbon_w, ribbon_h, ribbon_t], center=true);

        // Small connector housing on board edge
        translate([0, -(board_y/2 - 1.2), board_z/2 + 0.75])
            cube([16, 4, 1.5], center=true);
    }
}

camera_module();