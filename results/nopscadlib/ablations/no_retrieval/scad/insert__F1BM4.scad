// Threaded heat-set insert
// Spec: 8.2mm OD, 6.3mm length, internal thread for M4 (4.0mm) screws
// Model is ONE connected solid; all placements are formula-based.

$fn = 160;

// --- Parameters (mm) ---
outer_diameter = 8.2;     // OD
length         = 6.3;     // overall length

// M4 internal thread (ISO coarse)
thread_major_d   = 4.0;   // nominal major diameter
thread_pitch     = 0.7;   // M4 coarse pitch
thread_depth     = 0.30;  // radial depth (visual/approx)
thread_clearance = 0.10;  // extra clearance

// Lead-in chamfers
chamfer_height = 0.5;

// External knurl/barb rings
knurl_depth       = 0.30;
knurl_ring_height = 0.60;
knurl_pitch       = 1.00;

// Robust booleans
eps     = 0.6;     // through-cut margin
overlap = 0.08;    // overlap for unions

// --- Derived ---
outer_r = outer_diameter/2;

// Minor diameter for internal thread (approx + clearance)
thread_minor_d = thread_major_d - 2*thread_depth + 2*thread_clearance;
thread_minor_r = thread_minor_d/2;

// --- Helpers ---
module external_body() {
    union() {
        // Main body (exact length and OD)
        cylinder(h=length, r=outer_r, center=true);

        // End chamfers (additive, stays within OD)
        translate([0, 0,  length/2 - chamfer_height/2])
            cylinder(h=chamfer_height, r1=outer_r, r2=max(0.01, outer_r - chamfer_height), center=true);

        translate([0, 0, -length/2 + chamfer_height/2])
            cylinder(h=chamfer_height, r1=max(0.01, outer_r - chamfer_height), r2=outer_r, center=true);

        // External rings distributed along usable length (computed)
        usable_h = length - 2*chamfer_height;
        n_rings  = max(1, floor((usable_h - knurl_ring_height)/knurl_pitch) + 1);
        z0       = -length/2 + chamfer_height + knurl_ring_height/2;

        for (i = [0:n_rings-1]) {
            zi = z0 + i*knurl_pitch;
            if (zi <= (length/2 - chamfer_height - knurl_ring_height/2 + 1e-9))
                translate([0, 0, zi])
                    cylinder(h=knurl_ring_height, r=outer_r + knurl_depth, center=true);
        }
    }
}

module internal_bore_core() {
    // Core bore to minor diameter
    cylinder(h=length + 2*eps, r=thread_minor_r, center=true);
}

module internal_thread_cut() {
    // Helical V-thread relief: subtract a helical "wedge" that intersects the bore wall.
    // Use a 2D profile in XY (not a degenerate line) so it renders clearly in orthographic views.
    turns     = (length + 2*eps) / thread_pitch;
    twist_deg = 360 * turns;

    // Profile dimensions (in XY)
    tooth_w = thread_pitch * 0.55;     // tangential width of the cut
    tooth_h = thread_depth;            // radial height of the cut

    // Place the profile so it straddles the bore wall:
    // inner edge slightly inside minor radius, outer edge slightly outside.
    r_in  = max(0.01, thread_minor_r - tooth_h*0.15);
    r_out = thread_minor_r + tooth_h*1.05;

    translate([0, 0, -(length/2 + eps)])
        linear_extrude(
            height    = length + 2*eps,
            twist     = twist_deg,
            slices    = max(ceil(turns * 80), 120),
            convexity = 10
        )
            polygon(points=[
                [r_in,  -tooth_w/2],
                [r_out,  0],
                [r_in,   tooth_w/2]
            ]);
}

// --- Final model (ONE connected solid) ---
difference() {
    external_body();
    internal_bore_core();
    internal_thread_cut();
}