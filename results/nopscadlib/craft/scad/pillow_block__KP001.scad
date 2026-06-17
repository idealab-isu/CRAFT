$fn = 128;

// -------------------- Requested key dimensions --------------------
shaft_diameter_mm = 12.0;     // bore for shaft (through Y)
base_length_mm    = 71.0;     // X footprint
base_width_mm     = 56.0;     // Y footprint

// -------------------- KP-style mounting (2 slots along X) --------------------
mounting_hole_diameter_mm       = 10.0;
mounting_hole_center_spacing_mm = 55.0;  // X spacing between slot centers
slot_length_mm                  = 18.0;  // along X
hole_edge_offset_y_mm           = 14.0;  // from -Y edge to hole center

// -------------------- Base / feet --------------------
base_thickness_mm = 10.0;

// Raised feet pads (typical pillow block "feet" look)
foot_pad_thickness_mm = 4.0;
foot_pad_length_x_mm  = 26.0;
foot_pad_width_y_mm   = 18.0;

// -------------------- Housing geometry --------------------
housing_length_x_mm = 52.0;
housing_width_y_mm  = 34.0;
housing_block_h_mm  = 18.0;

// Arch (semi-cylinder) over the insert
arch_outer_d_mm = 44.0;     // outer diameter of arch
arch_len_y_mm   = 34.0;     // length along Y (matches housing width)

// Top cap (split housing look)
cap_thickness_mm  = 8.0;
cap_overhang_x_mm = 8.0;
cap_overhang_y_mm = 6.0;

// Side gussets (triangular ribs)
rib_len_x_mm       = 14.0;   // how far rib extends in X from housing side
rib_thickness_y_mm = 8.0;    // rib thickness in Y
rib_height_mm      = housing_block_h_mm + arch_outer_d_mm*0.35;

// Side inserts/spacers (the orange parts in top view) - must be attached
side_insert_thickness_x_mm = 6.0;   // thickness in X (outboard)
side_insert_len_y_mm       = 16.0;  // length along Y
side_insert_height_z_mm    = 10.0;  // height in Z

// Overlap to guarantee watertight unions
overlap_mm = 1.5;

// -------------------- Helpers --------------------
module rounded_slot_2d(len, dia) {
    hull() {
        translate([-(len/2 - dia/2), 0]) circle(d=dia);
        translate([ +(len/2 - dia/2), 0]) circle(d=dia);
    }
}

module slot_hole_3d(len, dia, h) {
    linear_extrude(height=h, center=true)
        rounded_slot_2d(len, dia);
}

module rib_tri_2d(len_x, height_z) {
    polygon(points=[
        [0, 0],
        [len_x, 0],
        [0, height_z]
    ]);
}

module gusset_rib(side=1, ysign=1) {
    // Rib connects base to housing side with overlap.
    x0 = side*(housing_length_x_mm/2 - overlap_mm);
    y0 = ysign*(housing_width_y_mm/2 - rib_thickness_y_mm/2);
    z0 = base_thickness_mm/2 - overlap_mm;

    translate([x0, y0, z0])
        rotate([0, 90, 0])  // extrude along X
            linear_extrude(height=rib_len_x_mm, center=false)
                rib_tri_2d(rib_height_mm, rib_thickness_y_mm);
}

// -------------------- Main solids --------------------
module base_plate() {
    cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);
}

module foot_pads() {
    // Two pads under the mounting slot regions to read as "feet"
    y_pos = -base_width_mm/2 + hole_edge_offset_y_mm;
    zc = -(base_thickness_mm/2) - foot_pad_thickness_mm/2 + overlap_mm;

    for (sx = [-1, 1]) {
        translate([sx*mounting_hole_center_spacing_mm/2, y_pos, zc])
            cube([foot_pad_length_x_mm, foot_pad_width_y_mm, foot_pad_thickness_mm], center=true);
    }
}

module housing_block() {
    translate([0, 0, base_thickness_mm/2 + housing_block_h_mm/2 - overlap_mm])
        cube([housing_length_x_mm, housing_width_y_mm, housing_block_h_mm], center=true);
}

module arch_over_insert() {
    // Semi-cylinder arch sitting on top of housing block, length along Y.
    center_z = base_thickness_mm/2 + housing_block_h_mm - overlap_mm; // arch "base" overlaps housing top
    translate([0, 0, center_z])
        intersection() {
            rotate([90, 0, 0])
                cylinder(d=arch_outer_d_mm, h=arch_len_y_mm, center=true);
            // keep upper half only
            translate([0, 0, arch_outer_d_mm/4])
                cube([base_length_mm*2, base_width_mm*2, arch_outer_d_mm], center=true);
        }
}

module top_cap() {
    cap_x = housing_length_x_mm + 2*cap_overhang_x_mm;
    cap_y = housing_width_y_mm  + 2*cap_overhang_y_mm;

    // Place cap so it overlaps arch and housing
    zc = base_thickness_mm/2 + housing_block_h_mm + (arch_outer_d_mm/4) - overlap_mm;
    translate([0, 0, zc])
        cube([cap_x, cap_y, cap_thickness_mm], center=true);
}

module side_inserts_spacers() {
    // These were floating/disconnected in the provided model.
    // Fix: attach them by overlapping into the housing block by overlap_mm.
    //
    // Place them at the housing mid-height so they intersect the housing side walls.
    zc = base_thickness_mm/2 + housing_block_h_mm/2; // centered on housing block
    // Keep them within the housing Y span (so they don't float outside)
    y0 = 0;

    for (side = [-1, 1]) {
        // Inner face of insert goes overlap_mm into housing:
        // housing side face at x = side*(housing_length_x_mm/2)
        // insert center x = side*(housing_length_x_mm/2 + insert_thickness/2 - overlap)
        xc = side*(housing_length_x_mm/2 + side_insert_thickness_x_mm/2 - overlap_mm);

        translate([xc, y0, zc])
            cube([side_insert_thickness_x_mm, side_insert_len_y_mm, side_insert_height_z_mm], center=true);
    }
}

// -------------------- Cuts --------------------
module mounting_slots_cut() {
    // Two slots on base, offset in Y from -edge
    y_pos = -base_width_mm/2 + hole_edge_offset_y_mm;
    zc = 0;

    for (sx = [-1, 1]) {
        translate([sx*mounting_hole_center_spacing_mm/2, y_pos, zc])
            slot_hole_3d(
                slot_length_mm,
                mounting_hole_diameter_mm,
                base_thickness_mm + 2*foot_pad_thickness_mm + 6*overlap_mm
            );
    }
}

module shaft_bore_cut() {
    // Through bore along Y, centered in arch
    center_z = base_thickness_mm/2 + housing_block_h_mm - overlap_mm;
    translate([0, 0, center_z])
        rotate([90, 0, 0])
            cylinder(d=shaft_diameter_mm, h=base_width_mm + 6*overlap_mm, center=true);
}

module insert_seat_cut() {
    // Larger seat around bore to suggest insert pocket
    seat_d = 28.0;
    center_z = base_thickness_mm/2 + housing_block_h_mm - overlap_mm;
    translate([0, 0, center_z])
        rotate([90, 0, 0])
            cylinder(d=seat_d, h=housing_width_y_mm*0.75 + 6*overlap_mm, center=true);
}

// -------------------- Assembly --------------------
module pillow_block_solid() {
    union() {
        base_plate();
        foot_pads();
        housing_block();
        arch_over_insert();
        top_cap();

        // FIX: add/attach side inserts/spacers with guaranteed overlap into housing
        side_inserts_spacers();

        // Gussets (connected to housing and base)
        gusset_rib(+1, +1);
        gusset_rib(-1, +1);
        gusset_rib(+1, -1);
        gusset_rib(-1, -1);
    }
}

difference() {
    pillow_block_solid();
    mounting_slots_cut();
    shaft_bore_cut();
    insert_seat_cut();
}