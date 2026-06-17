// 20x80 aluminium T-slot extrusion profile, 100mm long (single connected solid)
// FIX: ensure no mid-plane split / no floating internal bits by preserving a continuous
// center "spine" (material) through the inner void subtraction, with 1-2mm overlap.

profile_width_mm  = 20.0;   // X
profile_height_mm = 80.0;   // Y
length_mm         = 100.0;  // Z

wall_thickness_mm = 2.0;

// T-slot geometry (approximate)
slot_opening_mm   = 6.0;
slot_neck_mm      = 3.0;
slot_cavity_mm    = 10.0;
slot_depth_mm     = 6.0;

// Internal structure
center_bore_diameter_mm = 6.8;
web_thickness_mm        = 2.0;

// Overlap to guarantee attachment
overlap_mm = 1.5;

$fn = 64;

module extrusion_20x80(len=length_mm) {
    w  = profile_width_mm;
    h  = profile_height_mm;
    t  = wall_thickness_mm;
    wt = web_thickness_mm;

    // Clamp to keep geometry valid
    sd = min(slot_depth_mm, w/2 - t - 0.2);
    so = min(slot_opening_mm, h - 2*t - 0.2);
    sn = min(slot_neck_mm, so - 0.2);
    sc = min(slot_cavity_mm, so + 6);

    // Slot placement on the 20mm faces (left/right)
    cavity_xc = w/2 - (sd - sc/2);
    neck_xc   = w/2 - (sd - sn/2);
    open_xc   = w/2 - (t/2);

    inner_w = max(w - 2*t, 0.1);
    inner_h = max(h - 2*t, 0.1);

    // Ensure a continuous material bridge remains between left/right halves.
    // This "spine" is NOT subtracted from the outer body (i.e., it stays solid),
    // preventing any mid-plane separation.
    spine_w = max(wt + 2*overlap_mm, 1.0); // 1-2mm guaranteed overlap

    color("Silver")
    union() {
        difference() {
            // Outer body
            cube([w, h, len], center=true);

            // Inner void subtractor, but KEEP a central spine (material) so the body stays connected.
            // We subtract: (inner void MINUS spine) == difference(inner void, spine)
            difference() {
                cube([inner_w, inner_h, len + 2*overlap_mm], center=true);

                // Central spine to preserve material (connects left/right and prevents split)
                cube([spine_w, inner_h + 2*overlap_mm, len + 4*overlap_mm], center=true);
            }

            // T-slots on left/right faces
            for (sx = [-1, 1]) {
                // Opening cut (through outer wall thickness)
                translate([sx*open_xc, 0, 0])
                    cube([t + overlap_mm, so, len + 2*overlap_mm], center=true);

                // Neck cut
                translate([sx*neck_xc, 0, 0])
                    cube([sn, sn, len + 2*overlap_mm], center=true);

                // Cavity cut
                translate([sx*cavity_xc, 0, 0])
                    cube([sc, sc, len + 2*overlap_mm], center=true);
            }

            // Center bore
            cylinder(d=center_bore_diameter_mm, h=len + 2*overlap_mm, center=true);
        }
    }
}

extrusion_20x80(length_mm);