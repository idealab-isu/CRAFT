// Pan head screw (single connected solid)
// Specs: 5.0mm shank diameter, 10.0mm head diameter, 3.95mm head height, 10.0mm length (under head)

shaft_diameter_mm = 5.0;
head_diameter_mm  = 10.0;
head_height_mm    = 3.95;
length_mm         = 10.0;

overlap_mm = 0.2;

$fn = 128;

// Helical thread approximation using linear_extrude(twist=...)
module threaded_shank(d_major=5, L=10, pitch=0.8, depth=0.35, ov=0.2) {
    r_major = d_major/2;
    r_minor = r_major - depth;

    // Ensure at least one full turn
    turns = max(1, L / pitch);

    // 2D profile in XY, then twist-extrude along Z
    // Profile is a ring sector with a small "tooth" bump to suggest threads.
    // This is a visual thread (not ISO-accurate), but produces visible helical ridges.
    linear_extrude(height=L + ov, twist=turns*360, slices=ceil(turns*60), convexity=10)
        difference() {
            // Base ring at minor diameter
            circle(r=r_minor);

            // Remove inner to keep it solid? (No removal; keep solid)
            // Instead, add tooth by union below (done by difference+union pattern)
        }

    // Add the helical ridge as a second twisted extrusion and union it with the core
    // (kept separate for clarity; caller unions both)
    // Ridge: a thin radial wedge from r_minor to r_major
    // Use a small angular width so it looks like a thread crest.
}

module thread_ridge(d_major=5, L=10, pitch=0.8, depth=0.35, crest_ang=22, ov=0.2) {
    r_major = d_major/2;
    r_minor = r_major - depth;
    turns = max(1, L / pitch);

    linear_extrude(height=L + ov, twist=turns*360, slices=ceil(turns*60), convexity=10)
        polygon(points=[
            [r_minor, 0],
            [r_major, 0],
            [r_major*cos(crest_ang), r_major*sin(crest_ang)],
            [r_minor*cos(crest_ang), r_minor*sin(crest_ang)]
        ]);
}

module pan_head(d_head=10, h_head=3.95, ov=0.2) {
    r_head = d_head/2;

    // Pan head: cylindrical skirt + spherical cap, flat underside at z=0
    intersection() {
        union() {
            // Skirt
            translate([0,0,h_head/2])
                cylinder(h=h_head + ov, r=r_head, center=true);

            // Rounded top (sphere centered so top reaches z=h_head)
            translate([0,0,h_head - r_head])
                sphere(r=r_head);
        }
        // Keep only z >= 0
        translate([0,0,(h_head + 2*r_head)/2])
            cube([2*d_head, 2*d_head, h_head + 2*r_head], center=true);
    }
}

module pan_head_screw(d_shaft=5, d_head=10, h_head=3.95, L=10, ov=0.2) {
    // Thread parameters (visual)
    pitch = 0.8;     // mm
    depth = 0.35;    // mm

    union() {
        // Head: bottom at z=0, top at z=h_head
        pan_head(d_head=d_head, h_head=h_head, ov=ov);

        // Threaded shank: from z=-L to z=0, connected with slight overlap into head
        translate([0,0,-L])
            union() {
                // Core at minor diameter
                cylinder(h=L + ov, r=(d_shaft/2 - depth), center=false);

                // Helical ridge (thread crest)
                thread_ridge(d_major=d_shaft, L=L, pitch=pitch, depth=depth, crest_ang=22, ov=ov);
            }

        // Small under-head fillet/transition (keeps silhouette and ensures robust connection)
        // Positioned to overlap both head underside and shank top.
        translate([0,0,0])
            cylinder(h=ov + 0.6, r1=d_head/2, r2=d_shaft/2, center=false);
    }
}

pan_head_screw(
    d_shaft=shaft_diameter_mm,
    d_head=head_diameter_mm,
    h_head=head_height_mm,
    L=length_mm,
    ov=overlap_mm
);