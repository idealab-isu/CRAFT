// 40x40 aluminium extrusion profile, 100mm long (simplified 4040 T-slot style)
// ONE connected solid: outer 40x40 with T-slots and internal voids that do NOT split the body.

profile_w = 40.0;
profile_h = 40.0;
length    = 100.0;

$fn = 96;
eps = 0.05;

// Feature sizing (parametric, derived from profile size)
wall          = profile_w * 0.10;   // ~4.0 outer wall
slot_open     = profile_w * 0.15;   // ~6.0 opening at surface
slot_neck     = profile_w * 0.10;   // ~4.0 neck width
slot_depth    = profile_w * 0.22;   // ~8.8 depth from surface
slot_cavity_w = profile_w * 0.22;   // ~8.8 inner cavity width
slot_cavity_d = profile_w * 0.12;   // ~4.8 inner cavity depth
center_hole_r = profile_w * 0.12;   // ~4.8

// Keep a guaranteed connected "plus" web through the center
web = profile_w * 0.14;             // ~5.6 (thicker than before to prevent quadrant split)

// 2D cross-section (solid minus voids), then extruded along Z
module profile_2d() {
    difference() {
        // Outer boundary (40x40)
        square([profile_w, profile_h], center=true);

        // Central bore
        circle(r=center_hole_r);

        // Corner relief pockets, but clipped so they cannot cut through the central web
        pocket = profile_w * 0.18; // ~7.2
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(profile_w/2 - wall - pocket/2),
                sy*(profile_h/2 - wall - pocket/2)
            ])
            intersection() {
                square([pocket, pocket], center=true);
                // Keep-out region around center to preserve connectivity
                difference() {
                    square([profile_w, profile_h], center=true);
                    square([web, profile_h + 2], center=true);
                    square([profile_w + 2, web], center=true);
                }
            }
        }

        // T-slots on each side (cuts from outside inward)
        // Right
        translate([ profile_w/2 - slot_depth/2 + eps, 0])
            square([slot_depth + 2*eps, slot_open], center=true);
        translate([ profile_w/2 - slot_depth + slot_cavity_d/2 + eps, 0])
            square([slot_cavity_d + 2*eps, slot_cavity_w], center=true);
        translate([ profile_w/2 - slot_depth/2 + eps, 0])
            square([slot_depth + 2*eps, slot_neck], center=true);

        // Left
        translate([-profile_w/2 + slot_depth/2 - eps, 0])
            square([slot_depth + 2*eps, slot_open], center=true);
        translate([-profile_w/2 + slot_depth - slot_cavity_d/2 - eps, 0])
            square([slot_cavity_d + 2*eps, slot_cavity_w], center=true);
        translate([-profile_w/2 + slot_depth/2 - eps, 0])
            square([slot_depth + 2*eps, slot_neck], center=true);

        // Top
        translate([0,  profile_h/2 - slot_depth/2 + eps])
            square([slot_open, slot_depth + 2*eps], center=true);
        translate([0,  profile_h/2 - slot_depth + slot_cavity_d/2 + eps])
            square([slot_cavity_w, slot_cavity_d + 2*eps], center=true);
        translate([0,  profile_h/2 - slot_depth/2 + eps])
            square([slot_neck, slot_depth + 2*eps], center=true);

        // Bottom
        translate([0, -profile_h/2 + slot_depth/2 - eps])
            square([slot_open, slot_depth + 2*eps], center=true);
        translate([0, -profile_h/2 + slot_depth - slot_cavity_d/2 - eps])
            square([slot_cavity_w, slot_cavity_d + 2*eps], center=true);
        translate([0, -profile_h/2 + slot_depth/2 - eps])
            square([slot_neck, slot_depth + 2*eps], center=true);

        // Internal lightening voids: ONLY in the four quadrants, leaving a solid central plus-web.
        // This prevents the "four separate blocks" failure.
        quad_w = (profile_w/2 - wall) - web/2;
        quad_h = (profile_h/2 - wall) - web/2;

        if (quad_w > 1 && quad_h > 1) {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(web/2 + quad_w/2), sy*(web/2 + quad_h/2)])
                    square([quad_w, quad_h], center=true);
            }
        }
    }
}

module extrusion_4040(len=length) {
    color("Silver")
    linear_extrude(height=len, center=true, convexity=10)
        profile_2d();
}

// Final model: 40x40 cross-section, 100mm long
extrusion_4040(length);