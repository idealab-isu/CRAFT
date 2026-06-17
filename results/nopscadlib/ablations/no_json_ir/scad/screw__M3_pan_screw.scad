// Pan head screw (connected solid) with simple external threads
// Dimensions: shank d=3.0mm, head d=5.4mm, head h=2.0mm, overall length=10mm

$fn = 96;

shaft_diameter = 3.0;
head_diameter  = 5.4;
head_height    = 2.0;
overall_length = 10.0;

shaft_length = overall_length - head_height;

// Thread parameters (approximate ISO M3-like)
thread_pitch = 0.5;          // mm per turn
thread_depth = 0.18;         // radial depth (kept small for robustness)
thread_turns = shaft_length / thread_pitch;

eps = 0.02;

// Helical thread ridge (triangular-ish section) wrapped around the shank
module external_thread(d_major, pitch, depth, length) {
    turns = length / pitch;

    // A small wedge placed at the major radius, then twisted along Z
    // Using linear_extrude(twist=...) to create a helical ridge.
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        translate([d_major/2 - depth, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

// Rounded pan head profile via rotate_extrude (no hex facets)
module pan_head(d, h) {
    r = d/2;

    // Profile points in (radius, z) plane; z from 0..h
    // Slight under-head fillet and domed top.
    rotate_extrude(convexity=10)
        polygon(points=[
            [0, 0],
            [r*0.55, 0],
            [r*0.92, h*0.18],
            [r,      h*0.55],
            [r*0.78, h*0.92],
            [r*0.35, h],
            [0, h]
        ]);
}

// Simple Phillips-like cross recess (subtracted) but kept shallow
module cross_recess(head_d, head_h) {
    recess_depth = head_h*0.55;
    slot_w = head_d*0.18;
    slot_l = head_d*0.70;

    translate([0, 0, head_h - recess_depth + eps])
        union() {
            cube([slot_l, slot_w, recess_depth + 2*eps], center=true);
            cube([slot_w, slot_l, recess_depth + 2*eps], center=true);
        }
}

module screw() {
    difference() {
        union() {
            // Shank core (minor diameter) to support the thread ridge
            d_minor = shaft_diameter - 2*thread_depth;
            cylinder(h=shaft_length, d=d_minor, center=false);

            // External thread ridge (adds up to major diameter)
            external_thread(shaft_diameter, thread_pitch, thread_depth, shaft_length);

            // Pan head sits on top of shank; slight overlap ensures watertight union
            translate([0, 0, shaft_length - eps])
                pan_head(head_diameter, head_height);
        }

        // Drive recess cut into head (kept within head volume)
        translate([0, 0, shaft_length - eps])
            cross_recess(head_diameter, head_height);
    }
}

screw();