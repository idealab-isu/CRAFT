// Threaded heat-set insert (simplified) - 18mm OD, 16mm long, for 8mm screws

$fn = 160;

// Parameters
outer_diameter_mm = 18.0; //[9.0:36.0:0.1]
length_mm = 16.0; //[8.0:32.0:0.1]

screw_diameter_mm = 8.0; //[4.0:16.0:0.1]
internal_thread_pitch_mm = 1.25; //[0.6:2.5:0.05]

// Practical internal diameters (approx for M8x1.25)
thread_major_diameter_mm = screw_diameter_mm;          // ~8.0
thread_minor_diameter_mm = 6.8;                        // ~6.8 (tap drill-ish / minor)
thread_depth_mm = (thread_major_diameter_mm - thread_minor_diameter_mm)/2;

end_chamfer_mm = 0.8; //[0.4:1.6:0.05]
lead_in_taper_length_mm = 1.5; //[0.75:3.0:0.05]

knurl_depth_mm = 0.4; //[0.2:0.8:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]
rib_count = 12; //[6:24:1]
rib_width_mm = 1.0; //[0.5:2.0:0.05]
rib_height_mm = 12.0; //[6.0:24.0:0.1]

// Quality for thread approximation
thread_slices_per_turn = 24; // higher = smoother, slower

module internal_thread_cut(h, major_d, minor_d, pitch) {
    // Simple helical "thread" subtraction using linear_extrude twist.
    // This is not a standards-perfect profile, but creates a visible threaded hole.
    turns = h / pitch;
    twist_deg = -360 * turns;

    // 2D profile: a ring with a triangular notch that becomes a helical ridge after twisting.
    // Subtracting this from the bore yields a thread-like internal surface.
    linear_extrude(height=h, twist=twist_deg, slices=max(ceil(turns*thread_slices_per_turn), 12), convexity=10)
    difference() {
        circle(d=major_d);
        union() {
            circle(d=minor_d);
            // notch to create a thread flank
            // placed near the major radius so the twisted extrusion forms a helix
            translate([major_d/2 - thread_depth_mm*0.6, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [thread_depth_mm*1.2, 0],
                    [0,  pitch*0.22]
                ]);
        }
    }
}

module outer_body_with_knurls() {
    union() {
        // Main cylindrical body
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

        // Retention ribs/knurls protruding outward and connected to body
        // Inner face overlaps into the body by overlap_mm to ensure connectivity.
        for (i = [0:rib_count-1]) {
            rotate([0, 0, i*360/rib_count])
                translate([outer_diameter_mm/2 + knurl_depth_mm/2 - overlap_mm, 0, 0])
                    cube([knurl_depth_mm + 2*overlap_mm, rib_width_mm, rib_height_mm], center=true);
        }
    }
}

module threaded_insert() {
    color("Brass")
    difference() {
        // OUTER SOLID (with lead-in taper and end chamfers)
        union() {
            // Base body + knurls
            outer_body_with_knurls();

            // Lead-in taper added (not subtracted) to create a tapered end
            translate([0, 0, -length_mm/2 + lead_in_taper_length_mm/2])
                cylinder(h=lead_in_taper_length_mm,
                         r1=outer_diameter_mm/2,
                         r2=max(outer_diameter_mm/2 - 1.2, outer_diameter_mm/2*0.85),
                         center=true);

            // Small end chamfer rings (added) to visually break edges
            translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
                cylinder(h=end_chamfer_mm,
                         r1=outer_diameter_mm/2,
                         r2=outer_diameter_mm/2 - end_chamfer_mm,
                         center=true);

            translate([0, 0,  length_mm/2 - end_chamfer_mm/2])
                cylinder(h=end_chamfer_mm,
                         r1=outer_diameter_mm/2 - end_chamfer_mm,
                         r2=outer_diameter_mm/2,
                         center=true);
        }

        // INNER CUTS: bore + thread + entry chamfers
        union() {
            // Base bore (minor diameter) through
            cylinder(h=length_mm + 2*overlap_mm, d=thread_minor_diameter_mm, center=true);

            // Threaded region cut (slightly shorter than full length to keep end chamfers clean)
            thread_h = length_mm - 2*end_chamfer_mm;
            translate([0, 0, -thread_h/2])
                internal_thread_cut(h=thread_h,
                                    major_d=thread_major_diameter_mm,
                                    minor_d=thread_minor_diameter_mm,
                                    pitch=internal_thread_pitch_mm);

            // Bore lead-in chamfer (bottom)
            translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
                cylinder(h=end_chamfer_mm + overlap_mm,
                         d1=thread_major_diameter_mm + 2*end_chamfer_mm,
                         d2=thread_minor_diameter_mm,
                         center=true);

            // Bore chamfer (top)
            translate([0, 0,  length_mm/2 - end_chamfer_mm/2])
                cylinder(h=end_chamfer_mm + overlap_mm,
                         d1=thread_minor_diameter_mm,
                         d2=thread_major_diameter_mm + 2*end_chamfer_mm,
                         center=true);
        }
    }
}

// Assembly
threaded_insert();