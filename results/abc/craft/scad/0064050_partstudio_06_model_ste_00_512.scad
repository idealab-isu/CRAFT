// Dimension-calibrated (target: 0.04 x 0.06 x 0.09 mm)
scale([1.083357, 1.702763, 0.961338])
{
// Small axially oriented fitting: faceted collar with through-bore + slotted shank + central rib
// Units: mm

// ---------- Parameters (kept from original, but made consistent) ----------
bbox_x = 0.04; //[0.02:0.08:0.001]
bbox_y = 0.06; //[0.03:0.12:0.001]
bbox_z = 0.09; //[0.045:0.18:0.001]

collar_z = 0.02; //[0.01:0.04:0.001]
collar_facets = 6; //[6:6:1]
collar_radius = 0.018; //[0.009:0.03:0.001]
hole_d = 0.018; //[0.009:0.03:0.001]

shank_z = 0.07; //[0.035:0.14:0.001]
shank_x = 0.028; //[0.014:0.04:0.001]
shank_y = 0.036; //[0.018:0.06:0.001]

slot_len = 0.022; //[0.011:0.04:0.001]
slot_w = 0.008; //[0.004:0.016:0.001]
slot_z_center_1 = 0.02; //[0.01:0.06:0.001]
slot_z_center_2 = 0.045; //[0.02:0.065:0.001]

rib_thk = 0.004; //[0.002:0.008:0.001]
rib_h = 0.01; //[0.005:0.02:0.001]
rib_z_start = 0.0; //[0.0:0.02:0.001]
rib_z_end = 0.07; //[0.04:0.07:0.001]

overlap = 0.001; //[0.0005:0.002:0.0005]

// ---------- Derived placement (no arbitrary translates) ----------
total_z = collar_z + shank_z;

// Place model so collar top is at +total_z/2 and shank bottom at -total_z/2
collar_cz =  total_z/2 - collar_z/2;
shank_cz  = -total_z/2 + shank_z/2;

// Slots are positioned within shank, measured from shank top face (near collar)
function slot_cz_from_top(z_from_shank_top) =
    (shank_cz + shank_z/2) - z_from_shank_top;

// ---------- Helpers ----------
module capsule_slot_y(len, w, h_y) {
    // Slot runs along Z (len), thickness along X (w), extruded along Y (h_y)
    // Centered at origin.
    union() {
        cube([w, h_y, len], center=true);
        translate([0, 0, -len/2 + w/2])
            rotate([90, 0, 0]) cylinder(r=w/2, h=h_y, center=true, $fn=32);
        translate([0, 0,  len/2 - w/2])
            rotate([90, 0, 0]) cylinder(r=w/2, h=h_y, center=true, $fn=32);
    }
}

// ---------- Base solids ----------
module collar_head_faceted() {
    translate([0, 0, collar_cz])
        cylinder(r=collar_radius, h=collar_z, center=true, $fn=collar_facets);
}

module rectangular_shank() {
    translate([0, 0, shank_cz])
        cube([shank_x, shank_y, shank_z], center=true);
}

module central_longitudinal_rib() {
    // Rib centered on shank, protruding on +Y face, running along Z
    rib_len = max(0, rib_z_end - rib_z_start);
    rib_cz_local = -shank_z/2 + rib_z_start + rib_len/2;

    translate([0, shank_y/2 - rib_h/2 + overlap, shank_cz + rib_cz_local])
        cube([rib_thk, rib_h, rib_len], center=true);
}

// ---------- Cutters ----------
module central_through_opening() {
    // Through-bore along Z through entire part
    cylinder(r=hole_d/2, h=total_z + 4*overlap, center=true, $fn=48);
}

module shank_slot_at(z_from_shank_top) {
    // Cut slot through shank in Y direction, centered in X, running along Z
    translate([0, 0, slot_cz_from_top(z_from_shank_top)])
        capsule_slot_y(slot_len, slot_w, shank_y + 4*overlap);
}

// ---------- Main ----------
module main_solid() {
    union() {
        collar_head_faceted();
        // Ensure collar and shank are connected with slight overlap
        translate([0, 0, -overlap/2]) rectangular_shank();
        central_longitudinal_rib();
    }
}

difference() {
    main_solid();
    shank_slot_at(slot_z_center_1);
    shank_slot_at(slot_z_center_2);
    central_through_opening();
}
}
