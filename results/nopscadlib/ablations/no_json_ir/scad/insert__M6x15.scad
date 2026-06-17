// Threaded heat-set insert
// Specs: 15.0mm OD, 12.0mm long, for 6.0mm screws (M6-ish)

outer_diameter = 15.0;
overall_length = 12.0;

inner_diameter = 6.0;      // nominal screw size
thread_pitch   = 1.0;      // typical M6 pitch
thread_depth   = 0.6;      // radial depth of internal thread groove (visual/functional)

lead_in_len    = 1.2;      // chamfer length at both ends
anti_rot_count = 6;
anti_rot_depth = 1.0;      // radial protrusion
anti_rot_width = 2.0;      // tangential width

$fn = 120;

// --- Helpers ---
module internal_thread_groove(d_minor, depth, pitch, len) {
    // Helical "cutter" subtracted from the bore.
    turns = len / pitch;
    cutter_thick = depth;
    cutter_w = pitch * 0.55;
    r_center = d_minor/2 + depth/2;

    translate([0,0,-len/2])
        linear_extrude(
            height=len,
            twist=turns*360,
            slices=max(ceil(turns*40), 80),
            convexity=10
        )
            translate([r_center, 0, 0])
                square([cutter_thick, cutter_w], center=true);
}

module anti_rotation_ribs(od, len, count, rib_depth, rib_w, lead_in) {
    // Ribs protrude outward and overlap into body slightly to ensure connectivity.
    overlap = 0.25;
    rib_len = max(len - 2*lead_in, len*0.6);

    for (i = [0:count-1]) {
        rotate([0,0,i*360/count])
            translate([od/2 + rib_depth/2 - overlap, 0, 0])
                cube([rib_depth, rib_w, rib_len], center=true);
    }
}

// --- Main model ---
module threaded_insert() {
    d_bore  = inner_diameter;
    d_minor = d_bore;

    union() {
        // Outer body with chamfers (additive), then subtract bore + thread groove
        difference() {
            union() {
                // Main cylinder
                cylinder(d=outer_diameter, h=overall_length, center=true);

                // Additive lead-in chamfers (avoid subtracting away the whole body)
                translate([0,0, overall_length/2 - lead_in_len/2])
                    cylinder(d1=outer_diameter - 2*lead_in_len, d2=outer_diameter,
                             h=lead_in_len, center=true);

                translate([0,0,-overall_length/2 + lead_in_len/2])
                    cylinder(d1=outer_diameter, d2=outer_diameter - 2*lead_in_len,
                             h=lead_in_len, center=true);
            }

            // Through bore (slightly extended to guarantee clean subtraction)
            cylinder(d=d_bore, h=overall_length + 0.6, center=true);

            // Internal thread groove (helical subtraction)
            internal_thread_groove(d_minor=d_minor, depth=thread_depth,
                                   pitch=thread_pitch, len=overall_length + 0.4);
        }

        // Anti-rotation ribs (connected via overlap)
        anti_rotation_ribs(od=outer_diameter, len=overall_length, count=anti_rot_count,
                           rib_depth=anti_rot_depth, rib_w=anti_rot_width, lead_in=lead_in_len);
    }
}

threaded_insert();