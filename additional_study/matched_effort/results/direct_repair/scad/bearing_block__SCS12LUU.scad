$fn=96;

// Parameters
shaft_d = 8.0;
block_w = 42.0;   // X
block_l = 70.0;   // Y
block_h = 24.0;   // Z

// Bearing/bore
bore_clearance = 0.35;          // diameter clearance
bore_d = shaft_d + bore_clearance;
bore_z = block_h/2;             // centered vertically

// Split clamp slot
slot_w = 2.0;                   // slot thickness
slot_x = block_w/2;             // slot at +X side

// Mounting holes (4x)
mount_hole_d = 5.2;             // for M5 clearance
mount_counterbore_d = 9.5;      // counterbore diameter
mount_counterbore_depth = 4.0;  // from top
mount_edge_x = 8.0;             // edge margin in X
mount_edge_y = 10.0;            // edge margin in Y

// Clamp screw holes (2x) across the split
clamp_hole_d = 4.3;             // for M4 clearance
clamp_head_d = 8.0;             // counterbore for socket head
clamp_head_depth = 4.0;
clamp_y_offset = 18.0;          // from center along Y

// Fillets (approximated by minkowski with small sphere)
fillet_r = 1.2;

// Helpers
module rounded_block(size=[10,10,10], r=1) {
    // Minkowski rounding; keep renderable and reasonably fast
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module counterbored_hole_through(d_through, d_cb, cb_depth, h, from_top=true) {
    // Through hole + counterbore from top
    union() {
        cylinder(d=d_through, h=h+0.2, center=true);
        if (from_top) {
            translate([0,0,(h/2)-(cb_depth/2)+0.01])
                cylinder(d=d_cb, h=cb_depth+0.2, center=true);
        } else {
            translate([0,0,-(h/2)+(cb_depth/2)-0.01])
                cylinder(d=d_cb, h=cb_depth+0.2, center=true);
        }
    }
}

difference() {
    // Main body
    rounded_block([block_w, block_l, block_h], r=fillet_r);

    // Shaft bore along Y
    rotate([90,0,0])
        translate([0,0,0])
            cylinder(d=bore_d, h=block_l+2, center=true);

    // Split clamp slot (from +X face to bore)
    translate([slot_x - slot_w/2, 0, 0])
        cube([slot_w, block_l+2, block_h+2], center=true);

    // Mounting holes (4x) with top counterbores
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(block_w/2 - mount_edge_x), sy*(block_l/2 - mount_edge_y), 0])
            counterbored_hole_through(
                d_through=mount_hole_d,
                d_cb=mount_counterbore_d,
                cb_depth=mount_counterbore_depth,
                h=block_h,
                from_top=true
            );
    }

    // Clamp screw holes (2x) across X, with head counterbore from +X side
    for (sy = [-1, 1]) {
        translate([0, sy*clamp_y_offset, 0]) {
            // Through hole along X
            rotate([0,90,0])
                cylinder(d=clamp_hole_d, h=block_w+2, center=true);

            // Counterbore for head from +X side
            translate([block_w/2 - clamp_head_depth/2 + 0.01, 0, 0])
                rotate([0,90,0])
                    cylinder(d=clamp_head_d, h=clamp_head_depth+0.2, center=true);
        }
    }
}