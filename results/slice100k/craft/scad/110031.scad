// Dimension-calibrated (target: 11.00 x 18.92 x 8.76 mm)
scale([0.942258, 1.249545, 1.001270])
{
$fn = 96;

// Target bounding box (approx): X=11.0, Y=18.9, Z=8.8 mm
// Axes: X = barrel (short), Y = stem (long), Z = vertical

// --- Parameters (tuned to match description & bbox) ---
stem_len = 18.9;
stem_d   = 5.2;

barrel_len = 11.0;
barrel_d   = 6.6;

collar_d   = 7.6;
collar_h   = 2.2;          // along Y (distinct step/shoulder around stem)

flange_thk = 1.2;          // along X (barrel axis)
flange_W   = 8.8;          // along Y (stem axis)
flange_H   = 7.2;          // along Z

// Fork / U-slot at +X end of barrel (slot opens at +X)
slot_depth  = 4.6;         // how far slot goes into barrel from +X end (along X)
slot_widthY = 3.2;         // slot width along Y (sets prong thickness in Y)
slot_heightZ= 3.2;         // slot height along Z (gap between top/bottom prongs)
tip_chamfer = 0.6;

overlap = 1.2;             // ensure solid connectivity (1–2mm)
lead_in = 0.4;

// Helpers (centered primitives)
module cyl_x(d,h) cylinder(d=d, h=h, center=true);
module cyl_y(d,h) rotate([0,0,90]) cylinder(d=d, h=h, center=true); // axis along Y

// --- Solids ---
module stem() {
    // Long cylindrical stem along Y
    cyl_y(stem_d, stem_len);
}

module barrel() {
    // Short horizontal barrel along X
    cyl_x(barrel_d, barrel_len);
}

module collar() {
    // Stepped collar/shoulder at junction (around stem axis = Y)
    // Slightly longer to guarantee intersection with both stem and barrel
    cyl_y(collar_d, collar_h + overlap);
}

module flange() {
    // Flat rectangular stop plate at -X end of barrel
    // Positioned to touch/overlap the barrel end
    translate([-(barrel_len/2 + flange_thk/2 - overlap), 0, 0])
        cube([flange_thk, flange_W, flange_H], center=true);
}

// --- Subtractive features ---
module u_slot_void() {
    // Remove a rectangular slot from the +X end to create two parallel prongs
    // (top and bottom prongs; gap is along Z). Slot is centered in Y and Z.
    translate([barrel_len/2 - slot_depth/2 + overlap/2, 0, 0])
        cube([slot_depth + overlap, slot_widthY, slot_heightZ], center=true);
}

module tip_chamfer_voids() {
    // Chamfer the prong tips at +X end by cutting wedges on the top and bottom prongs.
    // Wedges are offset in Z so they only affect the remaining prongs (not the slot gap).
    cham_x = barrel_len/2 - tip_chamfer/2;

    // Z location of prong centers (top/bottom) relative to barrel center
    prong_center_z = (slot_heightZ/2) + (barrel_d/2 - slot_heightZ/2)/2;

    // Top prong chamfer
    translate([cham_x, 0, +prong_center_z])
        rotate([0,45,0])
            cube([tip_chamfer*2, slot_widthY + overlap, tip_chamfer*2], center=true);

    // Bottom prong chamfer
    translate([cham_x, 0, -prong_center_z])
        rotate([0,-45,0])
            cube([tip_chamfer*2, slot_widthY + overlap, tip_chamfer*2], center=true);
}

module barrel_end_leadins() {
    // Small lead-in chamfers on barrel ends (subtractive)
    // +X end
    translate([barrel_len/2 - lead_in/2, 0, 0])
        rotate([0,90,0])
            cylinder(r1=barrel_d/2, r2=max(0.01, barrel_d/2 - lead_in), h=lead_in*2, center=true);

    // -X end
    translate([-(barrel_len/2 - lead_in/2), 0, 0])
        rotate([0,-90,0])
            cylinder(r1=barrel_d/2, r2=max(0.01, barrel_d/2 - lead_in), h=lead_in*2, center=true);
}

module main_solid() {
    union() {
        stem();
        barrel();
        collar();
        flange();
    }
}

difference() {
    main_solid();

    // Forked/pronged end + chamfered tips (key missing feature)
    u_slot_void();
    tip_chamfer_voids();

    // Minor end lead-ins
    barrel_end_leadins();
}
}
