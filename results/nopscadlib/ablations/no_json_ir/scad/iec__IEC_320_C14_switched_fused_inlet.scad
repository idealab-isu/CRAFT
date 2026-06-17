// IEC Switched Fused Power Inlet Module (approximate geometry)
// Target faceplate/module size: 40.0mm x 27.0mm
// STRUCTURAL FIXES (connectivity):
// - Orange internal insert is now physically attached to the main body via a solid "tongue" that
//   overlaps into the body by ~1–2mm (not just proximity).
// - Orange insert is also prevented from being fully removed by the inlet cavity subtraction by
//   placing it slightly deeper than the cavity and adding the tongue behind the cavity.
// - All solids are combined in a single union() (inside one difference()).

$fn = 64;

module rrect2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)])
                circle(r=r2);
    }
}

module rrect3d(w, h, d, r, center=true) {
    linear_extrude(height=d, center=center)
        rrect2d(w, h, r);
}

module iec_inlet_module() {

    // --- Key dimensions (mm) ---
    face_w = 40.0;
    face_h = 27.0;
    flange_t = 3.0;

    // Flange ears (mounting tabs)
    ear_w = 6.0;
    ear_h = 4.0;
    ear_t = flange_t;

    // Main body behind flange
    body_w = 34.0;
    body_h = 22.0;
    body_d = 30.0;

    // Front bezel recess
    recess_d = 1.6;
    bezel_margin = 1.2;

    // IEC C14 inlet opening (rounded rectangle)
    inlet_w = 27.0;
    inlet_h = 19.0;
    inlet_r = 2.0;

    // Deeper cavity behind inlet
    inlet_cavity_d = 10.0;
    inlet_cavity_w = inlet_w + 2.0;
    inlet_cavity_h = inlet_h + 2.0;
    inlet_cavity_r = inlet_r + 0.8;

    // Switch + fuse openings (front face, above inlet)
    top_band_h = 7.0;
    sw_w = 12.0;
    sw_h = 6.0;
    sw_r = 1.0;

    fuse_w = 16.0;
    fuse_h = 6.0;
    fuse_r = 1.0;

    gap = 2.0;

    // Fuse drawer "lip"
    fuse_lip_t = 1.2;
    fuse_lip_w = fuse_w + 3.0;
    fuse_lip_h = fuse_h + 2.0;
    fuse_lip_r = 1.2;

    // Switch rocker bezel
    sw_lip_t = 1.0;
    sw_lip_w = sw_w + 2.0;
    sw_lip_h = sw_h + 2.0;
    sw_lip_r = 1.2;

    // Mounting holes on ears (2 holes, left/right)
    hole_r = 1.7;
    hole_x = face_w/2 + ear_w/2;
    hole_y = 0;

    // Panel retention spring bumps (simple wedges on body sides)
    latch_w = 2.0;
    latch_h = 6.0;
    latch_d = 10.0;
    latch_inset_from_front = 8.0;

    // Rear spade terminals (connected via a rear base block)
    spade_w = 6.0;
    spade_h = 10.0;
    spade_len = 8.0;
    spade_pitch = 10.0;
    spade_base_t = 2.0;

    // --- STRUCTURAL FIX PARAMETERS (overlaps/attachments) ---
    overlap = 1.2; // 1–2mm overlap to guarantee manifold connection

    // "Orange internal insert" (create a connected internal block)
    insert_w = inlet_cavity_w - 1.0;   // slightly smaller than cavity
    insert_h = inlet_cavity_h - 1.0;
    insert_d = inlet_cavity_d - 1.0;
    insert_r = max(0.6, inlet_cavity_r - 0.6);

    // Side rails (dark side components)
    side_part_w = 3.0;
    side_part_h = 14.0;
    side_part_d = 16.0;

    // Derived placements
    // Coordinate system: X=width, Y=height, Z=depth
    // Front face of flange at z=0, rear extends to +Z.
    body_z0 = flange_t;
    body_zc = body_z0 + body_d/2;

    assert(body_w <= face_w && body_h <= face_h);

    // Inlet opening centered in lower portion
    bottom_margin = 2.0;
    inlet_yc = -face_h/2 + bottom_margin + inlet_h/2;
    inlet_xc = 0;

    // Top band centerline for switch/fuse
    top_band_yc = face_h/2 - top_band_h/2;

    // Place switch and fuse side-by-side in top band
    total_top_w = sw_w + gap + fuse_w;
    sw_xc   = -total_top_w/2 + sw_w/2;
    fuse_xc =  total_top_w/2 - fuse_w/2;

    // Rear spade base block (connects spades to body)
    spade_base_w = (2*spade_pitch) + spade_w;
    spade_base_h = 12.0;
    spade_base_z0 = body_z0 + body_d - spade_base_t; // overlaps into body
    spade_base_zc = spade_base_z0 + spade_base_t/2;

    // Spade positions (3 terminals)
    spade_yc = -body_h/2 + spade_base_h/2;
    spade_z0 = body_z0 + body_d - 0.6; // start slightly inside body for overlap
    spade_zc = spade_z0 + spade_len/2;

    // Latch placement (on body sides)
    latch_zc = body_z0 + latch_inset_from_front + latch_d/2;
    latch_yc = 0;

    // Inlet cavity placement
    cavity_z0 = flange_t + 0.6;
    cavity_z1 = cavity_z0 + inlet_cavity_d;
    cavity_zc = (cavity_z0 + cavity_z1)/2;

    // --- ORANGE INSERT CONNECTIVITY FIX ---
    // The cavity subtraction removes material from z=[cavity_z0..cavity_z1].
    // If the insert sits entirely inside that range, it can appear "separate" in side views.
    // Fix: push the insert slightly deeper so it intersects solid body behind the cavity,
    // and add a "tongue" that extends further into the body with 1–2mm overlap.
    insert_z1 = cavity_z1 + overlap;                 // extend past cavity into solid body
    insert_z0 = insert_z1 - insert_d;
    insert_zc = (insert_z0 + insert_z1)/2;

    // Tongue: starts inside the insert and extends into the body beyond the cavity
    tongue_t = 3.0;                                 // along Z
    tongue_w = insert_w * 0.55;
    tongue_h = insert_h * 0.55;
    tongue_z0 = cavity_z1 - overlap;                // begins slightly before cavity ends
    tongue_z1 = tongue_z0 + tongue_t;
    tongue_zc = (tongue_z0 + tongue_z1)/2;

    // Side parts: attach to body sides with overlap into body
    side_xc = (body_w/2 + side_part_w/2 - overlap); // ensures intersection
    side_yc = 0;
    side_zc = body_z0 + body_d*0.55;

    difference() {
        union() {
            // --- Front flange with ears ---
            translate([0, 0, flange_t/2])
                cube([face_w, face_h, flange_t], center=true);

            translate([-(face_w/2 + ear_w/2), 0, flange_t/2])
                cube([ear_w, face_h + 2*ear_h, ear_t], center=true);

            translate([ (face_w/2 + ear_w/2), 0, flange_t/2])
                cube([ear_w, face_h + 2*ear_h, ear_t], center=true);

            // --- Main body behind flange ---
            translate([0, 0, body_zc])
                cube([body_w, body_h, body_d], center=true);

            // --- Side dark components (rails) ATTACHED to body with overlap ---
            for (sx = [-1, 1]) {
                translate([sx*side_xc, side_yc, side_zc])
                    cube([side_part_w, side_part_h, side_part_d], center=true);

                // Tie block to guarantee connection continuity
                translate([sx*(body_w/2 - overlap/2), side_yc, side_zc])
                    cube([overlap + 0.6, side_part_h, side_part_d], center=true);
            }

            // --- Panel retention latches (connected to body) ---
            for (sx = [-1, 1]) {
                translate([sx*(body_w/2 - latch_w/2 + overlap/2), latch_yc, latch_zc])
                    cube([latch_w + overlap, latch_h, latch_d], center=true);

                translate([sx*(body_w/2 + 0.6), latch_yc, latch_zc])
                    linear_extrude(height=latch_d, center=true)
                        polygon(points=[
                            [0, -latch_h/2],
                            [0,  latch_h/2],
                            [sx*2.0, 0]
                        ]);
            }

            // --- Fuse drawer lip (protruding frame) ---
            translate([fuse_xc, top_band_yc, flange_t - fuse_lip_t/2])
                difference() {
                    rrect3d(fuse_lip_w, fuse_lip_h, fuse_lip_t, fuse_lip_r, center=true);
                    rrect3d(fuse_w + 0.8, fuse_h + 0.8, fuse_lip_t + 0.2, max(0.2, fuse_r), center=true);
                }

            // --- Switch bezel lip (protruding frame) ---
            translate([sw_xc, top_band_yc, flange_t - sw_lip_t/2])
                difference() {
                    rrect3d(sw_lip_w, sw_lip_h, sw_lip_t, sw_lip_r, center=true);
                    rrect3d(sw_w + 0.8, sw_h + 0.8, sw_lip_t + 0.2, max(0.2, sw_r), center=true);
                }

            // --- Rear spade base (ensures spades are connected) ---
            translate([0, spade_yc, spade_base_zc])
                cube([spade_base_w, spade_base_h, spade_base_t], center=true);

            // --- Spade terminals (3) ---
            for (i = [-1, 0, 1]) {
                translate([i*spade_pitch, spade_yc, spade_zc])
                    cube([spade_w, spade_h, spade_len], center=true);

                translate([i*spade_pitch, spade_yc, spade_z0 + spade_base_t/2])
                    cube([spade_w, spade_h, spade_base_t], center=true);
            }

            // --- Orange internal insert/block (NOW PHYSICALLY ATTACHED) ---
            // Insert extends slightly beyond the cavity into solid body.
            color([1, 0.5, 0])
                translate([inlet_xc, inlet_yc, insert_zc])
                    rrect3d(insert_w, insert_h, insert_d, insert_r, center=true);

            // Tongue: guarantees a solid connection to the body behind the cavity
            // (overlaps into solid body by ~overlap and overlaps into insert volume).
            color([1, 0.5, 0])
                translate([inlet_xc, inlet_yc, tongue_zc])
                    rrect3d(tongue_w, tongue_h, tongue_t, insert_r, center=true);
        }

        // --- Front bezel recess pocket ---
        translate([0, 0, recess_d/2])
            cube([face_w - 2*bezel_margin, face_h - 2*bezel_margin, recess_d + 0.2], center=true);

        // --- IEC inlet opening through flange + a bit into body ---
        translate([inlet_xc, inlet_yc, (flange_t + 2.0)/2])
            rrect3d(inlet_w, inlet_h, flange_t + 2.0 + 0.2, inlet_r, center=true);

        // --- Deeper inlet cavity behind opening ---
        translate([inlet_xc, inlet_yc, cavity_zc])
            rrect3d(inlet_cavity_w, inlet_cavity_h, inlet_cavity_d + 0.2, inlet_cavity_r, center=true);

        // --- Switch opening (shallow recess) ---
        translate([sw_xc, top_band_yc, recess_d/2])
            rrect3d(sw_w, sw_h, recess_d + 0.2, sw_r, center=true);

        // --- Fuse drawer opening (shallow recess) ---
        translate([fuse_xc, top_band_yc, recess_d/2])
            rrect3d(fuse_w, fuse_h, recess_d + 0.2, fuse_r, center=true);

        // --- Mounting holes (through ears/flange) ---
        for (sx = [-1, 1])
            translate([sx*hole_x, hole_y, flange_t/2])
                cylinder(h=flange_t + 0.6, r=hole_r, center=true);
    }
}

iec_inlet_module();