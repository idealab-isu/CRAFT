$fn = 64;

// Overall bounding box must match: [12.7, 19, 8.2]  (X, Y, Z)
segment_size = [12.7, 19, 8.2];

W = segment_size[0];
H = segment_size[1];
T = segment_size[2];

// A-segment: top horizontal bar with beveled ends.
// Ensure visible geometry and keep it within the bounding box.
bar_h   = 4.2;                          // thickness in Y of the segment bar
chamfer = min(2.2, W/2 - 0.01);         // bevel length in X (safe)
y0      = H - bar_h;                    // place at top so overall Y fits exactly

module a_segment_2d() {
    // Chamfered rectangle spanning full width W and height bar_h
    polygon(points=[
        [0,            bar_h/2],
        [chamfer,      bar_h],
        [W - chamfer,  bar_h],
        [W,            bar_h/2],
        [W - chamfer,  0],
        [chamfer,      0]
    ]);
}

translate([0, y0, 0])
    linear_extrude(height=T, center=false, convexity=10)
        a_segment_2d();