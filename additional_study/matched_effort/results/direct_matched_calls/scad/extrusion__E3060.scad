$fn = 64;

length = 100;
w = 60;
h = 30;

wall = 2.0;
slot_w = 8.0;
slot_depth = 6.0;
corner_r = 2.0;

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    offset(r = r2) offset(delta = -r2) square([w, h], center = true);
}

module extrusion_3060_profile_2d() {
    difference() {
        // Outer body
        rounded_rect_2d(w, h, corner_r);

        // Inner hollow
        rounded_rect_2d(w - 2*wall, h - 2*wall, max(0, corner_r - 0.5));

        // T-slots (approximate) on all four sides
        // Top
        translate([0, h/2 - slot_depth/2])
            square([slot_w, slot_depth], center = true);

        // Bottom
        translate([0, -h/2 + slot_depth/2])
            square([slot_w, slot_depth], center = true);

        // Left
        translate([-w/2 + slot_depth/2, 0])
            square([slot_depth, slot_w], center = true);

        // Right
        translate([w/2 - slot_depth/2, 0])
            square([slot_depth, slot_w], center = true);

        // Central bore (typical-ish)
        circle(d = 6.0);
    }
}

linear_extrude(height = length, center = false, convexity = 10)
    extrusion_3060_profile_2d();