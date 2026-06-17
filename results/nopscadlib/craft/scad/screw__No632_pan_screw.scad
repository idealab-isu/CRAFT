// Pan head screw (single connected solid)
// Requested: 3.5mm shank dia, 6.9mm head dia, head height 2.5mm, 10mm long

$fn = 96;

// Parameters
shaft_diameter_mm = 3.5;
length_mm         = 10;
head_diameter_mm  = 6.9;
head_height_mm    = 2.5;

// Small overlap to guarantee watertight union
overlap_mm = 0.05;

// Simple helical thread approximation (optional but visible)
thread_pitch_mm   = 0.7;   // coarse-ish for M3.5
thread_depth_mm   = 0.25;  // radial depth of thread ridge
thread_start_mm   = 0.6;   // unthreaded length under head
thread_end_mm     = 0.6;   // unthreaded at tip
thread_fn         = 18;    // facets around thread ridge

module pan_head_screw(
    d_shaft=shaft_diameter_mm,
    L=length_mm,
    d_head=head_diameter_mm,
    h_head=head_height_mm
){
    r_shaft = d_shaft/2;
    r_head  = d_head/2;

    // Coordinate system:
    // z=0 at underside of head (bearing surface)
    // head spans z=[0..h_head]
    // shank spans z=[- (L-h_head) .. 0]
    shank_len = L - h_head;

    // Pan head profile: cylindrical skirt + rounded dome (intersection with sphere)
    // Dome height chosen so total head height matches h_head.
    skirt_h = max(0.6, h_head * 0.45);
    dome_h  = h_head - skirt_h;

    // Sphere radius that yields a spherical cap of height dome_h on base radius r_head:
    // R = (a^2 + h^2) / (2h)
    R = (r_head*r_head + dome_h*dome_h) / (2*dome_h);

    union() {
        // Shank core (minor diameter base for thread)
        translate([0,0,-shank_len/2])
            cylinder(h=shank_len + overlap_mm, r=r_shaft - thread_depth_mm*0.6, center=true);

        // Thread ridge (helical) over most of shank
        thread_h = max(0, shank_len - thread_start_mm - thread_end_mm);
        if (thread_h > 0) {
            translate([0,0,-shank_len + thread_end_mm])
                linear_extrude(
                    height=thread_h,
                    twist=360 * (thread_h / thread_pitch_mm),
                    slices=max(20, ceil(thread_h*12)),
                    convexity=10
                )
                translate([r_shaft - thread_depth_mm*0.2, 0, 0])
                    circle(r=thread_depth_mm, $fn=thread_fn);
        }

        // Tip (slight chamfer)
        tip_h = min(1.0, shank_len*0.25);
        if (tip_h > 0) {
            translate([0,0,-shank_len])
                cylinder(h=tip_h + overlap_mm, r1=r_shaft - thread_depth_mm*0.6, r2=max(0.2, (r_shaft - thread_depth_mm*0.6)*0.6), center=false);
        }

        // Head skirt
        translate([0,0,skirt_h/2])
            cylinder(h=skirt_h + overlap_mm, r=r_head, center=true);

        // Head dome (spherical cap)
        // Place sphere center so cap base is at z=skirt_h and top at z=h_head
        // Sphere center z = skirt_h + (dome_h - R)
        intersection() {
            translate([0,0,skirt_h + (dome_h - R)])
                sphere(r=R);
            translate([0,0,skirt_h + dome_h/2])
                cylinder(h=dome_h + overlap_mm, r=r_head, center=true);
        }

        // Small under-head fillet (connect head to shank smoothly)
        fillet_h = 0.35;
        translate([0,0,fillet_h/2])
            cylinder(h=fillet_h + overlap_mm, r1=r_shaft, r2=r_head, center=true);
    }
}

pan_head_screw();