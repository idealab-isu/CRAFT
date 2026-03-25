// Dimension-calibrated (target: 37.70 x 40.00 x 5.00 mm)
scale([1.000000, 0.231481, 8.000000])
{
// Radial starburst / asterisk-like spacer (connected solid)
// Target bounding box: 37.7 x 40.0 x 5.0 mm

$fn = 96;

// Bounding box
bbox_x = 37.7;
bbox_y = 40.0;
bbox_z = 5.0;

// Thickness
thickness = bbox_z;

// Central hub (solid, no holes)
hub_d = 14.0;

// Dominant long bar (spans X)
bar_len = bbox_x;
bar_w   = 7.0;

// Fewer distinct spokes at varied angles (not evenly spaced teeth)
spoke_angles_deg = [25, 55, 90, 125, 155, 205, 235];  // varied, not uniform
spoke_lens       = [18.0, 16.5, 20.0, 15.5, 17.0, 14.5, 16.0];
spoke_ws         = [4.2,  3.8,  4.6,  3.6,  4.0,  3.6,  3.8];

connect_overlap = 0.8; // overlap into hub for robust union

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep rotated rectangles safely within bbox by limiting half-length
diag_xy = sqrt(bbox_x*bbox_x + bbox_y*bbox_y);
max_len = diag_xy - 1.0;

module central_hub() {
    cylinder(d=hub_d, h=thickness, center=true);
}

module rect_spoke(len, w) {
    // Centered at origin so it intersects hub; extend slightly for overlap
    cube([len + 2*connect_overlap, w, thickness], center=true);
}

module dominant_long_bar() {
    rect_spoke(bar_len, bar_w);
}

module angled_spoke(a, len, w) {
    rotate([0, 0, a])
        rect_spoke(clamp(len, 0, max_len), w);
}

module starburst() {
    union() {
        central_hub();
        dominant_long_bar();
        for (i = [0 : len(spoke_angles_deg)-1])
            angled_spoke(spoke_angles_deg[i], spoke_lens[i], spoke_ws[i]);
    }
}

// Final: clip to exact bounding box (keeps one connected solid)
intersection() {
    starburst();
    cube([bbox_x, bbox_y, bbox_z], center=true);
}
}
