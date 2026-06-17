// Threaded heat-set insert (single connected solid)
// Target: 15.0mm OD, 12.0mm long, for M6 screws (internal thread represented)

$fn = 160;

// --- Parameters (mm) ---
insert_od = 15.0;
insert_len = 12.0;

thread_nom_d = 6.0;          // M6 nominal
thread_pitch = 1.0;          // M6 coarse
thread_clearance = 0.25;     // printed clearance for internal thread representation

// External heat-set style features
knurl_depth = 0.6;              // radial protrusion
knurl_band_len = 10.0;          // knurled length centered on body
knurl_teeth_count = 48;         // number of axial ribs
knurl_tooth_tangential_w = 0.9; // rib width (tangential)

// End features
chamfer_len = 0.8;           // lead-in chamfer length
end_relief = 0.25;           // small relief to avoid razor edges

// Internal thread representation (simple helical ridge inside a bore)
thread_turns = insert_len / thread_pitch;
thread_profile_h = 0.35;     // radial height of thread ridge (visual/fit)
thread_profile_w = 0.55;     // axial width of thread ridge (visual)
thread_steps_per_turn = 28;  // smoothness of helix

// Robust overlap for watertight unions/differences (1-2mm as requested)
overlap = 1.2;

// Derived
body_r = insert_od/2;
knurl_r = body_r + knurl_depth;

// Internal diameters (approximate for M6 insert)
minor_d = 5.0; // typical M6 internal minor ~5.0mm
major_d_repr = thread_nom_d + thread_clearance; // representation major

minor_r = minor_d/2;
major_r = major_d_repr/2;

// --- Helpers ---
module chamfered_cylinder(r, h, chamfer=0.8) {
    // FIX: previous version used center=true but did not translate the center section,
    // leaving it at z=0..(h-2c) while chamfers were centered about z=0.
    // This produced a malformed/offset body and can lead to "missing" geometry in views.
    c = min(chamfer, h/2 - 0.01);
    mid_h = max(0.01, h - 2*c);

    union() {
        // centered middle section
        cylinder(r=r, h=mid_h, center=true);

        // top chamfer (centered at +h/2 - c/2)
        translate([0,0, (h/2 - c/2)])
            cylinder(r1=max(0.01, r - c), r2=r, h=c, center=true);

        // bottom chamfer (centered at -h/2 + c/2)
        translate([0,0, -(h/2 - c/2)])
            cylinder(r1=r, r2=max(0.01, r - c), h=c, center=true);
    }
}

module axial_knurl_ribs() {
    // Axial ribs that protrude outward and overlap into the base body
    rib_len = knurl_band_len + 2*overlap;

    // Ensure ribs are thick enough and actually intersect the body
    rib_radial = knurl_depth + overlap; // extends into body by 'overlap'

    for (i = [0:knurl_teeth_count-1]) {
        rotate([0,0, i*360/knurl_teeth_count])
            // Inner face penetrates the body by 'overlap'
            translate([body_r + rib_radial/2 - overlap, 0, 0])
                cube([rib_radial, knurl_tooth_tangential_w, rib_len], center=true);
    }
}

module internal_thread_helix() {
    // Helical ridge volume to subtract from the bore (creates thread grooves)
    segs = max(8, ceil(thread_turns * thread_steps_per_turn));
    dz = insert_len / segs;
    dphi = 360 * thread_turns / segs;

    // Span beyond both ends to avoid coplanar artifacts
    translate([0,0,-insert_len/2 - overlap + dz/2]) {
        for (s = [0:segs-1]) {
            phi = s*dphi;
            translate([0,0,s*dz])
                rotate([0,0,phi])
                    translate([major_r - thread_profile_h/2, 0, 0])
                        cube([thread_profile_h, thread_profile_w, dz + 2*overlap], center=true);
        }
    }
}

module insert_solid() {
    // Outer body with knurl band and ribs (single connected solid)
    union() {
        // Main insert body (15mm OD, 12mm long)
        chamfered_cylinder(r=body_r, h=insert_len, chamfer=chamfer_len);

        // Knurl band centered on body; overlaps by design
        cylinder(r=knurl_r, h=knurl_band_len + 2*overlap, center=true);

        // Ribs intersect both the knurl band and the main body
        axial_knurl_ribs();
    }
}

module insert_with_internal_thread() {
    difference() {
        insert_solid();

        // Base bore (minor diameter) through the insert
        cylinder(r=minor_r, h=insert_len + 2*overlap, center=true);

        // Subtract helical ridge volume from the bore to create thread grooves
        internal_thread_helix();

        // Lead-in chamfers for screw start (both ends), extended with overlap
        translate([0,0, insert_len/2 - chamfer_len/2])
            cylinder(r1=major_r + end_relief, r2=minor_r, h=chamfer_len + 2*overlap, center=true);

        translate([0,0,-insert_len/2 + chamfer_len/2])
            cylinder(r1=minor_r, r2=major_r + end_relief, h=chamfer_len + 2*overlap, center=true);
    }
}

// --- Final ---
insert_with_internal_thread();