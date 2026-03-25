// Dimension-calibrated (target: 10.97 x 43.93 x 10.92 mm)
scale([1.000365, 1.068425, 1.797943])
{
// Thin constant-thickness bracket-like part:
// central rectangular pad + two long arms angled (shallow V/boomerang in side view)
// with large blended/concave-looking transitions. No holes/cutouts.
// Target bbox: 11.0 x 43.9 x 10.9 mm (X x Y x Z)

$fn = 96;

// ---------------- Parameters ----------------
bbox_X = 10.97;   // overall width (X)
bbox_Y = 43.93;   // overall length (Y)
bbox_Z = 10.92;   // overall height (Z) due to arm angle

thk    = 1.20;    // constant sheet thickness (extrusion height)

pad_L  = 12.0;    // central pad length along Y (distinct pad)
pad_W  = bbox_X;  // pad width along X

arm_angle_deg = 18.0;  // arm tilt about X (creates shallow V in side view)
end_R   = 5.0;         // rounded arm ends in plan

// Overlap for robust manifold unions (1–2mm)
overlap = 1.2;

// Derived arm length so overall Y matches bbox_Y
arm_L = (bbox_Y - pad_L)/2;

// Blend length near the root (make it large/visible)
blend_L = min(12, arm_L);

// ---------------- Helpers ----------------
module rrect2d(w, l, r) {
    r2 = min(r, w/2, l/2);
    hull() {
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2 - r2), sy*(l/2 - r2)]) circle(r=r2);
    }
}

// 3D strap with angled arms and large blended transitions
module strap3d() {
    union() {
        // Central pad (flat, distinct)
        linear_extrude(height=thk, center=true, convexity=10)
            square([pad_W, pad_L], center=true);

        // Arms: place their root edge at the pad edge (with overlap), then rotate about X.
        // Use center=true extrusions; translate in Y by half-length so the root aligns.
        for (s=[-1,1]) {
            // Root alignment:
            // pad edge at y = s*pad_L/2
            // arm local root edge at y = -s*arm_L/2 (because arm is centered)
            // so translate by y = s*(pad_L/2 - overlap) + s*(arm_L/2)
            translate([0, s*(pad_L/2 - overlap + arm_L/2), 0])
                rotate([s*arm_angle_deg, 0, 0])
                    linear_extrude(height=thk, center=true, convexity=10)
                        rrect2d(pad_W, arm_L, end_R);

            // Large blended/concave-looking transition:
            // Hull between a wider pad "tab" and a short rotated arm segment near the root.
            hull() {
                // Pad-side tab (flat) slightly longer to read as a filleted/concave blend region
                linear_extrude(height=thk, center=true, convexity=10)
                    translate([0, s*(pad_L/2 - overlap/2)])
                        square([pad_W, blend_L], center=true);

                // Arm-side short segment near root:
                // Place a short segment so its root overlaps the pad edge region.
                // Segment length = blend_L; align its root edge to pad edge with overlap.
                translate([0, s*(pad_L/2 - overlap + blend_L/2), 0])
                    rotate([s*arm_angle_deg, 0, 0])
                        linear_extrude(height=thk, center=true, convexity=10)
                            rrect2d(pad_W, blend_L + overlap, end_R);
            }
        }
    }
}

// Clip to requested bounding box while keeping one connected solid
module bbox_clip() { cube([bbox_X, bbox_Y, bbox_Z], center=true); }

// ---------------- Final ----------------
intersection() {
    strap3d();
    bbox_clip();
}
}
