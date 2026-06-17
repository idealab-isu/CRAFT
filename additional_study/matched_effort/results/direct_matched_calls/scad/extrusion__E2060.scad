$fn = 64;

length = 100;
w = 60;
h = 20;

slot = 6;          // slot opening width
slot_depth = 6;    // depth of slot cut from each face
wall = 2;          // outer wall thickness
core_r = 4;        // central bore radius
corner_r = 1.5;    // outer corner radius

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module extrusion_profile_2060_2d() {
    difference() {
        // Outer body
        rounded_rect_2d(w, h, corner_r);

        // Inner cavity (lightening)
        rounded_rect_2d(w - 2*wall, h - 2*wall, max(0, corner_r - 0.5));

        // Central bore
        circle(r=core_r);

        // T-slots (simple rectangular approximations)
        // Long sides (top/bottom)
        translate([0,  h/2 - slot_depth/2]) square([slot, slot_depth], center=true);
        translate([0, -h/2 + slot_depth/2]) square([slot, slot_depth], center=true);

        // Short sides (left/right)
        translate([ w/2 - slot_depth/2, 0]) square([slot_depth, slot], center=true);
        translate([-w/2 + slot_depth/2, 0]) square([slot_depth, slot], center=true);

        // Internal webs (keep some structure by cutting channels)
        // Long internal channels
        translate([0, 0]) square([w - 2*wall - 10, 4], center=true);
        // Short internal channels
        translate([0, 0]) square([4, h - 2*wall - 6], center=true);
    }
}

linear_extrude(height=length, center=false, convexity=10)
    extrusion_profile_2060_2d();