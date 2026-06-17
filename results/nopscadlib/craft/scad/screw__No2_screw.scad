// Pan head screw (single connected solid)
// Target: shaft Ø2.2mm, head Ø4.2mm, head height 1.7mm, total length 10mm

$fn = 96;

// Parameters
shaft_diameter = 2.2;
shaft_radius   = shaft_diameter/2;

length         = 10;

head_diameter  = 4.2;
head_radius    = head_diameter/2;
head_height    = 1.7;

// Thread approximation (visual)
thread_pitch   = 0.55;   // mm
thread_depth   = 0.18;   // mm (radial)
thread_len     = length - head_height; // threaded shank length

// Small overlap to guarantee manifold union
overlap = 0.15;

// Pan head profile controls
head_top_flat_r = head_radius * 0.55;  // small flat on top
head_fillet_r   = 0.35;               // rounding at head/shank junction

module pan_head_screw() {
    union() {
        // Shank core (cylindrical)
        translate([0,0,0])
            cylinder(h=thread_len + overlap, r=shaft_radius, center=false);

        // Approximate external thread as a helical ridge (unioned, not subtracted)
        // Keeps model one connected solid and visually threaded.
        translate([0,0,0])
            linear_extrude(height=thread_len, twist=360*(thread_len/thread_pitch), slices=max(40, ceil(thread_len*12)))
                translate([shaft_radius - thread_depth, 0, 0])
                    circle(r=thread_depth, $fn=24);

        // Pan head (rounded dome-ish) built from hull of two cylinders
        // Bottom of head starts at z=thread_len and overlaps into shank.
        translate([0,0,thread_len - overlap])
            hull() {
                // Base ring (slightly larger than shank, helps fillet)
                cylinder(h=overlap + 0.01, r=max(shaft_radius + head_fillet_r, head_radius*0.75), center=false);

                // Main head body
                translate([0,0,head_height])
                    cylinder(h=0.01, r=head_top_flat_r, center=false);

                // Outer diameter control at head base
                translate([0,0,0.25*head_height])
                    cylinder(h=0.01, r=head_radius, center=false);
            }

        // Ensure exact head height and diameter with a gentle cap (adds material only)
        translate([0,0,thread_len - overlap])
            cylinder(h=head_height + overlap, r=head_radius, center=false);
    }
}

pan_head_screw();