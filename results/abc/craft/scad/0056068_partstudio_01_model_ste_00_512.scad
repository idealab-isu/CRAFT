$fn = 96;

// Target bounding box (mm): ~X=0.03, Y=0.32, Z=0.07
// Elongated along Y

// Overall bbox targets
bbox_x = 0.03;
bbox_y = 0.32;
bbox_z = 0.07;

// Main dimensions
shaft_len = 0.24;
shaft_w   = 0.022;
shaft_h   = 0.05;

head_len  = 0.055;
head_w    = bbox_x;   // keep within bbox_x
head_h    = bbox_z;   // keep within bbox_z

collar_len = 0.012;
collar_r   = bbox_x/2;

socket_depth  = 0.03;
socket_square = 0.016;

tip_len   = 0.025;
tip_end_w = 0.008;
tip_end_h = 0.02;

facet_chamfer = 0.002;

// Use a small overlap for watertight unions (in mm)
overlap = 0.0015;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module faceted_rect_prism(x, y, z, chamfer) {
    // Slight faceting on the XZ cross-section
    intersection() {
        cube([x, y, z], center=true);
        rotate([0, 45, 0])
            cube([x + 2*chamfer, y + 2*chamfer, z + 2*chamfer], center=true);
    }
}

module tapered_tip_prism(len, w0, h0, w1, h1) {
    // Taper along Y using hull between two thin slices
    eps = 0.001;
    hull() {
        translate([0, -len/2, 0]) cube([w0, eps, h0], center=true);
        translate([0,  len/2, 0]) cube([w1, eps, h1], center=true);
    }
}

module head_block(len, w, h) {
    cube([w, len, h], center=true);
}

module collar_hex_y(len, r) {
    // Hex collar with axis along Y
    rotate([90, 0, 0])
        cylinder(h=len, r=r, center=true, $fn=6);
}

module socket_cut_from_face(depth, sq) {
    // Cut a recessed diamond (rotated square) socket along +Y from the end face.
    // Make it slightly larger in XZ and slightly deeper to read clearly in ortho views.
    rotate([0, 45, 0])
        cube([sq, depth, sq], center=false);
}

// --- Layout along Y axis (recalculated so parts touch with overlap) ---
// Place shaft centered at origin.
y_shaft_c = 0;

// Head attaches to negative-Y end of shaft
y_head_c = -(shaft_len/2 + head_len/2 - overlap);

// Collar sits at the very negative-Y end of the head (and overlaps into it)
y_collar_c = (y_head_c - head_len/2) - collar_len/2 + overlap;

// Tip attaches to positive-Y end of shaft
y_tip_c = +(shaft_len/2 + tip_len/2 - overlap);

// Socket placement: start exactly at the outer (most negative-Y) face of the collar/head region
socket_depth_eff = clamp(socket_depth, 0.002, head_len + collar_len - 0.002);

// Outer face of collar (most negative Y)
y_outer_face = y_collar_c - collar_len/2;

// Start the cut at the outer face and push inward along +Y
// (center=false cube starts at its local origin)
y_socket_start = y_outer_face - 0.0005; // tiny bias outward to ensure a clean opening

difference() {
    union() {
        // Shaft
        faceted_rect_prism(shaft_w, shaft_len, shaft_h, facet_chamfer);

        // Head
        translate([0, y_head_c, 0])
            head_block(head_len, head_w, head_h);

        // Collar (hex) at head end
        translate([0, y_collar_c, 0])
            collar_hex_y(collar_len, collar_r);

        // Tip
        translate([0, y_tip_c, 0])
            tapered_tip_prism(tip_len, shaft_w, shaft_h, tip_end_w, tip_end_h);
    }

    // Recessed socket opening (diamond), clearly visible from the collar end
    translate([0, y_socket_start, 0])
        socket_cut_from_face(socket_depth_eff + 0.001, socket_square * 1.05);
}