$fn = 64;

// Overall SMD envelope (L, W, H)
size = [9.90, 3.90, 1.25];
L = size[0];
W = size[1];
H = size[2];

// Simple SMD-style details (all derived from dimensions)
pad_len = L * 0.18;
pad_thk = H * 0.22;
pad_w   = W * 0.92;

chamfer = min(H * 0.18, W * 0.12);
overlap = min(0.05, H * 0.08); // small overlap to guarantee one connected solid

module chamfered_body(l, w, h, c) {
    // Create top-edge chamfers by subtracting wedges; keep overall envelope
    difference() {
        cube([l, w, h], center=true);

        // Long-side top chamfers (along X)
        for (sy = [-1, 1]) {
            translate([0, sy*(w/2 - c/2), h/2 - c/2])
                rotate([0, 90, 0])
                    linear_extrude(height=l + 2*overlap, center=true)
                        polygon(points=[[0,0],[c,0],[0,c]]);
        }

        // Short-side top chamfers (along Y)
        for (sx = [-1, 1]) {
            translate([sx*(l/2 - c/2), 0, h/2 - c/2])
                rotate([90, 0, 0])
                    linear_extrude(height=w + 2*overlap, center=true)
                        polygon(points=[[0,0],[c,0],[0,c]]);
        }
    }
}

union() {
    // Main body (chamfered)
    chamfered_body(L, W, H, chamfer);

    // End terminals/pads (connected with slight overlap into body)
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - pad_len/2 + overlap), 0, -H/2 + pad_thk/2 - overlap])
            cube([pad_len, pad_w, pad_thk], center=true);
    }

    // Polarity/Pin-1 style mark: shallow top dimple near one end (added, not subtracted)
    mark_r = min(W, H) * 0.18;
    translate([-L/2 + pad_len + mark_r*1.6, 0, H/2 - mark_r*0.55])
        sphere(r=mark_r);
}