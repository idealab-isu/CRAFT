$fn = 96;

// Target screw: dome head, M5 (5.0mm major dia), head Ø9.5, head height 2.75, length 10 (under-head)
thread_diameter = 5.0;
length = 10.0;                 // under-head length
head_diameter = 9.5;
head_height = 2.75;

// Thread approximation (visual)
thread_pitch = 0.8;            // typical M5 coarse
thread_depth = 0.35;           // radial depth (visual)
thread_segments = 18;          // smoothness of helix

// Overlap to ensure watertight union (1-2mm as required)
overlap = 1.0;

module dome_head_screw(d_major=5, L=10, hd=9.5, hh=2.75,
                       pitch=0.8, depth=0.35, segs=18) {

    r_major = d_major/2;
    r_minor = max(r_major - depth, 0.1);

    // Dome profile: spherical cap that meets the head cylinder at the top edge
    a = hd/2;
    h = hh;
    R = (a*a + h*h) / (2*h);
    zc = h - R;

    // Place head bottom at z=0, shaft extends to negative z.
    // Thread MUST be translated to start at z=-L and end at z=0 (with overlap into head).
    thread_h = L + overlap;          // extend slightly into head for guaranteed attachment
    thread_z0 = -L;                  // start at bottom of shank
    turns = L / pitch;
    twist_deg = -360 * turns;        // right-hand appearance

    union() {
        // Shaft core (minor diameter) - from z=-L to z=0, with slight overlap into head
        translate([0,0,-L/2])
            cylinder(h=L + overlap, r=r_minor, center=true);

        // Helical thread ridge (approx) around shaft
        // FIX: translate to z=-L so it wraps the shank instead of floating above.
        translate([0,0,thread_z0])
            linear_extrude(height=thread_h, twist=twist_deg,
                          slices=max(ceil(L*segs), 20), center=false)
                translate([r_minor - overlap/2, 0, 0])   // slight radial overlap into core
                    square([depth + overlap, pitch*0.45], center=true);

        // Head: cylindrical skirt + spherical cap, both starting at z=0
        skirt_h = min(0.35, hh*0.25);

        // Skirt overlaps downward into the shank to guarantee attachment
        translate([0,0,skirt_h/2 - overlap/2])
            cylinder(h=skirt_h + overlap, r=hd/2, center=true);

        // Spherical cap clipped to [0, hh], with a tiny downward overlap
        intersection() {
            translate([0,0,zc]) sphere(r=R);
            translate([0,0,hh/2 - overlap/2])
                cube([hd*2, hd*2, hh + overlap], center=true);
        }
    }
}

dome_head_screw(d_major=thread_diameter, L=length, hd=head_diameter, hh=head_height,
                pitch=thread_pitch, depth=thread_depth, segs=thread_segments);