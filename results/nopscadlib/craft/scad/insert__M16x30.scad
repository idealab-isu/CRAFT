// Threaded heat-set insert (single connected solid)
// Target: 30.0mm OD, 25.0mm long, through-hole for 16.0mm screws

$fn = 160;

// Parameters
outer_diameter_mm = 30; //[15:60:0.5]
length_mm = 25; //[12.5:50:0.5]
screw_diameter_mm = 16; //[8:32:0.5]
tolerance_clearance_mm = 0.2; //[0.05:0.6:0.05]

entry_chamfer_length_mm = 2.0; //[0.8:5:0.1]
tip_chamfer_length_mm   = 2.0; //[0.8:5:0.1]
bore_extra_length_mm    = 1.0; //[0.5:3.0:0.1]

knurl_depth_mm = 0.8; //[0.4:1.6:0.05]
knurl_pitch_mm = 1.6; //[0.8:3.2:0.1]
knurl_rib_width_mm = 0.8; //[0.4:1.6:0.05]
knurl_count = 14; //[6:40:1]

overlap_mm = 0.6; //[0.2:2.0:0.1]

// Internal thread (visual/approx) parameters
thread_pitch_mm = 2.0;          // coarse visual pitch
thread_depth_mm = 0.8;          // radial depth of thread profile
thread_profile_facets = 18;     // facets around each twist step

module internal_thread_cutter(h, r_minor, pitch, depth) {
    // Helical ridge to SUBTRACT from the bore (visual internal thread)
    turns = h / pitch;
    linear_extrude(
        height = h,
        twist = -360 * turns,
        slices = max(ceil(turns * thread_profile_facets), 24),
        convexity = 10
    )
        translate([r_minor, 0, 0])
            polygon(points=[
                [0, -pitch/4],
                [depth, 0],
                [0,  pitch/4]
            ]);
}

module threaded_insert() {
    outer_r = outer_diameter_mm/2;

    // Clearance bore for 16mm screw
    bore_r  = (screw_diameter_mm + tolerance_clearance_mm)/2;

    // Keep wall thickness sane
    min_wall = 1.2;
    bore_r_eff = min(bore_r, outer_r - min_wall);

    // Thread minor radius (slightly smaller than bore so thread cuts into bore wall)
    thread_minor_r = max(bore_r_eff - thread_depth_mm, 0.1);

    // Clamp chamfers so they never exceed radius
    entry_ch = min(entry_chamfer_length_mm, outer_r - 0.01);
    tip_ch   = min(tip_chamfer_length_mm,   outer_r - 0.01);

    // Axial extents (centered model)
    z_top =  length_mm/2;
    z_bot = -length_mm/2;

    // Knurl band extents (avoid chamfers)
    knurl_z0 = z_bot + tip_ch;
    knurl_z1 = z_top - entry_ch;
    knurl_h  = max(knurl_z1 - knurl_z0, 0);

    difference() {
        union() {
            // Main outer cylinder (exact OD and length)
            cylinder(r=outer_r, h=length_mm, center=true);

            // Entry chamfer (top) - connected via overlap
            translate([0, 0, z_top - entry_ch/2 + overlap_mm/2])
                cylinder(r1=outer_r, r2=max(outer_r - entry_ch, 0.01), h=entry_ch, center=true);

            // Tip chamfer (bottom) - connected via overlap
            translate([0, 0, z_bot + tip_ch/2 - overlap_mm/2])
                cylinder(r1=max(outer_r - tip_ch, 0.01), r2=outer_r, h=tip_ch, center=true);

            // Knurl ribs (raised rings) within knurl band
            if (knurl_h > 0) {
                for (i = [0:knurl_count-1]) {
                    z_i = knurl_z0 + (i + 0.5) * knurl_pitch_mm;
                    if (z_i <= knurl_z1)
                        translate([0, 0, z_i])
                            cylinder(r=outer_r, h=knurl_rib_width_mm, center=true);
                }
            }
        }

        // Knurl valley cutter (reduces between ribs)
        if (knurl_h > 0)
            translate([0, 0, (knurl_z0 + knurl_z1)/2])
                cylinder(r=max(outer_r - knurl_depth_mm, 0.01), h=knurl_h + overlap_mm, center=true);

        // Through bore (for 16mm screw clearance)
        cylinder(r=bore_r_eff, h=length_mm + bore_extra_length_mm, center=true);

        // Internal thread-like cutter (subtract helical ridge from bore)
        translate([0, 0, z_bot - bore_extra_length_mm/2])
            internal_thread_cutter(
                h = length_mm + bore_extra_length_mm,
                r_minor = thread_minor_r,
                pitch = thread_pitch_mm,
                depth = thread_depth_mm
            );
    }
}

threaded_insert();