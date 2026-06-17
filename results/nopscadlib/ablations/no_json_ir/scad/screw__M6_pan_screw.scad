$fn = 140;

// =====================
// Target dimensions (mm)
// =====================
shaft_diameter = 6.0;      // major diameter
shaft_length   = 10.0;     // under-head length
head_diameter  = 12.0;
head_height    = 4.75;

// =====================
// Visual thread (approx)
// =====================
thread_pitch   = 1.0;
thread_depth   = 0.45;     // radial ridge height
thread_start_z = 0.8;      // leave a small unthreaded tip region
thread_end_z   = shaft_length - 0.6;

// Tip
tip_len        = 1.2;

// Drive recess (simple Phillips-like cross)
drive_outer_d  = 6.0;
drive_depth    = 2.2;
drive_arm_w    = 1.4;
drive_arm_l    = drive_outer_d * 0.95;

// Small overlaps to ensure watertight union/difference
eps = 0.03;

// =====================
// Helpers
// =====================
module frustum(h, d1, d2) {
    cylinder(h=h, d1=d1, d2=d2, center=false);
}

// Helical thread ridge using linear_extrude with twist
module thread_ridge(major_d, pitch, depth, z0, z1) {
    h = max(0, z1 - z0);
    turns = (pitch > 0) ? (h / pitch) : 0;
    if (h > 0 && turns > 0) {
        translate([0,0,z0])
            linear_extrude(height=h, twist=turns*360, slices=max(36, ceil(turns*80)))
                translate([major_d/2 - depth/2, 0, 0])
                    circle(d=depth, $fn=48);
    }
}

// =====================
// Shaft with tip + threads
// Oriented along +Z so orthographic side views show the shank.
// =====================
module screw_shaft_with_threads() {
    union() {
        // Conical tip at bottom (z=0..tip_len)
        frustum(tip_len + eps,
                d1=max(0.2, (shaft_diameter - 2*thread_depth) * 0.15),
                d2=shaft_diameter - 2*thread_depth);

        // Main shank core (minor diameter) from tip to under-head
        translate([0,0,tip_len])
            cylinder(h=shaft_length - tip_len, d=shaft_diameter - 2*thread_depth, center=false);

        // Thread ridge (starts above tip)
        thread_ridge(shaft_diameter, thread_pitch, thread_depth,
                    max(thread_start_z, tip_len*0.6),
                    thread_end_z);
    }
}

// =====================
// Pan head (connected to shaft at z=shaft_length)
// =====================
module pan_head_solid() {
    // Head sits on top of shaft at z=shaft_length
    translate([0,0,shaft_length - eps])
    union() {
        skirt_h = head_height * 0.55;
        dome_h  = head_height - skirt_h;

        // Lower cylindrical skirt
        cylinder(h=skirt_h + eps, d=head_diameter, center=false);

        // Upper dome (gentle frustum)
        translate([0,0,skirt_h])
            frustum(dome_h, d1=head_diameter, d2=head_diameter*0.88);
    }
}

// =====================
// Phillips-like cross recess (subtractive), from top down
// =====================
module cross_recess() {
    z_top = shaft_length + head_height;

    // Cut from the top surface downward by drive_depth
    translate([0,0,z_top - drive_depth + eps])
    union() {
        cube([drive_arm_l, drive_arm_w, drive_depth + 2*eps], center=true);
        cube([drive_arm_w, drive_arm_l, drive_depth + 2*eps], center=true);
        cylinder(h=drive_depth + 2*eps, d=drive_outer_d*0.35, center=true);
    }
}

// =====================
// Complete screw model (ONE connected solid)
// =====================
module screw_model() {
    difference() {
        union() {
            screw_shaft_with_threads();
            pan_head_solid();
        }
        cross_recess();
    }
}

screw_model();