// Long linear bearing block for 8.0mm shaft
// Block footprint: 42.0mm x 70.0mm
// One connected solid (all features are booleaned from a single body)

$fn = 128;

// -------------------- Parameters --------------------
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
block_width_mm    = 42.0; //[21.0:84.0:0.5]   // X
block_length_mm   = 70.0; //[35.0:140.0:0.5]  // Y
block_height_mm   = 20.0; //[10.0:40.0:0.5]   // Z

// Bearing housing (SBR/SCS-style) geometry
bearing_outer_diameter_mm = 16.0; //[10.0:30.0:0.1]  // visible housing OD
boss_height_mm            = 10.0; //[6.0:16.0:0.5]   // housing height above base

// Bore / open slot
bore_clearance_mm         = 0.10; //[0.0:0.5:0.05]
slot_enabled              = 1; //[0:1:1]
slot_width_mm             = 3.0; //[1.0:8.0:0.1]     // clamp opening width
slot_depth_extra_mm       = 1.0; //[0.0:4.0:0.1]     // extend slot slightly past bore center

// Mounting
mount_hole_diameter_mm    = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_x_mm   = 26.0; //[13.0:52.0:0.5]
mount_hole_spacing_y_mm   = 54.0; //[27.0:108.0:0.5]
counterbore_diameter_mm   = 9.0; //[6.0:18.0:0.1]
counterbore_depth_mm      = 3.0; //[1.0:8.0:0.5]

// Edge treatment
corner_r_mm               = 2.0; //[0.0:6.0:0.1]
top_chamfer_mm            = 1.0; //[0.0:3.0:0.1]
eps_mm                    = 0.6; //[0.2:2.0:0.1]

// -------------------- Derived --------------------
bore_d_mm = shaft_diameter_mm + 2*bore_clearance_mm;
bore_r_mm = bore_d_mm/2;

boss_r_mm = bearing_outer_diameter_mm/2;

// Ensure boss is connected to base with overlap
boss_h_mm = min(boss_height_mm, block_height_mm*0.8);
boss_overlap_mm = 1.0;
boss_zc = (block_height_mm/2) + (boss_h_mm/2) - boss_overlap_mm;

// Slot: open from top down into bore (typical open bearing block)
slot_z_top = (block_height_mm/2) + boss_h_mm - boss_overlap_mm + eps_mm; // top of boss
slot_z_bot = 0 - (slot_depth_extra_mm); // slightly below bore center
slot_h_mm  = (slot_z_top - slot_z_bot);

// -------------------- Helpers --------------------
module rounded_rect_prism(size=[10,10,10], r=2, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, min(x,y)/2 - 0.01);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=rr)
                square([max(0.01, x-2*rr), max(0.01, y-2*rr)], center=true);
}

module mount_holes_through(total_h) {
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2, 0])
                cylinder(h=total_h, r=mount_hole_diameter_mm/2, center=true);
}

module mount_counterbores() {
    // Counterbores on top face of base (not on boss)
    zc = (block_height_mm/2) - (counterbore_depth_mm/2) + eps_mm/2;
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2, zc])
                cylinder(h=counterbore_depth_mm + eps_mm, r=counterbore_diameter_mm/2, center=true);
}

// -------------------- Main --------------------
module long_linear_bearing_block() {
    total_h_for_holes = block_height_mm + boss_h_mm + 6*eps_mm;

    difference() {
        union() {
            // Base block (42 x 70 footprint)
            rounded_rect_prism([block_width_mm, block_length_mm, block_height_mm], r=corner_r_mm, center=true);

            // Long bearing housing boss along full length (connected)
            translate([0, 0, boss_zc])
                cylinder(h=boss_h_mm, r=boss_r_mm, center=true);

            // Side flats (visual cue like SBR/SCS blocks), connected with overlap
            flat_w = max(4, (block_width_mm - 2*boss_r_mm)*0.45);
            flat_h = min(6, block_height_mm*0.35);
            flat_zc = (block_height_mm/2) - flat_h/2 + 0.8; // overlap into base
            for (sx = [-1, 1]) {
                translate([sx*(block_width_mm/2 - flat_w/2 + 0.8), 0, flat_zc])
                    rounded_rect_prism([flat_w, block_length_mm*0.82, flat_h], r=min(1.2, corner_r_mm), center=true);
            }
        }

        // Shaft bore through entire block along Y axis (verifiable 8mm + clearance)
        rotate([90, 0, 0])
            cylinder(h=block_length_mm + 2*eps_mm, r=bore_r_mm, center=true);

        // Open slot from top into bore (typical open bearing block)
        if (slot_enabled) {
            // Slot centered on X=0, runs full length in Y, cuts from top down past bore center
            translate([0, 0, (slot_z_top + slot_z_bot)/2])
                cube([slot_width_mm, block_length_mm + 2*eps_mm, slot_h_mm + 2*eps_mm], center=true);
        }

        // Mounting holes + counterbores
        mount_holes_through(total_h_for_holes);
        mount_counterbores();

        // Simple top chamfer by subtracting thin strips at perimeter (keeps one solid)
        if (top_chamfer_mm > 0) {
            // Along Y edges
            for (sy = [-1, 1]) {
                translate([0,
                           sy*(block_length_mm/2 - top_chamfer_mm/2),
                           block_height_mm/2 - top_chamfer_mm/2])
                    cube([block_width_mm + 2*eps_mm,
                          top_chamfer_mm + 2*eps_mm,
                          top_chamfer_mm + 2*eps_mm], center=true);
            }
            // Along X edges
            for (sx = [-1, 1]) {
                translate([sx*(block_width_mm/2 - top_chamfer_mm/2),
                           0,
                           block_height_mm/2 - top_chamfer_mm/2])
                    cube([top_chamfer_mm + 2*eps_mm,
                          block_length_mm + 2*eps_mm,
                          top_chamfer_mm + 2*eps_mm], center=true);
            }
        }
    }
}

long_linear_bearing_block();