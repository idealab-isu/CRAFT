// Pan head screw: 4.0mm shank dia, 7.8mm head dia, 3.3mm head height, 10mm long
// One connected solid. Pan head profile + Phillips recess + true helical cosmetic thread.

$fn = 128;

// --- Required dimensions ---
shaft_diameter_mm = 4.0;
head_diameter_mm  = 7.8;
head_height_mm    = 3.3;
length_mm         = 10.0;   // under-head length

// --- Detail controls ---
overlap_mm = 0.20;

// Thread (helical, cosmetic)
thread_pitch_mm = 0.8;
thread_depth_mm = 0.25;          // radial depth (major - minor)
thread_tooth_w_mm = 0.35;        // thickness of the ridge (tangential)
thread_start_offset_mm = 0.6;    // unthreaded near head
tip_chamfer_height_mm = 1.0;

// Under-head transition
under_head_fillet_height_mm = 0.7;

// Phillips recess (approx)
drive_depth_mm = head_height_mm * 0.55;
drive_radius_mm = (head_diameter_mm/2) * 0.55;
drive_slot_width_mm = 1.1;

// --- Helpers ---
module phillips_recess(depth, radius, slot_w) {
    // Cut volume (to be subtracted) from top surface downward
    union() {
        // conical pocket
        cylinder(h=depth + overlap_mm, r1=radius, r2=radius*0.55, center=false);

        // cross slots (slightly deeper)
        translate([0,0,-overlap_mm])
        union() {
            cube([2*radius*1.20, slot_w, depth + 2*overlap_mm], center=false);
            cube([slot_w, 2*radius*1.20, depth + 2*overlap_mm], center=false);
        }
    }
}

module pan_head_solid(head_d, head_h) {
    // Pan head: short cylindrical skirt + spherical cap
    head_r = head_d/2;

    dome_h  = head_h * 0.55;
    skirt_h = head_h - dome_h;

    // Sphere radius for cap: R = (a^2 + h^2)/(2h)
    a = head_r;
    h = dome_h;
    R = (a*a + h*h) / (2*h);

    union() {
        // skirt
        cylinder(h=skirt_h, r=head_r, center=false);

        // spherical cap
        translate([0,0,skirt_h])
        intersection() {
            translate([0,0,R - h]) sphere(r=R);
            cylinder(h=dome_h + overlap_mm, r=head_r, center=false);
        }
    }
}

module helical_thread_ridge(major_r, minor_r, pitch, z0, z1, tooth_w) {
    // Creates a continuous helical ridge by twisting a small rectangle around Z.
    // The ridge is centered at radius = (major+minor)/2 and spans radially to reach major/minor.
    turns = (z1 - z0) / pitch;
    mid_r = (major_r + minor_r) / 2;
    rad_w = max(major_r - minor_r, 0.01);

    translate([0,0,z0])
    linear_extrude(height=(z1 - z0), twist=360*turns, slices=max(ceil((z1 - z0) * 12), 60), convexity=10)
        translate([mid_r, 0, 0])
            square([rad_w, tooth_w], center=true);
}

module screw() {
    shank_r = shaft_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // z=0 at underside of head
    // shank extends to z=-length_mm
    // head extends to z=+head_height_mm

    minor_r = max(shank_r - thread_depth_mm, 0.05);

    // Thread extents (avoid head and tip)
    thread_z_top = -thread_start_offset_mm;
    thread_z_bot = -length_mm + tip_chamfer_height_mm;
    thread_len   = max(thread_z_top - thread_z_bot, 0);

    difference() {
        union() {
            // Shank core (minor diameter) - full length
            translate([0,0,-length_mm])
                cylinder(h=length_mm, r=minor_r, center=false);

            // Helical cosmetic thread ridge (continuous)
            if (thread_len > 0.01)
                helical_thread_ridge(
                    major_r = shank_r,
                    minor_r = minor_r,
                    pitch   = thread_pitch_mm,
                    z0      = thread_z_bot,
                    z1      = thread_z_top,
                    tooth_w = thread_tooth_w_mm
                );

            // Tip chamfer (connects to shank core)
            translate([0,0,-length_mm])
                cylinder(h=tip_chamfer_height_mm, r1=0.05, r2=minor_r, center=false);

            // Under-head transition (connects shank to head) with slight overlap
            translate([0,0,-under_head_fillet_height_mm + overlap_mm])
                cylinder(h=under_head_fillet_height_mm, r1=shank_r, r2=head_r, center=false);

            // Pan head (connected at z=0)
            pan_head_solid(head_diameter_mm, head_height_mm);
        }

        // Phillips recess cut from top (ensure it stays within head volume)
        translate([0,0,head_height_mm - drive_depth_mm])
            phillips_recess(drive_depth_mm, drive_radius_mm, drive_slot_width_mm);
    }
}

screw();