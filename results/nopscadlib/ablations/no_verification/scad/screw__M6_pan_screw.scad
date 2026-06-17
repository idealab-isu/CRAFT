// Pan head screw (single connected solid)
// Required: 6.0mm shaft diameter, 12.0mm head diameter, 4.75mm head height, 10mm length under head

$fn = 160;

// Parameters (mm)
shaft_diameter_mm     = 6.0;
length_under_head_mm  = 10.0;
head_diameter_mm      = 12.0;
head_height_mm        = 4.75;

// Thread (visual approximation; not ISO-accurate)
thread_pitch_mm       = 1.0;     // coarse-looking for M6-ish
thread_depth_mm       = 0.45;    // radial depth of thread ridge
thread_start_taper_mm = 1.2;     // taper at tip

// Drive recess (Phillips-like cross)
drive_socket_radius_factor = 0.52;
drive_socket_depth_factor  = 0.55;
drive_slot_width_mm        = 1.35;

// Small overlaps/tolerances
overlap_mm = 0.25;
eps_mm     = 0.02;

// Derived
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;

drive_r = head_r * drive_socket_radius_factor;
drive_h = head_height_mm * drive_socket_depth_factor;

// Coordinate system:
// underside of head at z=0
// head extends +Z to head_height_mm
// shaft extends -Z to -length_under_head_mm

module screw_core() {
    // Slight overlap into head to guarantee connectivity
    translate([0, 0, -(length_under_head_mm/2) + overlap_mm/2])
        cylinder(h=length_under_head_mm + overlap_mm, r=shaft_r - thread_depth_mm, center=true);
}

module thread_ridge() {
    // A helical ridge made by linear_extrude with twist.
    // It is unioned to the core to create visible threads.
    turns = length_under_head_mm / thread_pitch_mm;

    // Keep ridge within shaft OD
    ridge_r1 = max(shaft_r - thread_depth_mm, 0.01);
    ridge_r2 = shaft_r;

    // A thin radial "tooth" that becomes a helix when twisted
    tooth_w = max(thread_pitch_mm * 0.45, 0.35);

    translate([0, 0, -length_under_head_mm])
        linear_extrude(height=length_under_head_mm, twist=turns*360, slices=max(ceil(turns*40), 80), convexity=10)
            translate([ridge_r1, 0, 0])
                square([ridge_r2 - ridge_r1, tooth_w], center=false);
}

module thread_tip_taper() {
    // Taper the last part of the shaft to look like a screw tip
    // (still one connected solid)
    taper_h = min(thread_start_taper_mm, length_under_head_mm);
    translate([0, 0, -length_under_head_mm + taper_h/2])
        cylinder(h=taper_h + eps_mm, r1=shaft_r, r2=max(shaft_r*0.35, 0.6), center=true);
}

module screw_shaft_threaded() {
    union() {
        // Core + ridge + tip taper
        screw_core();
        // Ridge overlaps slightly into core by being placed at ridge_r1
        thread_ridge();
        thread_tip_taper();
    }
}

// Pan head: rounded top with a short cylindrical skirt and a filleted transition
module pan_head() {
    // Build a 2D profile and rotate_extrude for a true pan-head silhouette.
    // Profile is defined in (radius, z) plane.
    skirt_h = head_height_mm * 0.45;                 // cylindrical-ish lower portion
    dome_h  = head_height_mm - skirt_h;              // rounded upper portion
    fillet_r = min(0.9, dome_h * 0.9);               // small fillet at the shoulder

    rotate_extrude(convexity=10)
        union() {
            // Main skirt rectangle
            polygon(points=[
                [0, 0],
                [head_r, 0],
                [head_r, skirt_h],
                [0, skirt_h]
            ]);

            // Shoulder fillet (quarter circle) to soften transition into dome
            translate([head_r - fillet_r, skirt_h])
                intersection() {
                    circle(r=fillet_r);
                    square([fillet_r, fillet_r], center=false);
                }

            // Dome: circular arc that reaches the top at z=head_height_mm
            // Use a circle whose center is above the skirt to create a convex dome.
            dome_R = head_r * 0.95;
            dome_cz = head_height_mm - dome_R * 0.55;

            intersection() {
                // Limit to the dome region above skirt_h
                translate([0, skirt_h])
                    square([head_r + eps_mm, head_height_mm - skirt_h + eps_mm], center=false);

                // Circle defining dome curvature
                translate([0, dome_cz])
                    circle(r=dome_R);
            }
        }
}

// Cross recess cut into top of head
module head_drive_recess() {
    // Recess starts at top surface and goes down by drive_h
    z_center = head_height_mm - drive_h/2;

    intersection() {
        translate([0, 0, z_center])
            cylinder(h=drive_h + 2*eps_mm, r=drive_r, center=true);

        union() {
            translate([0, 0, z_center])
                cube([2*drive_r + 2*eps_mm, drive_slot_width_mm, drive_h + 2*eps_mm], center=true);
            translate([0, 0, z_center])
                cube([drive_slot_width_mm, 2*drive_r + 2*eps_mm, drive_h + 2*eps_mm], center=true);
        }
    }
}

module pan_head_screw() {
    difference() {
        union() {
            // Head sits on z=[0..head_height_mm]
            pan_head();

            // Shaft attaches at underside of head (z=0) and extends to -length_under_head_mm
            // Overlap slightly into head to ensure one connected solid
            translate([0, 0, overlap_mm])
                screw_shaft_threaded();
        }
        head_drive_recess();
    }
}

pan_head_screw();