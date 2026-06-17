$fn = 128;

// Parameters (mm)
shaft_d = 4.0;     // major diameter
length  = 10.0;    // under-head length

head_d  = 7.8;
head_h  = 3.3;

// Thread approximation (visual)
pitch = 0.7;                 // coarse-ish for ~M4
thread_depth = 0.35;         // radial depth (approx)
thread_len = length;         // threaded full length
tip_chamfer_h = 0.8;         // small lead-in

// Drive feature (Phillips-like cross recess)
drive_depth = 1.2;
drive_w = 1.2;
drive_l = 4.8;

// Small overlap to ensure watertight unions/differences
eps = 0.02;

module helical_thread(major_d, pitch, depth, len) {
    // Creates a helical ridge around a core cylinder.
    // Core radius is reduced so the ridge reaches major_d/2.
    major_r = major_d/2;
    core_r  = max(0.01, major_r - depth);

    union() {
        // Core
        cylinder(r=core_r, h=len);

        // Helical ridge (triangular-ish section)
        linear_extrude(height=len, twist=360*len/pitch, slices=max(24, ceil(len/pitch)*24), convexity=10)
            translate([core_r, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module pan_head(head_d, head_h) {
    // Pan head: short cylinder + rounded dome, total height = head_h
    base_h = head_h * 0.65;
    dome_h = head_h - base_h;

    union() {
        cylinder(d=head_d, h=base_h);

        translate([0,0,base_h - eps])
            intersection() {
                cylinder(d=head_d, h=dome_h + eps);
                // Sphere positioned so its cap forms the dome
                translate([0,0,0])
                    sphere(d=head_d);
            }
    }
}

module phillips_recess(head_d, depth, w, l) {
    // Simple cross recess (not a full Phillips geometry, but visible)
    // Centered on head top surface, cut downward.
    union() {
        cube([l, w, depth + eps], center=true);
        cube([w, l, depth + eps], center=true);
    }
}

module pan_head_screw(shaft_d, length, head_d, head_h) {
    major_r = shaft_d/2;

    difference() {
        union() {
            // Threaded shank with a small tip chamfer
            union() {
                helical_thread(shaft_d, pitch, thread_depth, thread_len);

                // Tip chamfer (reduces end sharpness)
                translate([0,0,0])
                    cylinder(h=tip_chamfer_h, r1=major_r*0.65, r2=max(0.01, major_r - thread_depth));
            }

            // Head connected at z=length (under-head length)
            translate([0,0,length - eps])
                pan_head(head_d, head_h);
        }

        // Drive recess cut from the top of the head
        translate([0,0,length + head_h - drive_depth/2 + eps])
            phillips_recess(head_d, drive_depth, drive_w, drive_l);
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);