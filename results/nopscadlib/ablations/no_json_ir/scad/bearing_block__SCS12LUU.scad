$fn = 96;

// Parameters (mm)
shaft_diameter        = 8.0;

block_width           = 42.0;   // X
block_length          = 70.0;   // Y
block_height          = 20.0;   // Z

mount_hole_diameter   = 4.0;
mount_hole_spacing_x  = 30.0;   // X spacing between hole centers
mount_hole_spacing_y  = 60.0;   // Y spacing between hole centers

clamp_screw_diameter  = 3.0;    // through-hole for clamp screw
clamp_screw_spacing_x = 24.0;   // X spacing between clamp screw centers (kept for compatibility)

clamp_slot_width      = 2.0;    // slit width (X)
clamp_slot_depth      = 5.0;    // depth from top surface (Z)

chamfer_size          = 2.0;    // edge chamfer size

eps = 0.02;

// Connectivity controls
overlap = 1.2;                  // 1–2mm overlap to guarantee merging
bridge_thickness = 1.6;         // solid web thickness across the slit (X)
bridge_height    = 1.6;         // solid web height at top (Z)

// Chamfered rectangular prism using Minkowski (keeps ONE connected solid)
module chamfered_block(size=[10,10,10], c=1) {
    inner = [max(eps, size[0]-2*c), max(eps, size[1]-2*c), max(eps, size[2]-2*c)];
    minkowski() {
        cube(inner, center=true);
        polyhedron(
            points=[
                [ c, 0, 0], [-c, 0, 0],
                [ 0, c, 0], [ 0,-c, 0],
                [ 0, 0, c], [ 0, 0,-c]
            ],
            faces=[
                [0,2,4],[2,1,4],[1,3,4],[3,0,4],
                [2,0,5],[1,2,5],[3,1,5],[0,3,5]
            ]
        );
    }
}

module sbr8_linear_bearing_block() {

    // Build as: (body + internal bridge) - (holes + slit)
    // The bridge guarantees the two halves are physically connected (no seam/gap),
    // while keeping the clamp slit functionally present.
    difference() {
        union() {
            // Main body
            chamfered_block([block_width, block_length, block_height], chamfer_size);

            // Internal bridge/web across the slit near the top surface.
            // Make it LONGER in Y so it intersects the body at BOTH ends (prevents "floating strip" look).
            // Also overlap in X and Z to guarantee fusion.
            translate([0, 0, block_height/2 - bridge_height/2 - eps])
                cube([bridge_thickness + 2*overlap,
                      block_length + 2*overlap,
                      bridge_height + 2*overlap], center=true);
        }

        // Shaft bore (along Y axis through the length)
        rotate([90, 0, 0])
            cylinder(h=block_length + 2*eps, d=shaft_diameter, center=true);

        // Mounting holes (through Z)
        for (x = [-mount_hole_spacing_x/2, mount_hole_spacing_x/2])
            for (y = [-mount_hole_spacing_y/2, mount_hole_spacing_y/2])
                translate([x, y, 0])
                    cylinder(h=block_height + 2*eps, d=mount_hole_diameter, center=true);

        // Clamp slit from top down, but STOP before the bridge so the block stays connected.
        // Ensure the slit spans the full length (with eps) but does NOT cut through the bridge.
        slit_h = max(eps, clamp_slot_depth - bridge_height);
        translate([0, 0, block_height/2 - slit_h/2 + eps])
            cube([clamp_slot_width,
                  block_length + 2*eps,
                  slit_h + 2*eps], center=true);

        // Clamp screw holes (through X, crossing the slit region)
        for (z = [block_height/2 - clamp_slot_depth/2])
            for (y = [-block_length*0.20, block_length*0.20])
                translate([0, y, z])
                    rotate([0, 90, 0])
                        cylinder(h=block_width + 2*eps, d=clamp_screw_diameter, center=true);
    }
}

sbr8_linear_bearing_block();