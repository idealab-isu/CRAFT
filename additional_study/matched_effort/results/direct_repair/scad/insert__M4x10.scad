$fn=128;

// Heat-set insert (simplified model)
// Outer: 10.0mm OD, 8.0mm long
// Internal thread: for 4.0mm screw (approx M4), modeled as helical cut

od = 10.0;
len = 8.0;

// Internal thread approximation (M4-ish)
thread_major_d = 4.0;      // nominal screw major diameter
thread_pitch   = 0.7;      // typical M4 coarse pitch
thread_depth   = 0.35;     // radial depth of thread cut (approx)
thread_clear   = 0.25;     // extra clearance on major diameter

// Lead-in chamfers
outer_chamfer = 0.6;
inner_chamfer = 0.5;

// Knurl-like shallow rings on outside (common for heat-set inserts)
ring_count = 10;
ring_depth = 0.35;
ring_width = len/(ring_count*2);

module helical_thread_cut(h, major_d, pitch, depth, clearance=0.0) {
    // Creates a helical "triangular" cutter that is subtracted from a pilot hole.
    // major_d: nominal major diameter of screw
    // depth: radial depth of thread profile
    // clearance: added to major diameter for easier fit
    turns = h / pitch;

    // Place the cutter around the major radius
    r_major = (major_d + clearance)/2;

    // 2D profile of cutter (in XY), centered near the major radius.
    // A small triangle that bites into the wall.
    profile = [
        [r_major - depth, -pitch*0.25],
        [r_major + depth*0.15, 0],
        [r_major - depth,  pitch*0.25]
    ];

    linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*60), 60), convexity=10)
        polygon(points=profile);
}

module insert_body() {
    // Base cylinder with slight end chamfers
    union() {
        // Main body
        cylinder(d=od, h=len);

        // Outer chamfers (add then later subtract to keep crisp? We'll just add frustums)
        translate([0,0,0])
            cylinder(d1=od-2*outer_chamfer, d2=od, h=outer_chamfer);
        translate([0,0,len-outer_chamfer])
            cylinder(d1=od, d2=od-2*outer_chamfer, h=outer_chamfer);
    }
}

module outer_rings() {
    // Subtractive shallow grooves to mimic knurl rings
    for (i=[0:ring_count-1]) {
        z0 = (i*2+1)*ring_width;
        translate([0,0,z0])
            cylinder(d=od+0.2, h=ring_width, center=false);
    }
}

module inner_bore_and_thread() {
    // Pilot bore slightly under major diameter; thread cutter will open it up
    pilot_d = thread_major_d - 2*thread_depth + thread_clear;
    pilot_d = max(pilot_d, 2.5);

    union() {
        // Straight pilot hole
        translate([0,0,-0.2])
            cylinder(d=pilot_d, h=len+0.4);

        // Inner chamfers
        translate([0,0,0])
            cylinder(d1=pilot_d+2*inner_chamfer, d2=pilot_d, h=inner_chamfer);
        translate([0,0,len-inner_chamfer])
            cylinder(d1=pilot_d, d2=pilot_d+2*inner_chamfer, h=inner_chamfer);

        // Helical thread cut
        translate([0,0,0])
            helical_thread_cut(len, thread_major_d, thread_pitch, thread_depth, thread_clear);
    }
}

difference() {
    // Outer body
    difference() {
        insert_body();
        // Ring grooves
        outer_rings();
    }

    // Internal bore + thread
    inner_bore_and_thread();
}