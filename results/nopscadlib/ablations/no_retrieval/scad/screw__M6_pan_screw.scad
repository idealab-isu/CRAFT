$fn = 160;

// Target dimensions (mm)
shank_d = 6.0;           // major diameter
screw_L = 10.0;          // length under head (z=0 down to z=-screw_L)
head_d  = 12.0;          // max head diameter
head_h  = 4.75;          // head height (z=0 up to z=head_h)

// Thread (visual, simplified ISO metric-like)
pitch = 1.0;             // coarse-ish for M6 visual
thread_depth = 0.55;     // radial depth (kept modest for robustness)
thread_start = 0.6;      // unthreaded length under head
thread_end_flat = 0.6;   // unthreaded at tip for chamfer/flat

// Pan head shaping
head_crown_h = 1.6;      // rounded crown height (within head_h)
underhead_fillet_r = 0.8;
tip_chamfer_h = 0.8;

// Simple Phillips-like cross recess (approx)
recess_depth = 2.0;
recess_w = 1.6;
recess_len = 7.0;
recess_taper = 0.4;

// Small overlap to guarantee watertight unions/differences
eps = 0.02;

module pan_head_solid() {
    // Head occupies z=[0, head_h]
    skirt_h = max(0.01, head_h - head_crown_h);

    union() {
        // Straight skirt
        translate([0,0,skirt_h/2 - eps])
            cylinder(h=skirt_h + 2*eps, r=head_d/2, center=true);

        // Crown frustum
        top_r = head_d/2 - head_crown_h*0.9;
        top_r = max(top_r, shank_d/2 + 0.6);

        translate([0,0,skirt_h - eps])
            cylinder(h=head_crown_h + 2*eps, r1=head_d/2, r2=top_r, center=false);

        // Spherical cap blended on top
        cap_r = top_r + head_crown_h*0.9;
        translate([0,0,head_h - cap_r + eps])
            intersection() {
                sphere(r=cap_r);
                translate([0,0,cap_r/2])
                    cube([2*head_d, 2*head_d, cap_r], center=true);
            }
    }
}

module underhead_fillet() {
    // Quarter-round fillet between shank and head underside at z=0
    shank_r = shank_d/2;
    rotate_extrude()
        translate([shank_r + underhead_fillet_r, underhead_fillet_r, 0])
            circle(r=underhead_fillet_r);
}

module cross_recess() {
    // Cut from top down into head
    zc = head_h - recess_depth/2;
    h  = recess_depth + 2*eps;

    translate([0,0,zc])
        union() {
            linear_extrude(height=h, center=true,
                          scale=(recess_len - 2*recess_taper)/recess_len)
                square([recess_len, recess_w], center=true);

            rotate([0,0,90])
                linear_extrude(height=h, center=true,
                              scale=(recess_len - 2*recess_taper)/recess_len)
                    square([recess_len, recess_w], center=true);
        }
}

module tip_chamfer_cut() {
    // Subtractive chamfer at the very tip (near z=-screw_L)
    translate([0,0,-screw_L + tip_chamfer_h/2])
        cylinder(h=tip_chamfer_h + 2*eps,
                 r1=shank_d/2 + thread_depth,
                 r2=max(0.01, (shank_d/2 + thread_depth) - tip_chamfer_h),
                 center=true);
}

module threaded_shank_solid() {
    // One connected solid: core cylinder + helical ridge (visual thread)
    shank_r = shank_d/2;
    core_r  = max(0.01, shank_r - thread_depth);

    // Threaded region along z in [-screw_L + thread_end_flat, -thread_start]
    z_top = -thread_start;
    z_bot = -screw_L + thread_end_flat;
    thread_len = max(0.01, z_top - z_bot);

    union() {
        // Core (full length under head)
        translate([0,0,-screw_L/2])
            cylinder(h=screw_L, r=core_r, center=true);

        // Helical ridge (approx triangular section)
        if (thread_len > 0.02) {
            translate([0,0,z_bot])
                linear_extrude(height=thread_len,
                              twist=360*thread_len/pitch,
                              slices=max(24, ceil(thread_len*24)),
                              convexity=10)
                    polygon(points=[
                        [core_r, -pitch*0.22],
                        [shank_r, 0],
                        [core_r,  pitch*0.22]
                    ]);
        }

        // Small unthreaded collar under head to blend into fillet
        // (keeps thread from intersecting the underhead fillet too aggressively)
        collar_h = max(0.01, thread_start);
        translate([0,0,-collar_h/2])
            cylinder(h=collar_h + eps, r=shank_r, center=true);

        // Small unthreaded tip land
        tip_h = max(0.01, thread_end_flat);
        translate([0,0,-screw_L + tip_h/2])
            cylinder(h=tip_h + eps, r=shank_r, center=true);
    }
}

module screw() {
    difference() {
        union() {
            // Head above z=0
            pan_head_solid();

            // Shank below z=0 (connected at z=0)
            threaded_shank_solid();

            // Fillet bridges head underside to shank at z=0
            underhead_fillet();
        }

        // Subtractive features
        cross_recess();
        tip_chamfer_cut();
    }
}

color("Silver") screw();