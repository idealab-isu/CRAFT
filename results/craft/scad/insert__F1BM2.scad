// Threaded heat-set insert (approximation)
// Target: 4.0mm OD, 3.6mm length, for M2 screws

$fn = 96;

// Parameters
screw_nominal_diameter_mm = 2.0; //[1.0:4.0:0.1]
outer_diameter_mm = 4.0;         //[2.0:8.0:0.1]
length_mm = 3.6;                 //[1.8:7.2:0.1]

// M2 internal thread approximation
thread_major_d_mm = 2.0;         // M2 major diameter
thread_pitch_mm   = 0.4;         // M2 coarse pitch
thread_depth_mm   = 0.18;        // radial depth (visual/approx)
thread_clearance_mm = 0.10;      // extra clearance for printable bore

// Knurl/serration approximation (not gear teeth)
knurl_count = 18;                //[8:36:1]
knurl_radial_height_mm = 0.18;   //[0.05:0.4:0.01]
knurl_tangential_width_mm = 0.35;//[0.15:0.8:0.01]
knurl_z_margin_mm = 0.35;        //[0.0:1.0:0.05]

// End chamfers
chamfer_mm = 0.35;               //[0.1:0.8:0.05]

// Robust overlap/epsilon
eps = 0.02;

// --- Helpers ---
module helical_thread_cut(major_d, pitch, depth, len, clearance=0.0) {
    // Creates a helical "V-ish" groove cutter to subtract from a cylindrical bore.
    // This is a visual/functional approximation, not a standards-accurate ISO profile.
    turns = len / pitch;
    steps = max(ceil(turns * 28), 60);

    // Cutter cross-section (2D) placed at radius = major/2, then twisted along Z.
    // Using a small trapezoid/triangle-like profile to avoid self-intersections.
    r0 = major_d/2 + clearance;
    w  = pitch * 0.55;                 // tangential width of groove
    d  = depth;                        // radial depth of groove

    translate([0,0,-len/2 - eps])
        linear_extrude(height=len + 2*eps, twist=turns*360, slices=steps, convexity=10)
            translate([r0, 0])
                polygon(points=[
                    [ 0,   -w/2],
                    [ d,    0  ],
                    [ 0,    w/2],
                    [-eps,  w/2],
                    [-eps, -w/2]
                ]);
}

module insert_body() {
    r_body = outer_diameter_mm/2;

    union() {
        // Main cylinder
        cylinder(r=r_body, h=length_mm, center=true);

        // Knurl ribs: shallow serrations that do NOT look like gear teeth
        knurl_h = max(length_mm - 2*knurl_z_margin_mm, length_mm*0.6);
        knurl_z0 = 0; // centered

        for (i = [0:knurl_count-1]) {
            rotate([0,0,i*360/knurl_count])
                translate([r_body - knurl_radial_height_mm/2, 0, knurl_z0])
                    cube([knurl_radial_height_mm, knurl_tangential_width_mm, knurl_h], center=true);
        }

        // End chamfers (simple conical frustums)
        // Top chamfer
        translate([0,0, length_mm/2 - chamfer_mm/2])
            cylinder(h=chamfer_mm, r1=r_body, r2=max(r_body - chamfer_mm, 0.01), center=true);

        // Bottom chamfer
        translate([0,0,-length_mm/2 + chamfer_mm/2])
            cylinder(h=chamfer_mm, r1=max(r_body - chamfer_mm, 0.01), r2=r_body, center=true);
    }
}

module threaded_insert() {
    r_body = outer_diameter_mm/2;

    // Bore sizing: keep a real round bore (not polygonal) and add helical groove
    // Minor diameter approx = major - 2*depth; add clearance for printability.
    minor_d = max(thread_major_d_mm - 2*thread_depth_mm, 0.5);
    bore_d  = minor_d + 2*thread_clearance_mm;

    difference() {
        color([0.8, 0.6, 0.2]) insert_body();

        // Round bore through
        cylinder(d=bore_d, h=length_mm + 2*eps, center=true);

        // Helical thread groove cut (subtract)
        // Use major diameter as reference radius for groove placement.
        helical_thread_cut(
            major_d = thread_major_d_mm,
            pitch   = thread_pitch_mm,
            depth   = thread_depth_mm,
            len     = length_mm + 0.2,
            clearance = thread_clearance_mm
        );
    }
}

// Assembly (single connected solid)
threaded_insert();