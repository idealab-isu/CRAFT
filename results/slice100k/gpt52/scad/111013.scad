$fn=64;

L = 14.0;   // X
W = 9.0;    // Y
T = 3.6;    // Z

end_len = 4.0;      // length of each end mass along X
web_len = L - 2*end_len;

end_w = W;          // full width at ends
web_w = 5.0;        // narrower central web width (I-beam-like in left/right view)

notch_len = 4.0;    // relief length along X at midspan
notch_depth = 2.0;  // relief depth from top/bottom edges along Y
notch_z = T;        // through thickness

module base_shape() {
    union() {
        translate([-(L/2) + end_len/2, 0, 0]) cube([end_len, end_w, T], center=true);
        translate([(L/2) - end_len/2, 0, 0]) cube([end_len, end_w, T], center=true);
        cube([web_len, web_w, T], center=true);
    }
}

module reliefs() {
    union() {
        translate([0, (W/2) - (notch_depth/2), 0]) cube([notch_len, notch_depth, notch_z], center=true);
        translate([0, -(W/2) + (notch_depth/2), 0]) cube([notch_len, notch_depth, notch_z], center=true);
    }
}

difference() {
    base_shape();
    reliefs();
}