// Stepped H-like bracket/block (prismatic, sharp edges)
// Target bounding box: 31.8 x 31.8 x 15.8 mm

$fn = 48;

// -------------------- Parameters --------------------
bbox_x = 31.8;
bbox_y = 31.8;
bbox_z = 15.8;

// End blocks (left/right)
end_w = 11.5;          // X width of each end block
end_d = bbox_y;        // Y depth
end_h = bbox_z;        // Z height

// Central bridge (connects end blocks)
bridge_d = 14;         // Y depth of bridge (narrower than end blocks)

// Asymmetric pads (additive, create asymmetric top/bottom silhouette)
pad_w = 7;             // X
pad_d = 10;            // Y
pad_h = 3;             // Z
pad_offset_x = 4;      // X offset from center
pad_offset_y = 6;      // Y offset from center

// Shoulder steps/rebates (subtractive)
top_rebate_depth = 2.2;
top_rebate_w = 10;
top_rebate_d = 12;

bottom_rebate_depth = 2.0;
bottom_rebate_w = 9;
bottom_rebate_d = 10;

// Internal relief cutouts (subtractive, through Z)
relief_w = 6;
relief_d = 8;
relief_offset_y = 7;

// Small additional rebates (subtractive)
small_rebate_w = 6;
small_rebate_d = 6;
small_rebate_depth = 1.2;

// Robustness
overlap = 0.6;           // small overlap to guarantee connectivity
cut_clear = 0.25;        // extra depth for clean subtraction

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Derived: ensure exact bbox in X by solving bridge width from bbox_x and end_w
// Total X = end_w + bridge_w + end_w
bridge_w = clamp(bbox_x - 2*end_w, 0.1, bbox_x);

// -------------------- Base solids --------------------
module end_block(sign=1) { // sign = -1 left, +1 right
    translate([sign*(bbox_x/2 - end_w/2), 0, 0])
        cube([end_w, end_d, end_h], center=true);
}

module central_bridge() {
    // Bridge spans exactly between end blocks; add tiny overlap in X for guaranteed union
    cube([bridge_w + 2*overlap, bridge_d, bbox_z], center=true);
}

module offset_pad_top() {
    // Additive pad on top face, offset in +X,+Y
    translate([ pad_offset_x,  pad_offset_y,  bbox_z/2 - pad_h/2])
        cube([pad_w, clamp(pad_d, 0.1, bbox_y), pad_h], center=true);
}

module offset_pad_bottom() {
    // Additive pad on bottom face, offset in -X,-Y (asymmetric overall)
    translate([-pad_offset_x, -pad_offset_y, -bbox_z/2 + pad_h/2])
        cube([pad_w, clamp(pad_d, 0.1, bbox_y), pad_h], center=true);
}

// -------------------- Subtractive features --------------------
module top_rebate() {
    translate([0, 0, bbox_z/2 - (top_rebate_depth + cut_clear)/2])
        cube([top_rebate_w, clamp(top_rebate_d, 0.1, bbox_y), top_rebate_depth + cut_clear], center=true);
}

module bottom_rebate() {
    translate([0, 0, -bbox_z/2 + (bottom_rebate_depth + cut_clear)/2])
        cube([bottom_rebate_w, clamp(bottom_rebate_d, 0.1, bbox_y), bottom_rebate_depth + cut_clear], center=true);
}

module internal_relief(sign=1) {
    // Through-cut relief near each end block, offset in Y opposite on each side
    translate([sign*(bbox_x/2 - end_w/2), -sign*relief_offset_y, 0])
        cube([relief_w, relief_d, bbox_z + 2*cut_clear], center=true);
}

module small_rebate_left_top() {
    translate([-(bbox_x/2 - end_w/2), 0, bbox_z/2 - (small_rebate_depth + cut_clear)/2])
        cube([small_rebate_w, small_rebate_d, small_rebate_depth + cut_clear], center=true);
}

module small_rebate_right_bottom() {
    translate([(bbox_x/2 - end_w/2), 0, -bbox_z/2 + (small_rebate_depth + cut_clear)/2])
        cube([small_rebate_w, small_rebate_d, small_rebate_depth + cut_clear], center=true);
}

// -------------------- Main body (ONE connected solid) --------------------
module main_body() {
    union() {
        end_block(-1);
        end_block( 1);
        central_bridge();
        offset_pad_top();
        offset_pad_bottom();
    }
}

// -------------------- Final model --------------------
difference() {
    main_body();

    // Shoulder steps
    top_rebate();
    bottom_rebate();

    // Internal reliefs (asymmetric pair)
    internal_relief(-1);
    internal_relief( 1);

    // Extra small rebates (diagonal/asymmetric)
    small_rebate_left_top();
    small_rebate_right_bottom();
}