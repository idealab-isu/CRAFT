// Standoff pillar: 4.0mm thread, 20.0mm long, 8.0mm diameter
// External M4 threaded section on one end + 8mm OD body.
// One connected solid; all translate() values derived from dimensions.

thread_diameter  = 4.0;   //[2.0:8.0:0.1]   // major diameter
outer_diameter   = 8.0;   //[4.0:16.0:0.1]  // body diameter
overall_length   = 20.0;  //[10.0:40.0:0.5]
threaded_length  = 20.0;  //[5.0:40.0:0.5]
overlap          = 0.5;   //[0.1:2.0:0.1]

// Visual thread parameters (approximate representation)
thread_pitch     = 0.8;   //[0.4:2.0:0.05]
thread_depth     = 0.35;  //[0.1:1.0:0.05]
$fn = 128;

module helical_external_thread(d_major, length, pitch, depth) {
    turns   = length / pitch;
    r_major = d_major / 2;
    r_root  = max(0.01, r_major - depth);

    union() {
        // Root cylinder (minor diameter)
        cylinder(h=length, r=r_root, center=true);

        // Helical ridge up to major diameter
        linear_extrude(height=length, twist=turns * 360, center=true, convexity=10)
            translate([r_root, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module standoff_pillar() {
    tlen = min(threaded_length, overall_length);
    body_len = overall_length - tlen;

    union() {
        // 8mm OD body section (if any), placed above the threaded section
        if (body_len > 0)
            translate([0, 0, (-overall_length/2) + tlen + body_len/2])
                cylinder(h=body_len, r=outer_diameter/2, center=true);

        // External M4 thread on the bottom end, with slight overlap into body for watertight union
        translate([0, 0, (-overall_length/2) + tlen/2])
            helical_external_thread(thread_diameter, tlen + 2*overlap, thread_pitch, thread_depth);
    }
}

standoff_pillar();