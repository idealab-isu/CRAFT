// Simple plate with one obround through-slot near a corner
// Bounding box: 114.0 x 59.5 x 0.8 mm

$fn = 96;

// Parameters
L = 114.0;
W = 59.5;
T = 0.8;

slot_len = 30;
slot_w   = 10;
slot_end_r = slot_w/2;

// Slot location (from left/bottom edges of the plate)
slot_center_x_from_left   = 18;
slot_center_y_from_bottom = 12;

// Ensure clean through-cut
slot_overlap = 1;

// Base
module plate_body() {
    cube([L, W, T], center=true);
}

// 2D obround profile (centered at origin, along X)
module obround2d(len, w) {
    r = w/2;
    hull() {
        translate([-(len/2 - r), 0]) circle(r=r);
        translate([ +(len/2 - r), 0]) circle(r=r);
    }
}

// Through-slot positioned from left/bottom edges
module obround_through_slot() {
    x = -L/2 + slot_center_x_from_left;
    y = -W/2 + slot_center_y_from_bottom;

    translate([x, y, 0])
        linear_extrude(height=T + 2*slot_overlap, center=true)
            obround2d(slot_len, slot_w);
}

// Final
difference() {
    plate_body();
    obround_through_slot();
}