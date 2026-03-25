$fn=128;

od = 15.0;
len = 12.0;

// For 6.0mm screws (approx M6 internal thread)
thread_major_d = 6.0;
thread_pitch = 1.0;
thread_depth = 0.35; // approximate
thread_minor_d = thread_major_d - 2*thread_depth;

lead_in = 1.0;
lead_out = 0.5;

knurl_count = 24;
knurl_depth = 0.6;

module helical_thread(d_major, d_minor, pitch, length, internal=true) {
    turns = length / pitch;
    steps_per_turn = 24;
    slices = max(12, ceil(turns * steps_per_turn));
    twist_deg = 360 * turns;

    r_major = d_major/2;
    r_minor = d_minor/2;
    h = pitch;

    // Triangular-ish thread profile in 2D (radial vs axial)
    // For internal thread, we subtract a ridge that reaches to major radius.
    // For external thread, we add it.
    module profile2d() {
        polygon(points=[
            [r_minor, 0],
            [r_major, h*0.5],
            [r_minor, h]
        ]);
    }

    if (internal) {
        linear_extrude(height=length, twist=twist_deg, slices=slices, convexity=10)
            profile2d();
    } else {
        linear_extrude(height=length, twist=twist_deg, slices=slices, convexity=10)
            profile2d();
    }
}

module knurled_shell(od, len, count, depth) {
    difference() {
        cylinder(d=od, h=len, center=true);
        for (i=[0:count-1]) {
            rotate([0,0, i*360/count])
                translate([od/2 - depth/2, 0, 0])
                    cube([depth, od*0.25, len+0.2], center=true);
        }
    }
}

module insert_body() {
    union() {
        knurled_shell(od, len, knurl_count, knurl_depth);

        // Small chamfers (approximated as cones) at ends
        translate([0,0, len/2 - lead_out/2])
            cylinder(d1=od-1.0, d2=od, h=lead_out, center=true);
        translate([0,0, -len/2 + lead_in/2])
            cylinder(d1=od, d2=od-1.0, h=lead_in, center=true);
    }
}

module heat_set_insert() {
    difference() {
        insert_body();

        // Core hole to minor diameter
        cylinder(d=thread_minor_d, h=len+0.6, center=true);

        // Internal thread cut (helical ridge subtraction)
        translate([0,0,-len/2])
            helical_thread(thread_major_d, thread_minor_d, thread_pitch, len, internal=true);

        // Lead-in taper for easier screw start
        translate([0,0,-len/2])
            cylinder(d1=thread_major_d+0.6, d2=thread_minor_d, h=lead_in, center=false);

        // Slight relief at far end
        translate([0,0, len/2 - lead_out])
            cylinder(d1=thread_minor_d, d2=thread_major_d, h=lead_out, center=false);
    }
}

heat_set_insert();