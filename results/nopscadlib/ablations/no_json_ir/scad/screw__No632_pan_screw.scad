$fn = 120;

// Pan head screw: shank Ø3.5, length 10; head Ø6.9, height 2.5
// Includes simple helical thread approximation and a shallow Phillips-like recess.

module helical_thread(d_major=3.5, length=10, pitch=0.7, depth=0.35) {
    // Approximate external thread using a twisted triangular rib
    turns = length / pitch;
    r_major = d_major/2;
    r_root  = r_major - depth;

    union() {
        // Root cylinder (minor diameter)
        cylinder(h=length, r=r_root, center=false);

        // Helical rib
        linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
            translate([r_root, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module pan_head(d_head=6.9, h_head=2.5, d_shank=3.5) {
    // Rounded/low dome pan head made by hulling two cylinders
    r_head = d_head/2;
    r_shank = d_shank/2;

    union() {
        hull() {
            // Base at underside of head
            cylinder(h=0.6, r=r_head, center=false);
            // Near top: slightly smaller to create dome
            translate([0, 0, h_head - 0.6])
                cylinder(h=0.6, r=r_head*0.82, center=false);
        }

        // Small fillet-like blend into shank
        hull() {
            cylinder(h=0.4, r=r_head*0.98, center=false);
            translate([0, 0, 0.4])
                cylinder(h=0.4, r=max(r_shank*1.05, r_head*0.55), center=false);
        }
    }
}

module phillips_recess(d=3.0, depth=1.0, arm_w=0.7) {
    // Simple cross recess (subtractive)
    union() {
        cylinder(d=d, h=depth, center=false);
        translate([-d/2, -arm_w/2, 0]) cube([d, arm_w, depth], center=false);
        translate([-arm_w/2, -d/2, 0]) cube([arm_w, d, depth], center=false);
    }
}

module pan_head_screw(d_shank=3.5, L=10, d_head=6.9, h_head=2.5) {
    // Overlap to guarantee physical connection (1–2mm)
    overlap = 1.5;

    // Place head so its underside intersects the TOP of the shank by 'overlap'
    head_z0 = L - overlap;          // underside of head
    head_h  = h_head + overlap;     // extend head downward by overlap so overall visible head height stays ~h_head

    // Extra bridge/neck to ensure robust union between thread geometry and head
    neck_h = overlap + 0.8;

    difference() {
        union() {
            // Threaded shank (base at z=0, top at z=L)
            helical_thread(d_major=d_shank, length=L, pitch=0.7, depth=0.35);

            // Neck/bridge overlaps both shank (below z=L) and head (above z=head_z0)
            translate([0, 0, L - overlap])
                cylinder(h=neck_h, d=d_shank*1.05, center=false);

            // Head: starts at head_z0 and extends upward; overlaps shank by 'overlap'
            translate([0, 0, head_z0])
                pan_head(d_head=d_head, h_head=head_h, d_shank=d_shank);
        }

        // Drive recess cut into the TOP of the head (ensure it stays within head volume)
        // Top of head is at z = head_z0 + head_h
        recess_depth = 1.0;
        translate([0, 0, (head_z0 + head_h) - recess_depth])
            phillips_recess(d=3.0, depth=recess_depth, arm_w=0.7);
    }
}

pan_head_screw(3.5, 10, 6.9, 2.5);