// Dimension-calibrated (target: 0.15 x 0.13 x 0.08 mm)
scale([0.873569, 0.976931, 1.520024])
{
// Bent elbow-like bracket/duct component (fixed structure + connectivity)
// Target bounding box: 0.2 x 0.1 x 0.1 mm (X x Y x Z)

$fn = 96;

// --- Bounding box targets ---
bbox_X = 0.20;
bbox_Y = 0.10;
bbox_Z = 0.10;

// --- Small overlap to guarantee connectivity (in mm) ---
ov = 0.002;   // 1–2 "mm" requested; using 0.002 in this tiny scale to avoid blowing bbox

// --- Main elbow (solid, thick curved body) ---
R_center = 0.040;          // centerline radius of elbow
tube_D   = 0.060;          // outer diameter of elbow body (thick)
arc_deg  = 90;

// --- End interfaces ---
big_L = 0.070;             // larger rectangular block length (along -X)
big_Y = bbox_Y;
big_Z = bbox_Z;

tongue_L = 0.060;          // smaller tongue length (along +Y)
tongue_Y = 0.040;
tongue_Z = 0.050;

// --- Obround end-cap near small end (integrated) ---
cap_L = 0.040;             // obround length along +Y
cap_W = 0.030;             // obround width along X
cap_Z = 0.050;

// --- Top lugs/steps near tip ---
lug1_L = 0.018; lug1_W = 0.018; lug1_H = 0.010;
lug2_L = 0.014; lug2_W = 0.014; lug2_H = 0.008;

// ----------------- Helpers -----------------
module obround_2d(L, W) {
    // L along Y, W along X
    r = W/2;
    hull() {
        translate([0, -L/2 + r]) circle(r=r);
        translate([0,  L/2 - r]) circle(r=r);
    }
}

module elbow_solid() {
    // Quarter torus-like solid made by rotate_extrude of a circle
    // Arc runs from +X toward +Y in XY plane.
    rotate_extrude(angle=arc_deg, convexity=10)
        translate([R_center, 0, 0])
            circle(d=tube_D);
}

module elbow_keep_quadrant() {
    // Keep only the +X,+Y quadrant and limit Z to bbox_Z
    intersection() {
        elbow_solid();
        // Keep region: x>=0, y>=0, |z|<=bbox_Z/2
        translate([bbox_X/2, bbox_Y/2, 0])
            cube([bbox_X, bbox_Y, bbox_Z], center=true);
    }
}

// ----------------- Main connected solid -----------------
module model_solid() {

    // Useful radii/edges for attachment math
    elbow_outer_r = R_center + tube_D/2;   // max x or y of elbow in kept quadrant

    // Place everything so the elbow sits near the inside corner (x>=0,y>=0),
    // then attach a big block at +X end and a tongue at +Y end.
    union() {

        // 1) Curved 90-degree elbow body (recognizable L/arc silhouette)
        elbow_keep_quadrant();

        // 2) Large rectangular block at the +X end, extending toward -X
        // Attach: block's +X face slightly overlaps elbow's max X (elbow_outer_r)
        // Block center x = (attach_x - big_L/2 + ov)
        translate([ elbow_outer_r - big_L/2 + ov,
                    big_Y/2,
                    0 ])
            cube([big_L, big_Y, big_Z], center=true);

        // 3) Smaller rectangular tongue at the +Y end, extending toward +Y
        // Attach: tongue's -Y face slightly overlaps elbow's max Y (elbow_outer_r)
        // Tongue center y = (attach_y + tongue_L/2 - ov)
        translate([ tongue_Y/2,
                    elbow_outer_r + tongue_L/2 - ov,
                    0 ])
            cube([tongue_Y, tongue_L, tongue_Z], center=true);

        // 4) Obround end-cap integrated near the smaller end (near tongue tip)
        // Place so its -Y end overlaps tongue tip region.
        // Tongue +Y face is at y = elbow_outer_r + tongue_L - ov
        cap_center_y = (elbow_outer_r + tongue_L - ov) - cap_L/2 + ov;
        translate([ 0,
                    cap_center_y,
                    0 ])
            linear_extrude(height=cap_Z, center=true)
                obround_2d(cap_L, cap_W);

        // 5) Two small rectangular lugs/steps on top side near the tip
        // Put them on top of the tongue (z = tongue_Z/2) with slight overlap.
        tongue_top_z = tongue_Z/2;

        // Lug 1 (closest to tip): overlap into tongue by ov in Z and Y
        lug1_center_y = (elbow_outer_r + tongue_L - ov) - lug1_L/2 + ov;
        translate([ 0,
                    lug1_center_y,
                    tongue_top_z + lug1_H/2 - ov ])
            cube([lug1_W, lug1_L, lug1_H], center=true);

        // Lug 2 (behind lug 1): positioned just behind with overlap
        lug2_center_y = lug1_center_y - (lug1_L/2 + lug2_L/2) + ov;
        translate([ 0,
                    lug2_center_y,
                    tongue_top_z + lug2_H/2 - ov ])
            cube([lug2_W, lug2_L, lug2_H], center=true);
    }
}

// ----------------- Final (fit/center to bbox) -----------------
module complete_model() {
    // Compute conservative extents from construction (before centering):
    elbow_outer_r = R_center + tube_D/2;

    // X extents:
    // min from big block: (elbow_outer_r - big_L + 2*ov) approximately
    // max from elbow: elbow_outer_r
    x_min = elbow_outer_r - big_L + 2*ov;
    x_max = elbow_outer_r;

    // Y extents:
    // min from elbow: 0
    // max from tongue/cap: elbow_outer_r + tongue_L (cap doesn't exceed tongue tip in Y)
    y_min = 0;
    y_max = elbow_outer_r + tongue_L;

    // Center into bbox in X/Y, keep Z centered at 0
    x_mid = (x_min + x_max)/2;
    y_mid = (y_min + y_max)/2;

    translate([bbox_X/2 - x_mid, bbox_Y/2 - y_mid, 0])
        model_solid();
}

complete_model();
}
