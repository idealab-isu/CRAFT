$fn = 120;

// Threaded heat-set insert (simplified) for M2.5 screw
// Overall: 4.0mm OD, 4.6mm length

od = 4.0;
len = 4.6;

// Typical M2.5 coarse pitch
pitch = 0.45;

// Internal thread (approx) for M2.5: minor diameter ~2.05-2.15mm; use 2.10mm
id_minor = 2.10;

// Thread depth (radial) approximation
thread_depth = 0.18;

// External knurl ring depth
knurl_depth = 0.18;
knurl_count = 7;

// Chamfers
chamfer = 0.35;

// Small overlap to ensure watertight unions/differences
eps = 0.02;

module helical_thread_internal(minor_d, depth, pitch, length) {
    // Robust internal-thread cutter using rotate_extrude with twist.
    // This avoids fragile hull-stepping that can produce empty/invalid geometry.
    r0 = minor_d/2;
    w  = pitch * 0.36; // thread flank width in Y

    // 2D wedge located at radius r0..r0+depth
    module ridge_profile_2d() {
        polygon(points=[
            [r0,        -w/2],
            [r0+depth,   0  ],
            [r0,         w/2]
        ]);
    }

    // Twist amount in degrees: 360 per pitch length
    linear_extrude(height=length, twist=360*length/pitch, slices=max(ceil(length/pitch*40), 80), convexity=10)
        ridge_profile_2d();
}

module insert_body() {
    union() {
        // Main body
        cylinder(d=od, h=len, center=false);

        // Bottom chamfer (expands to OD) - overlaps main body
        cylinder(d1=od-2*chamfer, d2=od, h=chamfer + eps, center=false);

        // Top chamfer (tapers down) - overlaps main body
        translate([0,0,len-chamfer-eps])
            cylinder(d1=od, d2=od-2*chamfer, h=chamfer + eps, center=false);

        // External knurl rings as thin collars that overlap the body
        ring_h = 0.22;
        for (i = [1:knurl_count]) {
            z = i*(len/(knurl_count+1));
            translate([0,0,z - ring_h/2])
                difference() {
                    cylinder(d=od + 2*knurl_depth, h=ring_h + eps, center=false);
                    translate([0,0,-eps])
                        cylinder(d=od, h=ring_h + 3*eps, center=false);
                }
        }
    }
}

difference() {
    insert_body();

    // Pilot hole through (slightly extended)
    translate([0,0,-eps])
        cylinder(d=id_minor, h=len + 2*eps, center=false);

    // Internal thread approximation (kept within length, no arbitrary offsets)
    translate([0,0,eps])
        helical_thread_internal(id_minor, thread_depth, pitch, len - 2*eps);

    // Slight countersink at top for screw start
    cs_h = 0.6;
    translate([0,0,len - cs_h - eps])
        cylinder(d1=id_minor, d2=id_minor + 0.8, h=cs_h + 2*eps, center=false);
}