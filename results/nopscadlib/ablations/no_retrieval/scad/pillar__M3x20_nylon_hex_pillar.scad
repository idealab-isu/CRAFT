// Standoff pillar, external M3 thread (visual), 20mm long
// "Nonemm diameter" interpreted as: no body diameter specified -> use typical 6mm OD.
// One connected solid; thread is the outer surface (not hidden inside a larger cylinder).

$fn = 128;

// -------- Parameters --------
L = 20.0;                 // overall length (mm)
thread_d = 3.0;           // major thread diameter (mm) (M3)
thread_pitch = 0.5;       // pitch (mm) (visual)
body_d = 6.0;             // standoff outer diameter (mm) (unspecified -> typical)
thread_depth = 0.22;      // radial thread depth (mm) (visual)
chamfer_L = 0.6;          // end chamfer length (mm)
overlap = 0.25;           // overlap to ensure watertight unions

// -------- Helpers --------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Chamfered cylinder (both ends)
module chamfered_cylinder(h, d, chamfer) {
    chamfer = clamp(chamfer, 0, h/2 - 0.001);
    union() {
        cylinder(h=h - 2*chamfer + overlap, d=d, center=true);

        translate([0, 0, (h/2 - chamfer/2)])
            cylinder(h=chamfer + overlap, d1=d, d2=max(d - 2*chamfer, 0.2), center=true);

        translate([0, 0, -(h/2 - chamfer/2)])
            cylinder(h=chamfer + overlap, d1=max(d - 2*chamfer, 0.2), d2=d, center=true);
    }
}

// External thread "ridge" (visual) around a core cylinder.
// This creates visible helical detail on the outside.
module external_thread_visual(len, major_d, pitch, depth) {
    depth = clamp(depth, 0.05, major_d/3);
    minor_d = max(major_d - 2*depth, 0.2);

    turns = len / pitch;
    twist_deg = 360 * turns;
    slices = max(ceil(turns * 40), 120);

    union() {
        // Core up to minor diameter
        cylinder(h=len, d=minor_d, center=true);

        // Helical ridge at the outside
        linear_extrude(height=len, center=true, twist=twist_deg, slices=slices, convexity=10)
            translate([minor_d/2, 0, 0])
                polygon(points=[
                    [0, -pitch*0.30],
                    [depth, 0],
                    [0,  pitch*0.30]
                ]);
    }
}

// -------- Model --------
module standoff_pillar() {
    // Make the thread visible by placing it on the outside of the body.
    // Use the larger of body_d and thread_d as the outer diameter.
    outer_d = max(body_d, thread_d);

    union() {
        // Main body
        chamfered_cylinder(L, outer_d, chamfer_L);

        // Thread on the outside (only if it fits the OD); otherwise it still shows as it defines OD.
        // Slightly longer to ensure it reaches into chamfers.
        external_thread_visual(L + 2*overlap, outer_d, thread_pitch, thread_depth);
    }
}

color("Silver") standoff_pillar();