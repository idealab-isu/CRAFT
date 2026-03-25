// Dimension-calibrated (target: 0.07 x 0.18 x 0.02 mm)
scale([0.900083, 0.680166, 2.857543])
{
// Rectangular open-center frame with rounded end loops + 4 identical angled mounting pads
// One connected solid, planar/plate-like

$fn = 96;

// -------------------- Parameters (mm) --------------------
bbox_L = 0.20;          // overall length (X)
bbox_W = 0.10;          // overall width  (Y)
bbox_T = 0.006;         // plate thickness (Z)  (kept small/flat)

frame_wall = 0.016;     // ring wall thickness

// Rounded end loops (integrated into outer silhouette)
loop_outer_r = bbox_W/2;                 // outer end radius (capsule ends)
loop_inner_r = max(loop_outer_r - frame_wall, 0.001);

// Central clearance (open center)
cutout_L = bbox_L - 2*frame_wall - 2*loop_outer_r;  // inner straight length
cutout_W = bbox_W - 2*frame_wall;                   // inner width

// Mounting pads
pad_L = 0.030;
pad_W = 0.020;
pad_T = bbox_T;          // pads are planar with frame (same thickness)
pad_angle_deg = 20;

pad_inset_x = 0.010;     // how far pads sit in from outer X edge
pad_inset_y = 0.010;     // how far pads sit in from outer Y edge
pad_overlap = 0.002;     // overlap into frame to guarantee connectivity

// Pad holes
hole_d = 0.004;
hole_spacing = 0.012;    // center-to-center along pad length
hole_edge_margin = 0.004;

// Ribbing on pads (raised)
rib_h = 0.002;
rib_w = 0.003;
rib_count = 3;

overlap = 0.001;

// -------------------- Helpers --------------------
module capsule2d(L, W) {
    // 2D capsule along X: overall length L, width W
    r = W/2;
    hull() {
        translate([-L/2 + r, 0]) circle(r=r);
        translate([ L/2 - r, 0]) circle(r=r);
    }
}

module frame_plate() {
    // Outer capsule minus inner capsule -> open-center frame with rounded end loops
    linear_extrude(height=bbox_T, center=true)
        difference() {
            capsule2d(bbox_L, bbox_W);
            capsule2d(bbox_L - 2*frame_wall, bbox_W - 2*frame_wall);
        }
}

module pad_solid() {
    // Pad body (planar) + raised ribs
    union() {
        // base pad
        cube([pad_L, pad_W, pad_T], center=true);

        // ribs on top surface
        for (i = [0 : rib_count-1]) {
            y = (rib_count==1) ? 0
                : (-pad_W/2 + hole_edge_margin + (i*(pad_W - 2*hole_edge_margin)/(rib_count-1)));
            translate([0, y, pad_T/2 + rib_h/2 - overlap])
                cube([pad_L - 2*hole_edge_margin, rib_w, rib_h], center=true);
        }
    }
}

module pad_holes() {
    // Two through-holes along pad length
    for (sx = [-1, 1]) {
        translate([sx*hole_spacing/2, 0, 0])
            cylinder(d=hole_d, h=pad_T + 2*overlap, center=true);
    }
}

module place_pad(xsign, ysign) {
    // Place identical pad near each corner, angled outward consistently
    // Corner reference at outer capsule bounding box corners:
    // X edge at +/- bbox_L/2, Y edge at +/- bbox_W/2
    // Pad center is inset from edges and overlapped into frame for connectivity.
    x0 = xsign*(bbox_L/2 - pad_inset_x - pad_L/2 + pad_overlap);
    y0 = ysign*(bbox_W/2 - pad_inset_y - pad_W/2 + pad_overlap);

    // Angle: pads on left rotate +, on right rotate -, mirrored by xsign
    ang = -xsign * pad_angle_deg;

    translate([x0, y0, 0])
        rotate([0, 0, ang])
            children();
}

// -------------------- Model --------------------
difference() {
    union() {
        frame_plate();

        // 4 identical pads, connected via overlap into frame
        for (xs = [-1, 1])
            for (ys = [-1, 1])
                place_pad(xs, ys)
                    pad_solid();
    }

    // Subtract holes from pads
    for (xs = [-1, 1])
        for (ys = [-1, 1])
            place_pad(xs, ys)
                pad_holes();
}
}
