$fn = 64;

length = 100;
w = 80;
h = 40;

wall = 2.5;
slot_w = 8;
slot_depth = 6;
corner_r = 2;

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module extrusion_4080_profile_2d() {
    difference() {
        // Outer body
        rounded_rect_2d(w, h, corner_r);

        // Inner hollow
        rounded_rect_2d(w - 2*wall, h - 2*wall, max(0, corner_r - 1));

        // T-slots (approximate) on all four sides
        // Top
        translate([0, h/2 - slot_depth/2])
            square([slot_w, slot_depth], center=true);

        // Bottom
        translate([0, -h/2 + slot_depth/2])
            square([slot_w, slot_depth], center=true);

        // Left
        translate([-w/2 + slot_depth/2, 0])
            rotate(90) square([slot_w, slot_depth], center=true);

        // Right
        translate([ w/2 - slot_depth/2, 0])
            rotate(90) square([slot_w, slot_depth], center=true);

        // Central bore (approximate)
        circle(d=10);
    }
}

linear_extrude(height=length, center=false, convexity=10)
    extrusion_4080_profile_2d();