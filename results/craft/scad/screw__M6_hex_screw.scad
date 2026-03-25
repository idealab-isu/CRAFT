// Hex head screw (single connected solid)
// Requested: 6.0mm shank diameter, 11.5mm head diameter (across flats), head height 4.15mm, length 10mm

shaft_diameter_mm = 6.0;
head_diameter_mm  = 11.5;   // across flats
head_height_mm    = 4.15;
length_mm         = 10.0;   // under-head length

// Simple cosmetic thread parameters (kept within 6.0mm major diameter)
thread_pitch_mm   = 1.0;
thread_depth_mm   = 0.35;   // radial depth (major radius - minor radius)
thread_fn         = 80;
overlap_mm        = 0.05;

$fn = 96;

module threaded_shank(d=6, L=10, pitch=1.0, depth=0.35) {
    // Major radius = d/2, minor radius = d/2 - depth
    r_major = d/2;
    r_minor = max(0.01, r_major - depth);

    // Helical ridge via linear_extrude(twist=...)
    // Ridge is a thin rectangular strip placed at minor radius and extending to major radius.
    turns = L / pitch;
    twist_deg = 360 * turns;

    union() {
        // Core cylinder at minor diameter
        cylinder(h=L, r=r_minor, center=false, $fn=thread_fn);

        // Helical ridge
        linear_extrude(height=L, twist=twist_deg, slices=ceil(L*12), center=false, convexity=10)
            translate([r_minor, 0, 0])
                square([r_major - r_minor, pitch*0.55], center=false);
    }
}

module hex_head(af=11.5, h=4.15) {
    // For a hex made with $fn=6, OpenSCAD's cylinder r is circumradius.
    // Across flats (AF) = 2 * r * cos(30)  => r = AF / (2*cos(30))
    r_circ = (af/2) / cos(30);
    cylinder(h=h, r=r_circ, center=false, $fn=6);
}

module screw() {
    // Z=0 at tip, Z=length_mm at underside of head, head extends to Z=length_mm+head_height_mm
    union() {
        // Threaded shank
        threaded_shank(d=shaft_diameter_mm, L=length_mm, pitch=thread_pitch_mm, depth=thread_depth_mm);

        // Hex head (slight overlap to guarantee manifold union)
        translate([0, 0, length_mm - overlap_mm])
            hex_head(af=head_diameter_mm, h=head_height_mm + overlap_mm);
    }
}

screw();