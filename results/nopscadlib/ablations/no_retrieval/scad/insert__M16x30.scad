// Threaded heat-set insert (simplified but recognizable)
// Target: 30.0mm OD, 25.0mm long (body), internal thread for 16.0mm screw

$fn = 180;

// -------------------- Parameters --------------------
insert_od = 30.0;          // outer diameter (body, excluding flange)
insert_len = 25.0;         // body length (not including flange thickness)
screw_nom_d = 16.0;        // nominal screw diameter

thread_pitch = 2.0;        // mm
thread_depth = 0.75;       // radial depth of internal thread (visual + printable)
thread_clearance = 0.35;   // added to major diameter for fit

// Bore diameters (approx for internal thread representation)
bore_major_d = screw_nom_d + thread_clearance;          // crest diameter of internal thread
bore_minor_d = bore_major_d - 2*thread_depth;           // root diameter

// Lead-in / relief
chamfer_len = 1.5;
relief_groove_w = 2.2;
relief_groove_depth = 0.8;

// Heat-set knurl (diamond knurl via crossed helical grooves)
knurl_depth = 0.7;         // groove depth cut into OD
knurl_pitch = 2.2;         // axial pitch of knurl helices
knurl_band_len = 18.0;     // length of knurled band centered on body

// Flange
flange_od = 34.0;
flange_thk = 2.0;

// Driver feature (top internal square-ish pocket)
driver_flat_w = 22.0;
driver_flat_d = 8.0;

// Robust boolean overlap (use 1-2mm as requested)
overlap = 1.2;

// -------------------- Helpers --------------------
module z_centered_cyl(r, h) { cylinder(r=r, h=h, center=true); }

// Outer solid: body length is exactly insert_len, OD is exactly insert_od
module body_with_flange() {
    union() {
        z_centered_cyl(insert_od/2, insert_len);

        // Flange on top, connected with overlap (recalculated)
        translate([0, 0, insert_len/2 + flange_thk/2 - overlap])
            z_centered_cyl(flange_od/2, flange_thk);
    }
}

// Internal thread cutter: helical "tooth" volume SUBTRACTED from the bore cylinder.
// Uses linear_extrude(twist) on a 2D profile placed at the correct radius.
module internal_thread_cut() {
    turns = (insert_len + 2*overlap) / thread_pitch;

    linear_extrude(
        height = insert_len + 2*overlap,
        center = true,
        twist  = turns*360,
        slices = max(ceil(turns*60), 160)
    )
        // Place tooth so it intersects the bore wall (recalculated)
        translate([bore_major_d/2 - thread_depth, 0, 0])
            polygon(points=[
                [0, -thread_pitch*0.22],
                [thread_depth, 0],
                [0,  thread_pitch*0.22]
            ]);
}

// Threaded bore void: start with major-diameter cylinder (guarantees visible hole),
// then subtract the helical cutter from it to create thread grooves in the void.
// This whole void is then subtracted from the insert body.
module internal_bore_with_thread_void() {
    difference() {
        z_centered_cyl(bore_major_d/2, insert_len + 2*overlap);
        internal_thread_cut();
    }
}

module lead_in_chamfers_void() {
    union() {
        // Top chamfer: ensure it opens to the top face and overlaps (recalculated)
        translate([0, 0, insert_len/2 - chamfer_len/2 + overlap/2])
            cylinder(
                r1 = bore_major_d/2 + chamfer_len*0.9,
                r2 = bore_major_d/2,
                h  = chamfer_len + overlap,
                center = true
            );

        // Bottom chamfer: ensure it opens to the bottom face and overlaps (recalculated)
        translate([0, 0, -insert_len/2 + chamfer_len/2 - overlap/2])
            cylinder(
                r1 = bore_major_d/2,
                r2 = bore_major_d/2 + chamfer_len*0.9,
                h  = chamfer_len + overlap,
                center = true
            );
    }
}

module thread_relief_groove_void() {
    // Positioned just above the bottom chamfer; overlaps for robust subtraction (recalculated)
    translate([0, 0, -insert_len/2 + chamfer_len + relief_groove_w/2])
        z_centered_cyl((bore_major_d/2) + relief_groove_depth, relief_groove_w + overlap);
}

module driver_feature_void() {
    // Pocket from the top face down; overlaps to ensure it opens to the top (recalculated)
    translate([0, 0, insert_len/2 - driver_flat_d/2 + overlap/2])
        cube([driver_flat_w, driver_flat_w, driver_flat_d + overlap], center=true);
}

// Diamond knurl: subtract two sets of shallow helical grooves from the OD band.
// Ensure the groove solids are centered on the body and actually intersect the OD.
module knurl_groove_set(hand=1) {
    turns = knurl_band_len / knurl_pitch;

    linear_extrude(
        height = knurl_band_len + 2*overlap,
        center = true,
        twist  = hand*turns*360,
        slices = max(ceil(turns*70), 200)
    )
        // Place groove circle so it cuts into the outer surface (recalculated)
        translate([insert_od/2 - knurl_depth, 0, 0])
            circle(r=knurl_depth, $fn=48);
}

module external_knurl_cut() {
    // Limit grooves to a band around the body so they don't affect the flange
    intersection() {
        union() {
            knurl_groove_set(+1);
            knurl_groove_set(-1);
        }
        // Band limiter centered on body (recalculated)
        z_centered_cyl((insert_od/2) + 3*knurl_depth, knurl_band_len + 2*overlap);
    }
}

// -------------------- Final Model --------------------
module heatset_insert() {
    difference() {
        // Outer solid (one connected piece)
        body_with_flange();

        // External knurl grooves (typical heat-set texture)
        external_knurl_cut();

        // Internal threaded bore (visible hole + thread detail)
        internal_bore_with_thread_void();

        // Lead-in chamfers
        lead_in_chamfers_void();

        // Thread relief groove
        thread_relief_groove_void();

        // Driver feature
        driver_feature_void();
    }
}

heatset_insert();