// Threaded heat-set insert (visual internal thread + heat-set knurling)
// Target: 25.0mm OD, 18.5mm long, for 10.0mm screws

$fn = 160;

// Parameters
outer_diameter = 25.0;                 //[12.5:50:0.1]
length = 18.5;                         //[9.25:37:0.1]
screw_diameter = 10.0;                 //[5:20:0.1]
internal_thread_pitch = 1.5;           //[0.75:3:0.05]

// Internal thread (visual)
thread_depth = 0.75;                   //[0.2:1.2:0.05]   // radial depth of thread
thread_profile_w = 0.70;               //[0.2:1.2:0.05]   // width of triangular profile

// Bore (minor diameter) for M10-ish internal thread (approx)
pilot_hole_diameter = 8.5;             //[4.25:17:0.1]

// Lead-in / end chamfers
lead_in_chamfer_depth = 1.0;           //[0.5:2:0.1]
end_face_chamfer = 0.4;                //[0.15:0.8:0.05]

// Heat-set knurling / barbs
knurl_depth = 0.7;                     //[0.3:1.2:0.05]
knurl_band_length = 12.0;              //[6:24:0.5]
knurl_band_offset_from_lead = 2.0;     //[1:4:0.1]
knurl_teeth = 60;                      //[24:120:1]
knurl_tooth_w = 0.9;                   //[0.4:2:0.05]

// Robustness
overlap = 0.8;                         //[0.5:2:0.1]
bore_extra_depth = 0.8;                //[0.2:1:0.1]
eps = 0.02;

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

// Helical "cutter" that is SUBTRACTED from the bore to show internal threading
module internal_thread_visual(minor_d, pitch, depth, len, profile_w) {
    minor_r = minor_d/2;
    turns = len / pitch;
    slices_per_turn = 48;
    twist_deg = -360 * turns;

    // Place the triangular profile so it intersects the bore wall:
    // - One edge at the bore radius (minor_r)
    // - Tip extends outward by 'depth' (so subtraction creates a groove)
    translate([0, 0, -len/2])
        linear_extrude(height=len, twist=twist_deg,
                       slices=max(ceil(turns*slices_per_turn), 24),
                       convexity=10)
            translate([minor_r, 0, 0])
                polygon(points=[
                    [0, -profile_w/2],
                    [0,  profile_w/2],
                    [depth, 0]
                ]);
}

// Knurl band: outward teeth that overlap into the base cylinder so it's one connected solid
module knurl_band(od, band_len, teeth, tooth_w, tooth_radial, z_center) {
    base_r = od/2;
    tooth_len = tooth_radial + overlap; // includes overlap into base
    translate([0, 0, z_center])
        for (i = [0:teeth-1]) {
            rotate([0, 0, i*360/teeth])
                translate([base_r + tooth_len/2 - overlap, 0, 0])
                    cube([tooth_len, tooth_w, band_len], center=true);
        }
}

module threaded_insert() {
    // Place knurl band from the lead-in end using formulas (no arbitrary offsets)
    knurl_zc_raw = -length/2 + knurl_band_offset_from_lead + knurl_band_length/2;
    knurl_zc = clamp(knurl_zc_raw,
                     -length/2 + knurl_band_length/2,
                      length/2 - knurl_band_length/2);

    // Keep thread within wall thickness
    wall_min = 1.6;
    max_thread_tip_r = outer_diameter/2 - wall_min;
    minor_r = pilot_hole_diameter/2;
    depth_limited = max(0.15, min(thread_depth, max_thread_tip_r - minor_r));

    // Thread length kept away from end chamfers
    thread_len = length - 2*(lead_in_chamfer_depth + end_face_chamfer);
    thread_len_safe = max(0.8, thread_len);

    // Ensure the thread cutter is centered within the insert
    thread_zc = 0;

    color("Brass")
    difference() {
        // ONE connected solid: body + knurl teeth + outer chamfers
        union() {
            // Main body
            cylinder(r=outer_diameter/2, h=length, center=true);

            // Knurl teeth
            knurl_band(outer_diameter, knurl_band_length, knurl_teeth,
                       knurl_tooth_w, knurl_depth, knurl_zc);

            // Outer lead-in chamfer (bottom)
            translate([0, 0, -length/2 + lead_in_chamfer_depth/2 - overlap/2])
                cylinder(r1=outer_diameter/2,
                         r2=outer_diameter/2 - lead_in_chamfer_depth,
                         h=lead_in_chamfer_depth + overlap, center=true);

            // Outer end chamfer (top)
            translate([0, 0,  length/2 - end_face_chamfer/2 + overlap/2])
                cylinder(r1=outer_diameter/2,
                         r2=outer_diameter/2 - end_face_chamfer,
                         h=end_face_chamfer + overlap, center=true);
        }

        // Through bore (minor diameter)
        cylinder(r=pilot_hole_diameter/2, h=length + 2*bore_extra_depth, center=true);

        // Internal thread grooves (visual)
        translate([0, 0, thread_zc])
            internal_thread_visual(pilot_hole_diameter, internal_thread_pitch,
                                   depth_limited, thread_len_safe, thread_profile_w);

        // Internal lead-in chamfer (bottom)
        translate([0, 0, -length/2 + lead_in_chamfer_depth/2])
            cylinder(r1=pilot_hole_diameter/2 + lead_in_chamfer_depth,
                     r2=pilot_hole_diameter/2,
                     h=lead_in_chamfer_depth + eps, center=true);

        // Internal exit chamfer (top)
        translate([0, 0,  length/2 - end_face_chamfer/2])
            cylinder(r1=pilot_hole_diameter/2,
                     r2=pilot_hole_diameter/2 + end_face_chamfer,
                     h=end_face_chamfer + eps, center=true);
    }
}

// Assembly
threaded_insert();