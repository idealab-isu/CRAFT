// Long linear bearing block for 9.0mm shaft
// Block size: 50.0mm (X) x 85.0mm (Y) x 25.0mm (Z)
// One connected solid (bearing/shaft not separate parts)

$fn = 96;

// --- Parameters (mm) ---
shaft_diameter = 9.0;
block_width    = 50.0;   // X
block_length   = 85.0;   // Y
block_height   = 25.0;   // Z

// Bore (through along Y). For a 9mm shaft, use a slightly larger bore.
bore_clearance = 0.20;
bore_diameter  = shaft_diameter + bore_clearance;

// Add recognizable bearing-block features (still ONE connected solid):
// - Raised cylindrical housing around the bore (top boss)
// - Clamp split slot from top down to the bore
// - Two clamp screw holes across X (through the boss), not floating
boss_diameter = 26.0;                 // outer housing diameter
boss_height   = 10.0;                 // height above top face
clamp_slot_w  = 2.0;                  // split width
clamp_slot_depth_to_bore = 0.6;       // extra depth past bore tangent (mm)

clamp_screw_diameter = 4.0;
clamp_screw_head_diameter = 7.5;      // shallow counterbore on +X side
clamp_screw_head_depth = 3.0;
clamp_screw_y_offset = 18.0;          // +/- along Y from center

// Mounting pattern (4 holes)
mount_hole_diameter   = 5.0;
counterbore_diameter  = 9.0;
counterbore_depth     = 3.0;

// Keep holes inside edges with a margin; compute spacing from block size
mount_edge_margin_x = 8.0;
mount_edge_margin_y = 10.0;
mount_hole_spacing_width  = block_width  - 2*mount_edge_margin_x; // X spacing
mount_hole_spacing_length = block_length - 2*mount_edge_margin_y; // Y spacing

// Small chamfer at bore entries
entry_chamfer = 0.8;

// Overlap for robust booleans
overlap = 1.0;

// --- Helpers ---
module bore_with_chamfers(d, len, chamfer) {
    // Main through bore (along Y)
    rotate([90,0,0])
        cylinder(d=d, h=len + 2*overlap, center=true);

    // Entry chamfers (approximated as short cones)
    for (sy = [-1, 1]) {
        translate([0, sy*(len/2 - chamfer/2), 0])
            rotate([90,0,0])
                cylinder(d1=d + 2*chamfer, d2=d, h=chamfer + overlap, center=true);
    }
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_spacing_width/2, sy*mount_hole_spacing_length/2, 0])
            cylinder(d=mount_hole_diameter, h=block_height + 2*overlap, center=true);
    }
}

module counterbores_top() {
    // Counterbores on top face (Z+)
    zc = block_height/2 - counterbore_depth/2 + overlap/2;
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_spacing_width/2, sy*mount_hole_spacing_length/2, zc])
            cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true);
    }
}

module clamp_slot() {
    // Slot from top of boss down to slightly past the bore tangent
    // Top of boss is at z = block_height/2 + boss_height
    z_top = block_height/2 + boss_height;
    // Bore top tangent is at z = 0 + bore_diameter/2
    z_target = bore_diameter/2 - clamp_slot_depth_to_bore;
    slot_h = z_top - z_target;

    // Center the slot volume so its top aligns with z_top
    zc = z_top - slot_h/2;

    translate([0, 0, zc])
        cube([clamp_slot_w, block_length + 2*overlap, slot_h + overlap], center=true);
}

module clamp_screw_holes() {
    // Two screws across X, through the boss region, at +/-Y offsets
    // Through-hole spans full width with overlap
    for (sy = [-1, 1]) {
        translate([0, sy*clamp_screw_y_offset, block_height/2 + boss_height/2])
            rotate([0,90,0])
                cylinder(d=clamp_screw_diameter, h=block_width + 2*overlap, center=true);

        // Shallow counterbore on +X side for screw head
        // Place so it starts at +X face and goes inward
        x_cb_center = block_width/2 - clamp_screw_head_depth/2 + overlap/2;
        translate([x_cb_center, sy*clamp_screw_y_offset, block_height/2 + boss_height/2])
            rotate([0,90,0])
                cylinder(d=clamp_screw_head_diameter, h=clamp_screw_head_depth + overlap, center=true);
    }
}

module body_with_boss() {
    union() {
        // Base block
        cube([block_width, block_length, block_height], center=true);

        // Raised cylindrical housing (boss) around bore on top face
        // Connected by construction: sits on top face with slight overlap
        zc = block_height/2 + boss_height/2 - overlap/2;
        translate([0, 0, zc])
            cylinder(d=boss_diameter, h=boss_height + overlap, center=true);
    }
}

// --- Main solid ---
module long_linear_bearing_block() {
    difference() {
        // Body (single connected solid with bearing housing)
        body_with_boss();

        // 9mm shaft bore (through along Y)
        bore_with_chamfers(bore_diameter, block_length, entry_chamfer);

        // Mounting holes + counterbores
        mounting_holes();
        counterbores_top();

        // Clamp split slot
        clamp_slot();

        // Clamp screw holes (across X)
        clamp_screw_holes();
    }
}

long_linear_bearing_block();