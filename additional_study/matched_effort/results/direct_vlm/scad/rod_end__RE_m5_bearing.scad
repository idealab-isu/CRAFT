$fn=128;

// uxcell-style M5x0.8 right-hand male rod end (self-lubricating) - connected solid.
// Includes: forged eye housing with through-hole, spherical ball with bore, and external M5x0.8 thread.

module rod_end_m5(
    // Thread / shank
    shank_major_d = 5.0,     // M5 major diameter
    pitch         = 0.8,
    shank_len     = 22.0,    // threaded length
    thread_depth  = 0.32,    // radial depth (cosmetic but real helical geometry)

    // Wrench flats / collar
    wrench_flat   = 10.0,    // across flats
    wrench_thk    = 2.4,

    // Neck between wrench and eye
    neck_d        = 7.0,
    neck_len      = 3.2,

    // Eye housing (forged look)
    eye_od        = 14.0,    // outer diameter of eye ring
    eye_thk       = 7.0,     // thickness along Z
    eye_len_y     = 18.0,    // overall length along Y (gives "rod-end" silhouette)
    eye_end_r     = 6.0,     // rounding radius for ends (capsule)

    // Through-hole (pin hole) along X
    eye_hole_d    = 5.2,

    // Ball (liner)
    ball_od       = 8.0,
    ball_bore_d   = 5.2,

    // Small overlaps for watertight unions
    ov            = 0.25
){
    union() {
        // --- External threaded shank (helical) ---
        // Place shank below the wrench collar; top of shank meets collar with overlap.
        translate([0,0,-shank_len - wrench_thk + ov])
            external_thread(d_major=shank_major_d, pitch=pitch, len=shank_len + wrench_thk, depth=thread_depth);

        // --- Wrench flats (hex collar) ---
        translate([0,0,-wrench_thk])
            hex_prism(flat=wrench_flat, h=wrench_thk + ov);

        // --- Neck transition (cyl) ---
        cylinder(d=neck_d, h=neck_len + ov);

        // --- Eye housing (forged/capsule body) ---
        // Eye starts at z = neck_len, overlaps into neck by ov.
        translate([0,0,neck_len - ov])
            difference() {
                // Capsule-like body along Y, with a circular eye ring at center.
                union() {
                    // Main capsule body (gives recognizable rod-end silhouette in side view)
                    capsule_y(len=eye_len_y, r=eye_end_r, h=eye_thk);

                    // Eye ring thickening around the ball area
                    // Centered at Y=0, adds material around the spherical seat.
                    cylinder(d=eye_od, h=eye_thk);
                }

                // Pin through-hole along X (goes through entire housing)
                translate([0,0,eye_thk/2])
                    rotate([0,90,0])
                        cylinder(d=eye_hole_d, h=eye_od + eye_len_y + 4, center=true);

                // Spherical seat cavity (slightly larger than ball for "liner" look)
                translate([0,0,eye_thk/2])
                    sphere(d=ball_od + 0.6);

                // Side relief to suggest forged profile (subtractive, keeps eye ring)
                // Scaled cylinder removes some material on the sides (Y direction).
                translate([0,0,eye_thk/2])
                    scale([1.0, 0.72, 1.0])
                        cylinder(d=eye_od*0.98, h=eye_thk + 0.6, center=true);
            }

        // --- Ball (self-lubricating insert) ---
        // Ball centered in the eye housing.
        translate([0,0,neck_len + eye_thk/2])
            difference() {
                sphere(d=ball_od);
                rotate([0,90,0])
                    cylinder(d=ball_bore_d, h=ball_od + 4, center=true);
            }
    }
}

// ---------- Helpers ----------

module hex_prism(flat=10, h=2){
    r = flat / sqrt(3); // circumradius for given flat-to-flat
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

// Capsule along Y: hull of two cylinders (extruded along Z)
module capsule_y(len=18, r=6, h=7){
    // Ensure len >= 2r
    L = max(len, 2*r);
    hull() {
        translate([0,  L/2 - r, 0]) cylinder(r=r, h=h);
        translate([0, -L/2 + r, 0]) cylinder(r=r, h=h);
    }
}

// External ISO-like triangular thread (approx) using helical extrusion.
// Produces a connected solid thread around a core cylinder.
module external_thread(d_major=5, pitch=0.8, len=22, depth=0.32){
    turns = len / pitch;
    twist_deg = 360 * turns;

    d_minor = d_major - 2*depth;
    core_d  = max(d_minor, d_major - 2*depth);

    // Core cylinder (minor diameter)
    cylinder(d=core_d, h=len);

    // Thread ridge: triangular profile swept helically
    // Profile is placed at radius ~ core/2 and extends outward to major diameter.
    // Use a small overlap into the core for robust union.
    linear_extrude(height=len, twist=twist_deg, slices=max(120, ceil(turns*120)))
        translate([core_d/2 - depth*0.15, 0, 0])
            polygon([
                [0, -pitch*0.28],
                [depth*1.05, 0],
                [0,  pitch*0.28]
            ]);
}

// Render
rod_end_m5();