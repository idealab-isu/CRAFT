$fn = 128;

// Target dimensions (mm)
shaft_d = 3.0;
shaft_r = shaft_d/2;

length  = 10.0;   // under-head length
head_d  = 5.7;
head_r  = head_d/2;
head_h  = 1.65;

// Thread approximation (visual, not a standards-accurate profile)
thread_pitch = 0.6;     // mm
thread_depth = 0.18;    // radial depth (mm)
thread_len   = length;  // threaded along full shank

eps = 0.02;

module dome_head(head_r, head_h) {
    // Spherical cap with base radius=head_r and cap height=head_h
    // Sphere radius: R = (a^2 + h^2) / (2h)
    R = (head_r*head_r + head_h*head_h) / (2*head_h);

    // Sphere center relative to cap base plane at z=0:
    // center_z = h - R (negative)
    intersection() {
        translate([0,0,head_h - R]) sphere(r=R);
        // Keep only z in [0, head_h]
        translate([-2*head_r, -2*head_r, 0])
            cube([4*head_r, 4*head_r, head_h], center=false);
    }
}

module threaded_shank(r, h, pitch, depth) {
    // Base cylinder + helical ridge (triangular-ish) using linear_extrude twist
    union() {
        cylinder(h=h, r=r - depth);

        // Helical ridge
        linear_extrude(height=h, twist=360*h/pitch, slices=max(ceil(h*24), 120), convexity=10)
            translate([r - depth, 0, 0])
                polygon(points=[
                    [0, -pitch*0.18],
                    [depth, 0],
                    [0,  pitch*0.18]
                ]);
    }
}

module dome_head_screw() {
    union() {
        // Head sits at z in [0, head_h]
        dome_head(head_r=head_r, head_h=head_h);

        // Threaded shank starts slightly inside head to guarantee connectivity
        translate([0,0,head_h - eps])
            threaded_shank(r=shaft_r, h=length + eps, pitch=thread_pitch, depth=thread_depth);
    }
}

dome_head_screw();