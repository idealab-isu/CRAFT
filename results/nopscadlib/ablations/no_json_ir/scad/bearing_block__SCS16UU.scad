$fn = 120;

// ===== Parameters (mm) =====
length = 50.0;   // X
width  = 44.0;   // Y
height = 20.0;   // Z

shaft_diameter   = 9.0;   // through bore for shaft (along X)
bearing_diameter = 15.0;  // bearing OD seat (along X)
bearing_length   = 16.0;  // seat length along X (centered)

mounting_hole_diameter  = 4.0;
mounting_hole_spacing_x = 30.0;
mounting_hole_spacing_y = 30.0;

clamp_slot_width     = 2.0;  // split slot width (opens from top to bore)
clamp_screw_diameter = 3.0;
clamp_screw_spacing  = 20.0;

// Small overlap to avoid coincident faces
eps = 0.02;

// Structural overlap to guarantee fusion (1-2mm as required)
overlap = 1.5;

// ===== Helpers =====
module body() {
    cube([length, width, height], center=true);
}

module shaft_bore() {
    // Through-bore along X
    rotate([0, 90, 0])
        cylinder(h = length + 2*eps, d = shaft_diameter, center=true);
}

module bearing_seat() {
    // Bearing seat along X, limited to bearing_length (not full length)
    seat_len = min(bearing_length, length);
    rotate([0, 90, 0])
        cylinder(h = seat_len + 2*eps, d = bearing_diameter, center=true);
}

module mounting_holes() {
    // 4 vertical mounting holes
    for (x = [-mounting_hole_spacing_x/2, mounting_hole_spacing_x/2])
        for (y = [-mounting_hole_spacing_y/2, mounting_hole_spacing_y/2])
            translate([x, y, 0])
                cylinder(h = height + 2*eps, d = mounting_hole_diameter, center=true);
}

module split_clamp_slot() {
    // Slot from TOP down to (and slightly past) the shaft centerline
    slot_depth = height/2 + shaft_diameter/2 + 1.0;
    translate([0, 0, height/2 - slot_depth/2 + eps])
        cube([length + 2*eps, clamp_slot_width, slot_depth + 2*eps], center=true);
}

module clamp_screw_holes() {
    // Two clamp screw holes across Y, above the shaft centerline
    z_pos = min(shaft_diameter/2 + 4.0, height/2 - 3.0);
    for (x = [-clamp_screw_spacing/2, clamp_screw_spacing/2])
        translate([x, 0, z_pos])
            rotate([90, 0, 0])
                cylinder(h = width + 2*eps, d = clamp_screw_diameter, center=true);
}

// ===== Connectivity Fixes =====
// 1) Fuse the two "blue halves" across the clamp slot WITHOUT blocking the shaft bore.
//    This is done by adding two thin ribs on the left/right sides of the bore (in Y),
//    located below the shaft centerline so the top split remains open.
module clamp_fuse_ribs() {
    // How far from center the ribs sit (keep clear of the bore + a little margin)
    bore_r = shaft_diameter/2;
    margin = 0.6; // small clearance so we don't intrude into the bore
    y_clear = bore_r + margin;

    // Rib thickness across Y (must be >0 and provide 1-2mm overlap into both halves)
    rib_y = overlap; // 1.5mm

    // Rib height in Z: from bottom up to just below shaft centerline, with overlap
    rib_z = (height/2 - bore_r) + overlap;
    rib_z = max(rib_z, overlap);

    // Place ribs so their top slightly overlaps above z=0 (shaft centerline) by overlap/2,
    // but they still won't block the bore because they are outside the bore in Y.
    z_center = -height/2 + rib_z/2;

    // Full length in X for robust fusion
    for (side = [-1, 1]) {
        translate([0, side*(y_clear + rib_y/2 - overlap/2), z_center])
            cube([length + 2*eps, rib_y + overlap, rib_z], center=true);
    }
}

// 2) Add a thin internal liner/insert that is GUARANTEED to be attached.
//    It spans the clamp slot region and overlaps into the surrounding body by 1-2mm.
//    It is kept OUTSIDE the shaft bore region (in Z) so it doesn't obstruct the shaft.
module attached_liner() {
    // Liner thickness across the split (Y). Make it slightly wider than the slot
    // so it intersects the body on both sides by ~overlap.
    liner_y = clamp_slot_width + 2*overlap;

    // Liner thickness in Z (thin plate)
    liner_z = 2.0; // small but printable

    // Place liner just below the shaft centerline so it doesn't intersect the bore.
    // Ensure it still intersects the body (it will, since it's inside the block).
    z_top_limit = -shaft_diameter/2 - 0.4; // keep below bore
    z_center = z_top_limit - liner_z/2;

    translate([0, 0, z_center])
        cube([length + 2*eps, liner_y, liner_z], center=true);
}

// ===== Assembly =====
difference() {
    union() {
        // Main body
        body();

        // Connectivity: ensure no split halves / no gaps / no floating insert
        clamp_fuse_ribs();
        attached_liner();
    }

    // Core functional features
    shaft_bore();
    bearing_seat();

    // Mounting + clamp features
    mounting_holes();
    split_clamp_slot();
    clamp_screw_holes();
}