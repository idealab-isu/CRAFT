// Dimension-calibrated (target: 0.11 x 0.11 x 0.02 mm)
scale([1.309767, 1.309767, 1.000000])
{
// Flat linkage bracket: annulus + two orthogonal forked clevis arms (plate-like, one connected solid)

$fn = 96;

// -------------------- Parameters (mm) --------------------
plate_t   = 0.02;     // plate thickness (very thin)
overlap   = 0.001;    // small overlap to guarantee connectivity / clean booleans

// Central ring (annulus)
ring_od   = 0.06;
bore_d    = 0.03;

// Arm geometry
arm_len   = 0.025;    // length from ring OD tangent to clevis end
arm_w     = 0.02;     // overall arm width (across prongs)

// Clevis geometry (fork)
clevis_gap = 0.01;    // gap between prongs (slot width)
prong_w    = 0.005;   // thickness of each prong (in-plane)
u_depth    = 0.01;    // depth of U opening from end
u_end_margin = 0.003; // material at very end beyond U opening

// Derived
ring_r = ring_od/2;
bore_r = bore_d/2;

// Ensure arm_w matches prongs+gap (or larger). If larger, prongs are centered.
prongs_span = 2*prong_w + clevis_gap;
prong_offset = (clevis_gap/2 + prong_w/2);

// -------------------- Helpers --------------------
module plate_extrude() linear_extrude(height=plate_t, center=true) children();

module annulus_2d() {
    difference() {
        circle(r=ring_r);
        circle(r=bore_r);
    }
}

// A 2D clevis arm along +X, starting at x=0 (root) and ending at x=arm_len.
// Includes two prongs and a U-shaped opening at the end.
module clevis_arm_2d_x() {
    // Base prongs (two rails)
    difference() {
        union() {
            // Two prongs spanning full arm length
            translate([arm_len/2,  prong_offset]) square([arm_len, prong_w], center=true);
            translate([arm_len/2, -prong_offset]) square([arm_len, prong_w], center=true);

            // Root blend pad to ensure robust connection to ring
            // (slightly wider near root, still plate-like)
            translate([0, 0]) circle(r=arm_w/2);
        }

        // U opening: remove slot near the end, leaving end margin
        // Slot spans the gap region and cuts into prongs by u_depth.
        // Place so its far edge is arm_len - u_end_margin.
        translate([arm_len - u_end_margin - u_depth/2, 0])
            square([u_depth, clevis_gap], center=true);
    }
}

// Same arm but along +Y (rotate 90°)
module clevis_arm_2d_y() {
    rotate(90) clevis_arm_2d_x();
}

// -------------------- Main 2D profile --------------------
module bracket_2d() {
    union() {
        annulus_2d();

        // Arms are attached tangentially at ring OD.
        // Place arm root at x=ring_r (tangent point), so x=0 of arm aligns there.
        translate([ring_r - overlap, 0]) clevis_arm_2d_x();
        translate([0, ring_r - overlap]) clevis_arm_2d_y();
    }
}

// -------------------- Final solid --------------------
plate_extrude()
    bracket_2d();
}
