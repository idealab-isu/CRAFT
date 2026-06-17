$fn = 96;

// Target dimensions (mm)
shaft_d = 3.5;   // major diameter
head_d  = 7.0;   // head diameter
length  = 10.0;  // overall length (tip to top of head)

// Head proportions (pan head + drive)
head_h  = 2.6;
shaft_h = length - head_h;

// Thread approximation (visual, not ISO-accurate)
pitch = 0.8;                 // mm per turn
thread_depth = 0.35;         // radial depth (mm)
tip_h = 1.0;                 // pointed tip height (mm)
unthreaded_under_head = 0.4; // smooth section under head (mm)

eps = 0.02;

// Drive (Phillips-like cross)
drive_w = head_d * 0.18;
drive_l = head_d * 0.70;
drive_depth = head_h * 0.55;

module helical_thread(major_d, pitch, depth, h) {
    turns = h / pitch;
    r_major = major_d/2;
    r_base  = r_major - depth;

    // Ridge is built so its inner edge sits at r_base and outer edge reaches r_major
    linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
        translate([r_base, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

module screw() {
    difference() {
        union() {
            // --- Shaft core (minor diameter) + tip (connected) ---
            core_d = shaft_d - 2*thread_depth;
            core_h = max(shaft_h - tip_h, 0);

            if (core_h > 0)
                cylinder(d=core_d, h=core_h);

            // Tip cone starts exactly at end of core (or at 0 if core_h==0)
            translate([0,0,core_h])
                cylinder(d1=core_d, d2=0.6, h=tip_h);

            // --- Thread ridge (connected; starts after smooth section under head) ---
            thread_start_z = unthreaded_under_head;
            thread_h = max(shaft_h - thread_start_z, 0);

            if (thread_h > 0)
                translate([0,0,thread_start_z])
                    helical_thread(major_d=shaft_d, pitch=pitch, depth=thread_depth, h=thread_h);

            // --- Head (connected to shaft at z=shaft_h) ---
            translate([0,0,shaft_h])
            union() {
                cyl_h  = head_h * 0.55;
                dome_h = head_h - cyl_h;

                cylinder(d=head_d, h=cyl_h);

                // Dome cap: sphere scaled in Z so total head height equals head_h
                translate([0,0,cyl_h])
                    scale([1,1, dome_h/(head_d/2)])
                        sphere(d=head_d);
            }
        }

        // --- Phillips-like cross recess (centered in head, subtractive) ---
        // Place recess so its top is slightly below the head top to avoid breaking through.
        recess_top_z = shaft_h + head_h - eps;
        recess_z0 = recess_top_z - drive_depth;

        translate([0,0,recess_z0])
        union() {
            translate([-drive_l/2, -drive_w/2, 0])
                cube([drive_l, drive_w, drive_depth + 2*eps], center=false);

            rotate([0,0,90])
                translate([-drive_l/2, -drive_w/2, 0])
                    cube([drive_l, drive_w, drive_depth + 2*eps], center=false);
        }
    }
}

screw();