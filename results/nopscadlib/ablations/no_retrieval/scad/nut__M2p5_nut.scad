// Hex nut: M2.5, 5.8mm across flats, 2.2mm thick
// One connected solid, no face bumps/markings, with internal thread approximation.

$fn = 96;

// --- Parameters (mm) ---
nut_af      = 5.8;     // across flats
nut_thk     = 2.2;     // thickness

// M2.5 coarse thread (approx)
thread_pitch = 0.45;   // mm
major_d      = 2.5;    // nominal major diameter
minor_d      = 2.05;   // approximate minor diameter for internal thread

// Edge chamfer (small, typical)
chamfer      = 0.20;

// Robust boolean overlap
overlap      = 0.20;

// --- Helpers ---
function hex_R(af) = af / sqrt(3); // circumradius for a hex with given across-flats

module hex_prism(af, h) {
    linear_extrude(height=h, center=true)
        polygon(points=[
            [ hex_R(af), 0],
            [ hex_R(af)/2,  af/2],
            [-hex_R(af)/2,  af/2],
            [-hex_R(af), 0],
            [-hex_R(af)/2, -af/2],
            [ hex_R(af)/2, -af/2]
        ]);
}

// Simple internal thread approximation using linear_extrude twist.
// This is not a standards-perfect ISO profile, but it is a helical threaded void.
module internal_thread(d_major, d_minor, pitch, length) {
    turns = length / pitch;
    // Use a triangular "tooth" in 2D, extruded with twist to form a helix.
    // The triangle spans from minor radius to major radius.
    r_maj = d_major/2;
    r_min = d_minor/2;

    // Tooth thickness along Y kept small to avoid self-intersection.
    tooth_w = pitch * 0.35;

    linear_extrude(height=length + 2*overlap, center=true, twist=turns*360, slices=max(ceil(turns*40), 60))
        translate([0,0,0])
            polygon(points=[
                [r_min, -tooth_w/2],
                [r_maj,  0],
                [r_min,  tooth_w/2]
            ]);
}

// Chamfer cutter (top or bottom) as a conical frustum ring.
module chamfer_cutter(af, chamfer_h, zsign=1) {
    // Place cutter so it intersects the nut edge by chamfer_h.
    // zsign: +1 for top, -1 for bottom.
    R = hex_R(af);
    zc = zsign*(nut_thk/2 - chamfer_h/2);
    translate([0,0,zc])
        cylinder(h=chamfer_h + 2*overlap,
                 r1=R + chamfer_h,
                 r2=R - chamfer_h,
                 center=true);
}

// --- Final nut ---
module hex_nut_M25() {
    difference() {
        // Body
        hex_prism(nut_af, nut_thk);

        // Internal thread void (helical)
        internal_thread(major_d, minor_d, thread_pitch, nut_thk);

        // Small entry chamfers on both faces (typical nut lead-in)
        chamfer_cutter(nut_af, chamfer,  1);
        chamfer_cutter(nut_af, chamfer, -1);
    }
}

color("DimGray") hex_nut_M25();