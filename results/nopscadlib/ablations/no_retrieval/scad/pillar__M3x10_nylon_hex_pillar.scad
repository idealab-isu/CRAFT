// Standoff pillar: M3 external thread, 10mm long.
// Requested diameter was invalid ("Nonemm"), so this models a true M3 threaded rod
// with major diameter = 3.0mm (no extra unthreaded pillar OD).
$fn = 128;

// -------- Parameters (mm) --------
length = 10.0;           // overall length
d_major = 3.0;           // M3 major diameter
pitch   = 0.5;           // M3 coarse pitch (0.5mm)
thread_h = 0.27;         // radial thread height (visual/printable approximation)
chamfer_h = 0.5;         // small end chamfer
eps = 0.02;              // overlap for watertight unions

// -------- Derived --------
r_major = d_major/2;
r_minor = max(0.2, r_major - thread_h);
turns   = length / pitch;

// -------- External helical thread (connected solid) --------
// Build a helical "rib" and union it with a minor-diameter core.
module external_thread(len, pitch, rmaj, rmin) {
    local_turns = len / pitch;
    // Thread thickness along Z in the 2D profile (kept < pitch)
    w = pitch * 0.55;

    // 2D profile in (radius, z) plane; extruded with twist to form helix.
    // Slight overlaps ensure robust union with the core.
    linear_extrude(
        height = len,
        twist = local_turns * 360,
        slices = max(ceil(local_turns * 80), 120),
        convexity = 10
    )
    polygon(points=[
        [rmin - eps, -w/2],
        [rmaj + eps, -w/6],
        [rmaj + eps,  w/6],
        [rmin - eps,  w/2]
    ]);
}

// -------- Model --------
module standoff_m3(len) {
    union() {
        // Minor-diameter core (centered)
        cylinder(r = r_minor, h = len, center = true);

        // Helical thread spans full length; align bottom to core bottom
        translate([0, 0, -len/2])
            external_thread(len, pitch, r_major, r_minor);

        // End chamfers (additive) to avoid razor edges while keeping one solid
        translate([0, 0,  len/2 - chamfer_h/2])
            cylinder(r1 = r_major, r2 = max(0.2, r_major - chamfer_h), h = chamfer_h, center = true);
        translate([0, 0, -len/2 + chamfer_h/2])
            cylinder(r1 = max(0.2, r_major - chamfer_h), r2 = r_major, h = chamfer_h, center = true);
    }
}

standoff_m3(length);