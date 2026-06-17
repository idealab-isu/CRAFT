$fn = 96;

module shaft_support_bracket(rod_d=10, total_h=20) {

    // Dimensions (mm)
    base_w = 40;
    base_d = 30;
    base_h = 5;

    block_w = 24;
    block_d = 24;
    block_h = total_h - base_h;

    hole_d = 3.2;
    hole_edge = 6;

    // Rod cradle (U-slot from top)
    cradle_clear = 0.4;
    cradle_d = rod_d + cradle_clear;
    cradle_r = cradle_d/2;

    // Slot opening width (so it is a cradle, not a full bore)
    slot_w = cradle_d * 0.75;

    // Ensure the cradle cuts through the full upper block height
    cradle_cut_h = block_h + 2;

    // Clamp split (thin slit from front to the cradle)
    split_w = 1.2;

    // Coordinate helpers (all solids sit on Z=0)
    base_z0 = 0;
    base_z1 = base_h;
    block_z0 = base_z1;
    block_z1 = total_h;

    // Cradle center height: slightly below top so it forms a U
    cradle_cz = block_z1 - cradle_r - 1.0;

    // Mounting hole positions
    hx1 = hole_edge;
    hx2 = base_w - hole_edge;
    hy1 = hole_edge;
    hy2 = base_d - hole_edge;

    difference() {
        // ONE connected solid body
        union() {
            // Base plate
            translate([0, 0, base_z0])
                cube([base_w, base_d, base_h], center=false);

            // Upper support block centered on base
            translate([(base_w - block_w)/2, (base_d - block_d)/2, block_z0])
                cube([block_w, block_d, block_h], center=false);
        }

        // Rod cradle: cylinder along Y, cut from the top (U-shape)
        translate([base_w/2, base_d/2, cradle_cz])
            rotate([90, 0, 0])
                cylinder(h = block_d + 2, d = cradle_d, center=true);

        // Slot opening to make it a cradle (remove a rectangular window above the cylinder)
        translate([base_w/2 - slot_w/2, base_d/2 - (block_d+2)/2, cradle_cz])
            cube([slot_w, block_d + 2, (block_z1 - cradle_cz) + cradle_r + 2], center=false);

        // Clamp split slit from front face into the cradle area
        translate([base_w/2 - split_w/2, (base_d - block_d)/2 - 1, cradle_cz - cradle_r - 2])
            cube([split_w, block_d/2 + 2, (block_z1 - (cradle_cz - cradle_r - 2)) + 1], center=false);

        // Mounting holes through base
        for (x = [hx1, hx2], y = [hy1, hy2])
            translate([x, y, base_h/2])
                cylinder(h = base_h + 0.6, d = hole_d, center=true);
    }
}

shaft_support_bracket();