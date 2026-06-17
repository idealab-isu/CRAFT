// Standoff pillar: M4 external thread, 20mm long, 8mm OD
// One connected solid, no floating parts

$fn = 128;

// Parameters (mm)
L = 20.0;                 // overall length
body_d = 8.0;             // outer diameter
thread_nom_d = 4.0;       // nominal thread diameter (major)
thread_pitch = 0.7;       // pitch (visual/approx)
thread_depth = 0.35;      // radial depth of thread profile (visual/approx)
chamfer = 0.6;            // end chamfer length
overlap = 0.25;           // overlap to ensure watertight unions

// Derived
body_r = body_d/2;
thread_r_major = thread_nom_d/2;
thread_r_minor = max(thread_r_major - thread_depth, 0.01);

// --- Helpers ---
module end_chamfer_cut(zsign=1) {
    // Subtractive chamfer cut at each end of the body
    translate([0, 0, zsign*(L/2 - chamfer/2)])
        cylinder(h=chamfer + overlap, r1=body_r + 0.01, r2=max(body_r - chamfer, 0.01), center=true);
}

module body_core() {
    difference() {
        cylinder(h=L, r=body_r, center=true);
        end_chamfer_cut(+1);
        end_chamfer_cut(-1);
    }
}

// External helical thread (approx) using rotate_extrude + linear_extrude twist
// Built as a continuous helical ridge around the M4 major diameter.
module external_thread() {
    turns = L / thread_pitch;
    slices = max(ceil(turns * 40), 160);

    // 2D profile in X-Y plane for rotate_extrude:
    // A small rectangle at radius = thread_r_minor..thread_r_major
    // with a tangential width to make the ridge visible.
    tangential_w = thread_pitch * 0.55;

    translate([0, 0, -L/2])
        linear_extrude(height=L, twist=turns*360, slices=slices, convexity=10)
            rotate_extrude(angle=360, convexity=10)
                translate([thread_r_minor, -tangential_w/2, 0])
                    square([thread_depth, tangential_w], center=false);
}

// Lead-in cuts to soften thread start/end (cuts thread only)
module thread_lead_in_cuts() {
    // Conical cuts at both ends, sized to fully remove the ridge at the ends
    r_cut = thread_r_major + thread_depth + 0.5;

    translate([0, 0,  L/2 - chamfer/2])
        cylinder(h=chamfer + overlap, r1=r_cut, r2=0.01, center=true);

    translate([0, 0, -L/2 + chamfer/2])
        cylinder(h=chamfer + overlap, r1=r_cut, r2=0.01, center=true);
}

// Final: body + thread, all connected
module standoff() {
    union() {
        body_core();

        // Thread ridge is centered on the body surface and overlaps into it
        // to guarantee a single connected solid.
        difference() {
            external_thread();
            thread_lead_in_cuts();
        }
    }
}

standoff();