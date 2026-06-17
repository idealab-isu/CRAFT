// 20x60 aluminium extrusion profile, 100mm long (Z axis)
// One connected solid, with visible T-slots and internal cavities.

$fn = 96;

module extrusion_20x60(len=100, w=20, h=60) {

    // Typical-ish 20-series slot geometry (approximate)
    wall        = 2.0;   // outer wall thickness
    slot_open   = 6.2;   // opening at surface
    slot_neck   = 3.2;   // narrow neck just inside opening
    slot_depth  = 10.0;  // total depth from surface to back of slot cavity
    neck_depth  = 2.2;   // depth of the narrow neck region
    slot_cavity = 10.2;  // width of the inner cavity behind the neck

    // Internal void (kept smaller than outer to preserve walls)
    inner_w = w - 2*wall;
    inner_h = h - 2*wall;

    // Center bore (common for 20-series)
    bore_r = 2.6;

    eps = 0.2;

    // 2D profile for a single T-slot cut from +X face inward
    module tslot2d_x() {
        // Coordinates in XY plane; +X is outward face.
        // Build as union of rectangles to form opening + neck + cavity.
        union() {
            // Opening at surface
            translate([ w/2 - slot_depth/2, 0 ])
                square([slot_depth, slot_open], center=true);

            // Neck near surface (slightly shallower)
            translate([ w/2 - neck_depth/2, 0 ])
                square([neck_depth, slot_neck], center=true);

            // Inner cavity behind neck
            cavity_depth = max(0.1, slot_depth - neck_depth);
            translate([ w/2 - neck_depth - cavity_depth/2, 0 ])
                square([cavity_depth, slot_cavity], center=true);
        }
    }

    // 2D profile for a single T-slot cut from +Y face inward
    module tslot2d_y() {
        union() {
            translate([ 0, h/2 - slot_depth/2 ])
                square([slot_open, slot_depth], center=true);

            translate([ 0, h/2 - neck_depth/2 ])
                square([slot_neck, neck_depth], center=true);

            cavity_depth = max(0.1, slot_depth - neck_depth);
            translate([ 0, h/2 - neck_depth - cavity_depth/2 ])
                square([slot_cavity, cavity_depth], center=true);
        }
    }

    difference() {
        // Outer body
        cube([w, h, len], center=true);

        // Main internal cavity (keeps outer walls)
        cube([inner_w, inner_h, len + eps], center=true);

        // Four T-slots (extruded along Z)
        linear_extrude(height=len + eps, center=true) tslot2d_x();
        linear_extrude(height=len + eps, center=true) mirror([1,0,0]) tslot2d_x();

        linear_extrude(height=len + eps, center=true) tslot2d_y();
        linear_extrude(height=len + eps, center=true) mirror([0,1,0]) tslot2d_y();

        // Center bore
        cylinder(r=bore_r, h=len + eps, center=true);
    }
}

extrusion_20x60(len=100, w=20, h=60);