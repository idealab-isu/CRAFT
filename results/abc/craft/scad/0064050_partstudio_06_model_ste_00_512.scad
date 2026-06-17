// Dimension-calibrated (target: 0.04 x 0.06 x 0.09 mm)
scale([0.975000, 1.688080, 0.977528])
{
$fn = 64;

// -------------------- Parameters (mm) --------------------
bbox_x = 0.04;   // overall width (X)
bbox_y = 0.06;   // overall thickness (Y)
bbox_z = 0.09;   // overall length (Z)  (axial direction)

collar_h = 0.02;
collar_flat_d = 0.06;   // across flats (approx) for hex collar
hole_d = 0.02;

shank_l = 0.07;
shank_w = 0.04;
shank_t = 0.03;

slot_l = 0.03;
slot_w = 0.012;
slot_offset_x = 0.012;  // slots side-by-side in X

rib_h = 0.006;          // rib height in Y
rib_w = 0.01;           // rib width in X

overlap = 0.001;

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep everything within the requested bounding box
// Total Z = collar_h + shank_l
// Total Y = max(collar_flat_d, shank_t + rib_h)  (collar is the thickest)
shank_l_eff = clamp(shank_l, 0.001, bbox_z - collar_h);
collar_h_eff = clamp(collar_h, 0.001, bbox_z - shank_l_eff);

collar_d_eff = clamp(collar_flat_d, 0.001, min(bbox_x, bbox_y));
shank_w_eff  = clamp(shank_w, 0.001, bbox_x);
shank_t_eff  = clamp(shank_t, 0.001, bbox_y);

rib_w_eff = clamp(rib_w, 0.001, shank_w_eff);
rib_h_eff = clamp(rib_h, 0.001, bbox_y - shank_t_eff);

hole_d_eff = clamp(hole_d, 0.001, collar_d_eff * 0.9);

slot_l_eff = clamp(slot_l, 0.001, shank_l_eff * 0.9);
slot_w_eff = clamp(slot_w, 0.001, min(shank_t_eff, shank_w_eff) * 0.9);

// Slot centers in X, ensure they stay inside shank width
slot_offset_x_eff = clamp(slot_offset_x, 0, (shank_w_eff - slot_w_eff) / 2);

// -------------------- Geometry --------------------
module collar_hex() {
    // Hex-like collar/head at +Z end
    translate([0, 0, shank_l_eff + collar_h_eff/2 - overlap])
        cylinder(h=collar_h_eff, r=collar_d_eff/2, $fn=6, center=true);
}

module shank_block() {
    // Rectangular shank from Z=0..shank_l_eff
    translate([0, 0, shank_l_eff/2])
        cube([shank_w_eff, shank_t_eff, shank_l_eff], center=true);
}

module rib_fin() {
    // Central longitudinal rib on top face of shank (positive Y)
    translate([0, shank_t_eff/2 + rib_h_eff/2 - overlap, shank_l_eff/2])
        cube([rib_w_eff, rib_h_eff, shank_l_eff], center=true);
}

module through_hole() {
    // Through-opening along axis (Z)
    translate([0, 0, (shank_l_eff + collar_h_eff)/2])
        cylinder(h=shank_l_eff + collar_h_eff + 2*overlap, r=hole_d_eff/2, center=true);
}

module oval_slot_at(xc) {
    // Elongated oval slot through shank thickness (Y), oriented along Z
    // Use hull of two cylinders (axis Y) to make a capsule/oval.
    zc = shank_l_eff/2;
    dz = slot_l_eff/2 - slot_w_eff/2;
    translate([xc, 0, zc])
        hull() {
            translate([0, 0, -dz])
                rotate([90, 0, 0])
                    cylinder(h=shank_t_eff + 2*overlap, r=slot_w_eff/2, center=true);
            translate([0, 0,  dz])
                rotate([90, 0, 0])
                    cylinder(h=shank_t_eff + 2*overlap, r=slot_w_eff/2, center=true);
        }
}

// -------------------- Final solid (one connected part) --------------------
difference() {
    union() {
        shank_block();
        rib_fin();
        collar_hex();
    }

    // Cuts
    through_hole();
    oval_slot_at( slot_offset_x_eff);
    oval_slot_at(-slot_offset_x_eff);
}
}
