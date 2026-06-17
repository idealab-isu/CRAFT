// Threaded heat-set insert (M3), 8.0mm OD, 6.0mm long
// One connected solid, with visible internal bore + internal thread, and external knurling.

$fn = 120;

// --- Required dimensions ---
insert_OD = 8.0;          // outer diameter
insert_L  = 6.0;          // length
screw_nominal = 3.0;      // for 3.0mm screws

// --- Internal thread / bore (approximate ISO M3) ---
thread_pitch = 0.5;       // M3 coarse
thread_major_D = 3.0;     // major diameter (internal thread crest)
thread_minor_D = 2.5;     // minor diameter (internal thread root) ~2.4-2.6 typical
thread_depth = (thread_major_D - thread_minor_D)/2;

// --- Lead-in chamfers ---
chamfer_depth = 0.6;      // axial depth each end
chamfer_extra = 0.2;      // small extra to ensure clean subtraction

// --- External knurling (diamond) ---
knurl_count = 24;         // around circumference
knurl_amp   = 0.25;       // radial protrusion
knurl_twist = 22;         // degrees of twist over full length (controls helical look)

// --- Robust boolean overlap ---
overlap = 0.2;

// ----------------- Helpers -----------------
module body_cylinder() {
    cylinder(d=insert_OD, h=insert_L, center=true);
}

module end_chamfer(zsign=1) {
    // Subtractive chamfer at each end: frustum that removes outer edge
    // Positioned so it intersects the end face.
    translate([0,0, zsign*(insert_L/2 - chamfer_depth/2)])
        cylinder(d1=insert_OD + 2*chamfer_extra, d2=insert_OD - 2*chamfer_depth, h=chamfer_depth + chamfer_extra, center=true);
}

module internal_thread_cut() {
    // Helical triangular-ish ridge subtracted from a pre-bore to suggest internal threading.
    // Implemented as a twisted linear_extrude of a small rectangle located at the thread radius.
    // This is a visual/fit approximation, not a perfect ISO profile.
    thread_len = insert_L - 2*chamfer_depth;
    twist_deg = 360 * (thread_len / thread_pitch);

    // Base bore to thread major diameter (so the thread is visible in end views)
    translate([0,0,0])
        cylinder(d=thread_major_D, h=insert_L + 2*overlap, center=true);

    // Helical groove: subtract material down toward minor diameter
    translate([0,0,-thread_len/2])
        linear_extrude(height=thread_len, twist=twist_deg, slices=max(60, ceil(thread_len/thread_pitch*40)))
            translate([thread_major_D/2 - thread_depth/2, 0, 0])
                square([thread_depth, thread_pitch*0.55], center=true);
}

module external_knurl_diamond() {
    // Create two opposite-handed helical ridges and intersect with a thin shell region,
    // then union onto the body. Ensures everything is connected (overlaps into body).
    shell_inner_d = insert_OD - 0.6;                 // ensures ridges overlap into body
    shell_outer_d = insert_OD + 2*knurl_amp + 0.2;   // bounds for intersection

    module shell_region() {
        difference() {
            cylinder(d=shell_outer_d, h=insert_L + 2*overlap, center=true);
            cylinder(d=shell_inner_d, h=insert_L + 4*overlap, center=true);
        }
    }

    module helical_ridges(hand=1) {
        // A set of twisted "bars" around the circumference
        union() {
            for (i=[0:knurl_count-1]) {
                rotate([0,0, i*360/knurl_count])
                    translate([insert_OD/2 + knurl_amp*0.55, 0, 0])
                        linear_extrude(height=insert_L + 2*overlap,
                                       twist=hand*knurl_twist,
                                       slices=80,
                                       center=true)
                            square([knurl_amp*1.2, insert_OD*0.18], center=true);
            }
        }
    }

    // Intersect ridges with shell so they only appear on the outside
    intersection() {
        shell_region();
        union() {
            helical_ridges( 1);
            helical_ridges(-1);
        }
    }
}

// ----------------- Final model -----------------
module heat_set_insert() {
    difference() {
        union() {
            // Main body
            body_cylinder();

            // External knurling (connected by overlapping into body)
            external_knurl_diamond();
        }

        // Internal bore + thread (subtractive)
        internal_thread_cut();

        // End chamfers (subtractive)
        end_chamfer( 1);
        end_chamfer(-1);
    }
}

color([0.8, 0.6, 0.2])
heat_set_insert();