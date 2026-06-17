// Linear bearing block for 8.0mm shaft (SCS8-style)
// Block footprint: 42.0mm x 36.0mm
// One connected solid (bearing shown as internal void only; no separate floating parts).

// -------------------- Parameters --------------------
block_length = 42;   // X
block_width  = 36;   // Y
block_height = 24;   // Z

shaft_diameter = 8.0;
tolerance_clearance = 0.2;
bore_diameter = shaft_diameter + tolerance_clearance;   // through bore

// LM8UU-ish seat (common in SCS8 blocks)
bearing_outer_diameter = 15.0 + 0.2;  // slight clearance
bearing_length = 24.0;               // (not used; seat modeled through for simplicity)
use_bearing_seat = 1;                // 1 = seat for LM8UU OD, 0 = only bore

// Mounting holes (SCS8 typical: 4x M5)
mount_hole_diameter = 5.2;
mount_hole_spacing_x = 28;  // X spacing
mount_hole_spacing_y = 22;  // Y spacing
counterbore_diameter = 9.5;
counterbore_depth = 4;

// Clamp slit + clamp screw boss (side ear)
clamp_slit_width = 1.2;     // slit thickness
clamp_slit_depth = 18;      // how far down from top
clamp_screw_hole_diameter = 3.4; // M3 clearance
clamp_screw_boss_diameter = 10;
clamp_screw_boss_thickness = 6;  // ear thickness (extends in +X)

// Edge treatment
chamfer_size = 1.0;

// Robust boolean overlap (use 1-2mm to guarantee connections)
overlap = 1.2;

// -------------------- Helpers --------------------
module mounting_holes() {
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx * mount_hole_spacing_x/2, sy * mount_hole_spacing_y/2, 0])
                cylinder(d=mount_hole_diameter, h=block_height + 2*overlap, center=true, $fn=48);
}

module mounting_counterbores() {
    // Counterbores from TOP face only
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx * mount_hole_spacing_x/2, sy * mount_hole_spacing_y/2,
                       block_height/2 - counterbore_depth/2 + overlap/2])
                cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=64);
}

module corner_chamfers() {
    // Simple 45° corner chamfers by subtracting cubes at corners
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*(block_length/2 - chamfer_size/2),
                       sy*(block_width/2  - chamfer_size/2), 0])
                cube([chamfer_size, chamfer_size, block_height + 2*overlap], center=true);
}

module bearing_seat_and_bore() {
    // Axis along X (typical SCS blocks: shaft runs along X)
    seat_d = (use_bearing_seat == 1) ? bearing_outer_diameter : bore_diameter;

    // Seat pocket (through along X for simplicity)
    rotate([0, 90, 0])
        cylinder(d=seat_d, h=block_length + 2*overlap, center=true, $fn=96);

    // Through bore for shaft
    rotate([0, 90, 0])
        cylinder(d=bore_diameter, h=block_length + 2*overlap, center=true, $fn=96);
}

module clamp_slit() {
    // Slit from top down, centered in Y, running across X
    // IMPORTANT: extend slightly in Y so it fully cuts through (prevents "two halves" artifact from coplanar faces)
    translate([0, 0, block_height/2 - clamp_slit_depth/2])
        cube([block_length + 2*overlap, clamp_slit_width + 2*overlap, clamp_slit_depth + overlap], center=true);
}

module clamp_screw_hole() {
    // Screw passes through the ear in X direction, centered on slit height
    zc = block_height/2 - clamp_slit_depth/2;

    // Ensure the hole fully spans the boss and slightly enters the main body
    translate([block_length/2 + clamp_screw_boss_thickness/2 - overlap, 0, zc])
        rotate([0, 90, 0])
            cylinder(d=clamp_screw_hole_diameter,
                     h=clamp_screw_boss_thickness + 4*overlap, center=true, $fn=48);
}

module clamp_boss() {
    // Ear/boss attached to +X side, centered on slit height
    // Center X so its left face penetrates into the main block by 'overlap'
    zc = block_height/2 - clamp_slit_depth/2;

    // left_face = x_center - thickness/2 = block_length/2 - overlap
    x_center = block_length/2 + clamp_screw_boss_thickness/2 - overlap;

    translate([x_center, 0, zc])
        rotate([0, 90, 0])
            cylinder(d=clamp_screw_boss_diameter, h=clamp_screw_boss_thickness, center=true, $fn=64);
}

// -------------------- Main solid --------------------
module linear_bearing_block_scs8() {

    // Build as ONE continuous body (prevents the "split into two halves" look/mesh issues):
    // - main block
    // - clamp boss
    // - a thin internal "bridge" across the slit region near the bottom so the part is physically one piece
    //   (keeps the clamp slit functional while guaranteeing connectivity)
    zc_slit = block_height/2 - clamp_slit_depth/2;
    slit_bottom_z = zc_slit - clamp_slit_depth/2; // bottom of slit cut volume
    bridge_thickness_z = max(1.0, overlap);        // 1-2mm physical connection
    bridge_center_z = slit_bottom_z - bridge_thickness_z/2 - 0.01; // sit just below slit cut

    difference() {
        union() {
            cube([block_length, block_width, block_height], center=true);
            clamp_boss();

            // Connectivity bridge: spans across Y at the slit location, inside the block.
            // This removes any chance of two disconnected halves after the slit subtraction.
            translate([0, 0, bridge_center_z])
                cube([block_length + 2*overlap, clamp_slit_width + 6*overlap, bridge_thickness_z], center=true);
        }

        mounting_holes();
        mounting_counterbores();
        bearing_seat_and_bore();
        clamp_slit();
        clamp_screw_hole();
        corner_chamfers();
    }
}

linear_bearing_block_scs8();