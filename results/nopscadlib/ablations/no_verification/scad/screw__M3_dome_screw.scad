// Dome head screw with threads
// Specs: 3.0mm major (shank/thread) diameter, 5.7mm head diameter,
//        head height 1.65mm, 10mm threaded length (under head)

$fn = 128;

// Parameters (mm)
major_d = 3.0;     // thread major diameter
length  = 10.0;    // under-head length

head_d  = 5.7;
head_h  = 1.65;

transition_h = 0.6;     // under-head blend height
overlap = 0.08;         // small overlap for manifold unions

// Thread parameters (simple ISO-like approximation)
pitch = 0.50;           // coarse for M3
minor_d = 2.55;         // approximate minor diameter for visual/printable thread
thread_start_taper = 1.0; // taper length at tip

module helical_thread(major_d, minor_d, pitch, len) {
    major_r = major_d/2;
    minor_r = minor_d/2;

    // Triangular thread profile in XZ plane, then twist-extruded along Z.
    // Profile spans one pitch in Z and reaches from minor_r to major_r in X.
    // Centered around z=0 so it repeats cleanly.
    thread_h = major_r - minor_r;

    linear_extrude(height=len, twist=360*len/pitch, slices=max(ceil(24*len/pitch), 60), convexity=10)
        polygon(points=[
            [minor_r, -pitch/2],
            [major_r,  0],
            [minor_r,  pitch/2]
        ]);
}

module dome_cap(head_d, head_h) {
    head_r = head_d/2;

    // Spherical cap with exact base radius=head_r and height=head_h
    R = (head_r*head_r + head_h*head_h) / (2*head_h);

    // Sphere center is above base plane by (R - head_h)
    translate([0, 0, (R - head_h)])
        intersection() {
            sphere(r=R);
            // Keep only z in [0, head_h]
            translate([0, 0, head_h/2])
                cube([head_d*3, head_d*3, head_h], center=true);
        }
}

module dome_head_screw() {
    major_r = major_d/2;
    minor_r = minor_d/2;
    head_r  = head_d/2;

    union() {
        // Thread core (minor diameter cylinder) from z=0..length
        cylinder(h=length, r=minor_r, center=false);

        // Helical thread ridge, connected and overlapping slightly into the core
        translate([0, 0, -overlap])
            helical_thread(major_d=major_d, minor_d=minor_d, pitch=pitch, len=length + overlap);

        // Tip taper (minor->major) to avoid abrupt start and ensure clean end
        // Placed at bottom, overlaps into thread/core
        translate([0, 0, 0])
            cylinder(h=thread_start_taper, r1=minor_r, r2=major_r, center=false);

        // Under-head transition (major -> head base), connected at z=length
        translate([0, 0, length - overlap])
            cylinder(h=transition_h + overlap, r1=major_r, r2=head_r, center=false);

        // Dome head (base at z=length, top at z=length+head_h), overlaps into transition
        translate([0, 0, length - overlap])
            dome_cap(head_d=head_d, head_h=head_h + overlap);
    }
}

dome_head_screw();