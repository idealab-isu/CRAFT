// Pan head screw — shank Ø4.0, head Ø7.8, head height 3.3, length 10
// Coordinate system: Z=0 at underside of head; shank extends to -screw_L; head extends to +head_h

$fn = 128;

// ---------------- Parameters (mm) ----------------
shank_d = 4.0;
screw_L = 10.0;

head_d = 7.8;
head_h = 3.3;

// Pan head profile tuning (kept within head_h)
head_top_flat_h = 0.55;
head_crown_h    = head_h - head_top_flat_h;   // domed portion height
head_top_d      = head_d * 0.86;              // top diameter of crown (pan head taper)

// Underhead fillet (kept small so it doesn't exceed head diameter)
underhead_fillet_r = 0.35;

// Drive: Phillips-style cross recess (visual)
drive_depth = 1.7;
drive_w     = 1.05;
drive_len   = 5.2;
drive_tip_r = 0.35;
drive_taper = 0.35;

// Thread (visual approximation): helical ridge
thread_pitch = 0.7;
thread_depth = 0.22;     // radial height of ridge
thread_width = 0.35;     // ridge thickness (tangential)
thread_start_z = -0.15;  // start slightly under head
thread_end_z   = -screw_L + 0.9; // leave a small unthreaded tip region

// Tip
tip_len    = 0.9;
tip_flat_d = 0.6;

// Robust overlap
eps = 0.03;

// ---------------- Helpers ----------------
module rounded_slot_2d(len, w, r) {
    // 2D rounded rectangle centered at origin
    hull() {
        translate([ len/2 - r, 0]) circle(r=r);
        translate([-len/2 + r, 0]) circle(r=r);
    }
    // expand to width w (ensure r <= w/2)
    offset(delta=max(0, w/2 - r))
        hull() {
            translate([ len/2 - r, 0]) circle(r=r);
            translate([-len/2 + r, 0]) circle(r=r);
        }
}

module phillips_recess() {
    // Subtractive tapered cross; top of recess at z=head_h
    translate([0,0, head_h - drive_depth])
        linear_extrude(
            height = drive_depth + eps,
            center = false,
            scale  = (drive_len - drive_taper) / drive_len
        )
        union() {
            rounded_slot_2d(drive_len, drive_w, drive_tip_r);
            rotate(90) rounded_slot_2d(drive_len, drive_w, drive_tip_r);
        }
}

module shank_core() {
    // Shank from z=0 down to z=-screw_L
    translate([0,0, -screw_L/2])
        cylinder(h=screw_L + eps, r=shank_d/2, center=true);
}

module tip_solid() {
    // Conical tip with small flat, connected to shank end
    // Occupies z in [-screw_L, -screw_L + tip_len]
    union() {
        // cone
        translate([0,0, -screw_L + tip_len/2])
            cylinder(h=tip_len + eps, r1=shank_d/2, r2=tip_flat_d/2, center=true);
        // flat end disk (ensures non-zero end face)
        translate([0,0, -screw_L + eps/2])
            cylinder(h=eps, r=tip_flat_d/2, center=true);
    }
}

module pan_head_solid() {
    // Pan head: crowned frustum + top flat + underhead fillet
    union() {
        // Crowned portion (frustum), bottom at z=0, top at z=head_crown_h
        translate([0,0, head_crown_h/2])
            cylinder(h=head_crown_h + eps, r1=head_d/2, r2=head_top_d/2, center=true);

        // Top flat cap, from z=head_crown_h to z=head_h
        translate([0,0, head_crown_h + head_top_flat_h/2])
            cylinder(h=head_top_flat_h + eps, r=head_top_d/2, center=true);

        // Underhead fillet: quarter-round blended into shank, kept inside head diameter
        // Place so it intersects both head underside (z=0) and shank radius.
        // Use rotate_extrude of a circle whose center is at (shank_r + fillet_r, fillet_r)
        translate([0,0, 0])
            rotate_extrude()
                translate([shank_d/2 + underhead_fillet_r, underhead_fillet_r, 0])
                    circle(r=underhead_fillet_r);
    }
}

module thread_ridge() {
    // Helical ridge around shank (visual thread)
    thread_h = max(0, thread_start_z - thread_end_z); // positive height
    turns = thread_h / thread_pitch;

    if (thread_h > 0.001) {
        translate([0,0, thread_end_z])
            linear_extrude(
                height = thread_h,
                twist  = turns * 360,
                slices = max(ceil(turns * 80), 120),
                center = false
            )
            // Place ridge at shank surface; square is [tangential x radial]
            translate([shank_d/2 - thread_depth/2, 0, 0])
                square([thread_depth, thread_width], center=true);
    }
}

module screw_body() {
    // One connected solid: head + shank + thread ridge + tip
    union() {
        pan_head_solid();
        shank_core();
        thread_ridge();
        tip_solid();
    }
}

module final_screw() {
    difference() {
        screw_body();
        phillips_recess();
    }
}

// Output
color("DimGray") final_screw();