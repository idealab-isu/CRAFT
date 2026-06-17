$fn = 160;

// Threaded heat-set insert (simplified, renderable)
// OD: 12.0 mm, Length: 10.0 mm, for M5 screw (internal thread approximated)

od = 12.0;
len = 10.0;

// Typical M5 internal thread: major ~5.0, minor ~4.2
id_major = 5.0;
id_minor = 4.2;

// Heat-set inserts often have a lead-in and slight taper; keep subtle
taper = 0.3;          // mm reduction in OD at one end
chamfer = 0.6;        // mm chamfer height

// Knurl approximation
knurl_count = 28;
knurl_depth = 0.45;   // radial depth
knurl_pitch = 1.2;    // mm along Z between knurl "rings"
knurl_twist = 18;     // degrees twist per ring

module insert_body() {
    // Main body with slight taper and chamfers
    union() {
        // Tapered cylinder
        cylinder(h = len, r1 = od/2, r2 = (od/2 - taper));

        // Chamfer at top
        translate([0,0,len - chamfer])
            cylinder(h = chamfer, r1 = (od/2 - taper), r2 = (od/2 - taper - chamfer*0.6));

        // Chamfer at bottom
        cylinder(h = chamfer, r1 = (od/2), r2 = (od/2 - chamfer*0.6));
    }
}

module knurl_ridges() {
    // Create a set of twisted triangular ridges around the outside
    // by stacking thin rings of rotated wedges.
    rings = max(1, floor(len / knurl_pitch));
    ring_h = len / rings;

    for (i = [0:rings-1]) {
        z0 = i * ring_h;
        rot = i * knurl_twist;

        translate([0,0,z0])
        rotate([0,0,rot])
        for (k = [0:knurl_count-1]) {
            rotate([0,0,360*k/knurl_count])
            translate([od/2 - knurl_depth, 0, 0])
                linear_extrude(height = ring_h, center = false, convexity = 10)
                    polygon(points=[
                        [0, -0.35],
                        [knurl_depth, 0],
                        [0, 0.35]
                    ]);
        }
    }
}

module internal_thread_void() {
    // Approximate internal thread as a helical groove cut into a cylinder.
    // This is not a standards-accurate ISO thread, but visually/thread-like.
    pitch = 0.8;                 // M5 coarse pitch
    turns = len / pitch;
    groove_depth = 0.35;         // radial depth of groove
    groove_width = 0.55;         // tangential width of groove

    // Base bore to minor diameter
    cylinder(h = len + 0.2, r = id_minor/2, center = false);

    // Helical groove: twist an offset rectangle around the axis
    translate([0,0,-0.1])
    linear_extrude(height = len + 0.2, twist = -360*turns, slices = max(60, ceil(turns*80)), convexity = 10)
        translate([id_minor/2 - groove_depth, 0, 0])
            square([groove_depth + 0.02, groove_width], center = true);

    // Slight lead-in at top
    translate([0,0,len-1.0])
        cylinder(h = 1.2, r1 = id_major/2, r2 = id_minor/2);
}

difference() {
    union() {
        insert_body();
        // Add knurl ridges, then trim to OD envelope to keep clean
        intersection() {
            union() {
                insert_body();
                knurl_ridges();
            }
            cylinder(h = len, r1 = od/2, r2 = (od/2 - taper));
        }
    }
    internal_thread_void();
}