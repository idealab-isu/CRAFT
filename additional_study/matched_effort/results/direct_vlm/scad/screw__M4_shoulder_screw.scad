$fn = 120;

// Dimensions (mm)
shaft_d = 5.0;
head_d  = 9.0;
head_h  = 2.4;
len     = 10.0;          // overall length (tip to top of head)

// Simple thread approximation
pitch        = 1.0;      // mm per turn
thread_depth = 0.35;     // radial depth
tip_h        = 1.2;      // pointed tip height

// Derived
shaft_r = shaft_d/2;
head_r  = head_d/2;

thread_r_outer = shaft_r;
thread_r_inner = max(0.1, shaft_r - thread_depth);

eps = 0.05;

// Length allocations along Z (tip at z=0, top of head at z=len)
thread_len = max(0, len - head_h - tip_h);  // straight threaded section length
z_tip0     = 0;
z_tip1     = tip_h;
z_thread0  = z_tip1 - eps;                  // overlap into tip
z_thread1  = z_tip1 + thread_len;
z_head0    = z_thread1 - eps;               // overlap into thread
z_head1    = z_head0 + head_h;              // should be ~= len

module helical_thread(len_h, pitch, r_outer, r_inner) {
    turns = len_h / pitch;
    linear_extrude(height=len_h, twist=turns*360, slices=max(40, ceil(turns*60)))
        difference() {
            circle(r=r_outer);
            circle(r=r_inner);
            // notch to create a single-start ridge (approx thread profile)
            translate([0, -r_outer*2]) square([r_outer*2, r_outer*4], center=false);
        }
}

union() {
    // Pointed tip (z=0..tip_h)
    cylinder(h=tip_h, r1=0.01, r2=thread_r_outer);

    // Threaded shaft (connected to tip and head)
    if (thread_len > 0)
        translate([0, 0, z_thread0])
            helical_thread(thread_len + 2*eps, pitch, thread_r_outer, thread_r_inner);

    // Head (connected to shaft)
    translate([0, 0, z_head0])
        cylinder(h=head_h + eps, r=head_r);
}