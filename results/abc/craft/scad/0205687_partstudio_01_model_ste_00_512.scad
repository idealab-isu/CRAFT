// Dimension-calibrated (target: 0.04 x 0.04 x 0.02 mm)
scale([0.000950, 0.000950, 0.001111])
{
$fn = 160;

// Units: mm
disk_d = 40;
disk_t = 14;

// Front face recessed rim (ring pocket)
rim_outer_d = 38;
rim_inner_d = 30;
rim_depth   = 1.5;

// Back square peg (male)
peg_w = 12;
peg_t = 6;

// Central square feature: visible BOSS on the FRONT face
center_sq_w   = 10;
center_boss_h = 2.2;

// Optional: square through-hole aligned to peg (set to 0 to disable)
center_hole_w = 6;   // keep smaller than boss so boss remains visible
center_hole_depth = disk_t + center_boss_h + 4;

// Diamond cutouts (THROUGH the disk so they read clearly in ortho)
diamond_w = 6;
diamond_h = 10;
diamond_depth = disk_t + center_boss_h + 6; // ensure through disk + boss with margin
diamond_r = 12;                              // radius for surrounding diamonds

// Overlap / boolean safety
overlap = 1.2;   // 1–2mm overlap for solid connections
eps = 0.05;

// Main Circular Disk
module main_circular_disk() {
    cylinder(d=disk_d, h=disk_t, center=true);
}

// Back Square Peg (protrudes from back face) - connected with overlap
module back_square_peg() {
    // Disk spans z = [-disk_t/2, +disk_t/2]
    // Peg should attach to back face at z = -disk_t/2 with overlap into disk
    translate([0, 0, -disk_t/2 - peg_t/2 + overlap])
        cube([peg_w, peg_w, peg_t], center=true);
}

// Shallow recessed rim on the FRONT face (a ring-shaped pocket)
module front_recessed_rim_cut() {
    // Pocket sits within the top face: z = [disk_t/2 - rim_depth, disk_t/2]
    translate([0, 0, disk_t/2 - rim_depth/2])
        difference() {
            cylinder(d=rim_outer_d, h=rim_depth + 2*eps, center=true);
            cylinder(d=rim_inner_d, h=rim_depth + 4*eps, center=true);
        }
}

// Central square boss on FRONT face (visible in ortho) - connected with overlap
module central_square_boss() {
    // Boss attaches to front face at z = +disk_t/2 with overlap into disk
    translate([0, 0, disk_t/2 + center_boss_h/2 - overlap])
        cube([center_sq_w, center_sq_w, center_boss_h], center=true);
}

// Central square through feature (hole) aligned with peg/shaft interface
module central_square_through_hole() {
    if (center_hole_w > 0)
        // Centered at origin so it passes through disk and boss
        cube([center_hole_w, center_hole_w, center_hole_depth], center=true);
}

// Diamond cutout (2D diamond extruded)
module diamond_cutout() {
    linear_extrude(height=diamond_depth, center=true)
        polygon(points=[
            [0,  diamond_h/2],
            [ diamond_w/2, 0],
            [0, -diamond_h/2],
            [-diamond_w/2, 0]
        ]);
}

// Five diamond cutouts: one at top + four around it (NE/SE/SW/NW) for true "5" pattern
module five_diamond_cutouts() {
    union() {
        // One at the top (north)
        translate([0, diamond_r, 0]) diamond_cutout();

        // Four around the center, rotated 45° relative to axes (symmetric around the top one)
        for (a = [45, 135, 225, 315])
            rotate([0, 0, a]) translate([diamond_r, 0, 0]) diamond_cutout();
    }
}

// Final Assembly (one connected solid)
module miniature_knob() {
    difference() {
        union() {
            main_circular_disk();
            back_square_peg();
            central_square_boss();
        }

        // front recessed rim pocket
        front_recessed_rim_cut();

        // diamond cutouts (through)
        five_diamond_cutouts();

        // central square through feature (hole)
        central_square_through_hole();
    }
}

color([0.85, 0.85, 0.8])
miniature_knob();
}
