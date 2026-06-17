// Threaded heat-set insert (single connected solid)
// Target: 30.0mm OD, 25.0mm long, internal thread for 16.0mm screw

// Parameters
outer_diameter_mm = 30; //[15:60:0.5]
length_mm = 25; //[12.5:50:0.5]

screw_diameter_mm = 16; //[8:32:0.5]
internal_thread_pitch_mm = 2; //[1:4:0.25]

// Approx. ISO metric thread geometry (visual/printable representation)
thread_depth_factor = 0.613;          // ~0.613*p (approx. radial depth for ISO-like profile)
thread_clearance_mm = 0.25;           // extra clearance on major diameter for fit

// Heat-set insert exterior
external_knurl_depth_mm = 1.2; //[0.6:2.4:0.1]
rib_count = 24; //[8:64:1]
rib_width_mm = 2.5; //[1:6:0.1]
rib_height_mm = 18; //[8:24:0.5]

// Ends
end_chamfer_mm = 1.5; //[0.5:3:0.1]
lead_in_taper_length_mm = 3; //[1.5:6:0.25]

// Robust boolean overlap
overlap_mm = 0.6; //[0.5:2:0.1]

// Quality
$fn = 128;

// ---------- Helpers ----------
function clamp(x, a, b) = min(max(x, a), b);

module internal_thread_cut(d_major, pitch, h, leadin_len, chamfer) {
    // Subtractive internal thread + bore + lead-ins.
    // IMPORTANT: keep all subtractive geometry strictly within the insert length
    // to avoid coincident/degenerate booleans that can yield "blank" renders.

    depth = thread_depth_factor * pitch;                 // radial thread depth
    d_minor = d_major - 2*depth;                         // minor diameter
    d_minor = max(d_minor, d_major - 1.8*pitch);         // keep sane

    // Keep lead-in and chamfer within half-length
    leadin_len = clamp(leadin_len, 0, h/2 - 0.01);
    chamfer    = clamp(chamfer,    0, h/2 - 0.01);

    // Helical cut parameters
    turns = h / pitch;
    twist_deg = -360 * turns; // right-hand internal thread cut

    union() {
        // Core bore (through)
        cylinder(d=d_minor, h=h + 2*overlap_mm, center=true);

        // Helical thread groove cut (kept within length)
        linear_extrude(height=h + 2*overlap_mm, center=true, twist=twist_deg, slices=max(24, ceil(turns*32)))
            translate([d_major/2, 0, 0])
                polygon(points=[
                    [0, -pitch/2],
                    [-depth, 0],
                    [0,  pitch/2]
                ]);

        // Lead-in tapers (both ends), positioned by formulas from h and leadin_len
        if (leadin_len > 0) {
            translate([0, 0, -h/2 + leadin_len/2])
                cylinder(d1=d_major, d2=d_minor, h=leadin_len + 2*overlap_mm, center=true);

            translate([0, 0,  h/2 - leadin_len/2])
                cylinder(d1=d_minor, d2=d_major, h=leadin_len + 2*overlap_mm, center=true);
        }

        // Entry chamfers (both ends) on major diameter
        if (chamfer > 0) {
            translate([0, 0, -h/2 + chamfer/2])
                cylinder(d1=d_major, d2=max(0.01, d_major - 2*chamfer), h=chamfer + 2*overlap_mm, center=true);

            translate([0, 0,  h/2 - chamfer/2])
                cylinder(d1=max(0.01, d_major - 2*chamfer), d2=d_major, h=chamfer + 2*overlap_mm, center=true);
        }
    }
}

module threaded_insert() {
    // Derived internal thread diameters
    internal_major_d_mm = screw_diameter_mm + thread_clearance_mm;
    internal_major_d_mm = min(internal_major_d_mm, outer_diameter_mm - 2.0); // keep wall thickness
    internal_major_d_mm = max(internal_major_d_mm, 0.01);

    // Exterior rib placement
    rib_h = clamp(rib_height_mm, 0, max(0, length_mm - 2*end_chamfer_mm));
    rib_z_center = 0;

    difference() {
        union() {
            // Main body (exact OD and length)
            cylinder(d=outer_diameter_mm, h=length_mm, center=true);

            // Outside end chamfers (both ends), connected via overlap
            if (end_chamfer_mm > 0) {
                translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
                    cylinder(d1=outer_diameter_mm, d2=max(0.01, outer_diameter_mm - 2*end_chamfer_mm),
                             h=end_chamfer_mm + 2*overlap_mm, center=true);

                translate([0, 0,  length_mm/2 - end_chamfer_mm/2])
                    cylinder(d1=max(0.01, outer_diameter_mm - 2*end_chamfer_mm), d2=outer_diameter_mm,
                             h=end_chamfer_mm + 2*overlap_mm, center=true);
            }

            // Anti-rotation ribs / knurl-like features (protrude outward, connected by overlap)
            if (rib_h > 0 && external_knurl_depth_mm > 0 && rib_width_mm > 0 && rib_count > 0) {
                for (i = [0:rib_count-1]) {
                    rotate([0, 0, i*360/rib_count])
                        // Inner face overlaps into the body by overlap_mm to guarantee connectivity
                        translate([outer_diameter_mm/2 + external_knurl_depth_mm/2 - overlap_mm, 0, rib_z_center])
                            cube([external_knurl_depth_mm, rib_width_mm, rib_h], center=true);
                }
            }
        }

        // Internal threaded hole (subtract)
        internal_thread_cut(
            d_major   = internal_major_d_mm,
            pitch     = internal_thread_pitch_mm,
            h         = length_mm,
            leadin_len= lead_in_taper_length_mm,
            chamfer   = end_chamfer_mm
        );
    }
}

// Assembly
threaded_insert();