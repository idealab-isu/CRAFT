$fn = 96;

// Parameters (mm)
shaft_diameter = 6.0;

block_width  = 34.0;   // Y
block_length = 58.0;   // X
block_height = 20.0;   // Z

mounting_hole_diameter = 4.0;
mounting_hole_spacing_x = 24.0; // along X
mounting_hole_spacing_y = 48.0; // along Y

// Clamp slot (split) and clamp screw clearance holes
clamp_slot_width = 3.0;          // slot thickness along Y
clamp_screw_clear_d = 4.0;       // clearance for clamp screws
clamp_screw_spacing_x = 24.0;    // along X (same as mounting spacing)

// Bearing seat (typical SBR-style block has a larger bore/seat for the bushing)
bearing_seat_d = 12.0;           // OD seat for a small linear bushing (visual/typical)
bearing_seat_len = 40.0;         // length of seat along X (keeps end walls)

// Outer shaping (typical bearing block geometry)
side_relief_depth = 4.0;         // how much to relieve each side (Y) to create "ears"
side_relief_z0 = 6.0;            // start height of side relief from bottom
top_chamfer = 2.0;               // simple top edge chamfer (approx)

eps = 0.02;

// Connectivity overlap (1-2mm) for any added/attached solids
overlap = 1.2;

module sbr_bearing_block_assembly() {

    // Derived / clamped values to keep geometry valid and connected
    seat_len = min(bearing_seat_len, block_length - 2*(2.0)); // keep >=2mm end walls
    seat_len = max(seat_len, 10.0);

    // Side relief only above a certain Z so the base remains full width for mounting
    relief_h = max(block_height - side_relief_z0, 0.1);

    // Ensure mounting holes stay inside the block
    hole_x = min(mounting_hole_spacing_x/2, block_length/2 - mounting_hole_diameter);
    hole_y = min(mounting_hole_spacing_y/2, block_width/2  - mounting_hole_diameter);

    difference() {
        // --- SOLID BODY (one connected solid) ---
        union() {
            // Main rectangular body (exact overall size)
            cube([block_length, block_width, block_height], center=true);

            // Add a subtle top "cap" ridge to resemble bearing housing (connected)
            cap_h = 3.0;
            cap_w = block_width - 2*side_relief_depth;
            cap_w = max(cap_w, block_width*0.6);
            translate([0, 0, block_height/2 - cap_h/2])
                cube([block_length, cap_w, cap_h], center=true);

            // --- FIX: attach the small protruding tab/extension (was floating/disconnected) ---
            // Create a side tab that is guaranteed to intersect the main body by `overlap`.
            // This matches the "small blue tab/extension" seen on one side in the views.
            tab_x = 4.0;                 // protrusion length outward in X
            tab_y = 6.0;                 // tab width in Y
            tab_z = block_height;        // full height to match the visible vertical strip

            // Place on the -X end, near the -Y edge (as in the provided views),
            // with overlap into the main body so it cannot float.
            tab_center_x = -(block_length/2 + tab_x/2 - overlap);
            tab_center_y = -(block_width/2 - tab_y/2); // flush to -Y face
            tab_center_z = 0;

            translate([tab_center_x, tab_center_y, tab_center_z])
                cube([tab_x, tab_y, tab_z], center=true);
        }

        // --- INTERNAL FEATURES ---

        // Bearing seat (larger bore) along X, centered
        rotate([0, 90, 0])
            cylinder(h=seat_len + 2*eps, d=bearing_seat_d, center=true);

        // Shaft bore (through) along X, centered
        rotate([0, 90, 0])
            cylinder(h=block_length + 2*eps, d=shaft_diameter, center=true);

        // Mounting holes: 4 holes through Z (vertical), typical pattern
        for (x = [-hole_x, hole_x])
            for (y = [-hole_y, hole_y])
                translate([x, y, 0])
                    cylinder(h=block_height + 2*eps, d=mounting_hole_diameter, center=true);

        // Split clamp slot: cut from top down to slightly below shaft center
        slot_depth = block_height/2 + shaft_diameter/2 + 0.8; // reaches below bore
        translate([0, 0, block_height/2 - slot_depth/2 + eps])
            cube([block_length + 2*eps, clamp_slot_width, slot_depth + 2*eps], center=true);

        // Clamp screw clearance holes: through Y across the split, two holes along X
        for (x = [-clamp_screw_spacing_x/2, clamp_screw_spacing_x/2])
            translate([x, 0, 0])
                rotate([90, 0, 0])
                    cylinder(h=block_width + 2*eps, d=clamp_screw_clear_d, center=true);

        // --- EXTERNAL SHAPING CUTS (to avoid "two slabs" look) ---

        // Side relief pockets (create mounting "ears" look while keeping base full width)
        // Left relief
        translate([0,
                   -(block_width/2 - side_relief_depth/2) + eps,
                   -block_height/2 + side_relief_z0 + relief_h/2])
            cube([block_length + 2*eps, side_relief_depth + 2*eps, relief_h + 2*eps], center=true);

        // Right relief
        translate([0,
                   (block_width/2 - side_relief_depth/2) - eps,
                   -block_height/2 + side_relief_z0 + relief_h/2])
            cube([block_length + 2*eps, side_relief_depth + 2*eps, relief_h + 2*eps], center=true);

        // Simple top chamfer approximation: remove thin wedges along long edges
        cham_h = top_chamfer;
        cham_h = min(cham_h, block_height/3);
        cham_w = top_chamfer;
        cham_w = min(cham_w, block_width/4);

        // Long edge chamfers (front/back in Y) using rotated cubes
        for (sy = [-1, 1]) {
            translate([0,
                       sy*(block_width/2 - cham_w/2),
                       block_height/2 - cham_h/2])
                rotate([0, 0, 45])
                    cube([block_length + 2*eps, cham_w*1.6, cham_h*1.6], center=true);
        }
    }
}

sbr_bearing_block_assembly();