// Socket Head Cap Screw (single connected solid)
// Target: shank Ø5.0, head Ø8.5, head height 5.0, length under head 10.0

$fn = 128;

// Parameters (mm)
shank_diameter_mm     = 5.0;   // Ø shank (major)
length_under_head_mm  = 10.0;  // length under head
head_diameter_mm      = 8.5;   // Ø head
head_height_mm        = 5.0;   // head height

// Socket (Allen) recess (typical for M5: 4mm AF)
socket_af_mm          = 4.0;   // across flats
socket_depth_mm       = 3.0;   // depth

// Simple external thread approximation (visual)
thread_pitch_mm       = 0.8;   // M5 coarse pitch
thread_depth_mm       = 0.35;  // radial depth (visual)
thread_start_taper_mm = 1.0;   // taper at tip (visual)

// Small overlaps to ensure watertight unions/differences
eps = 0.03;

module hex_prism_af(af, h, center=false) {
    // For a regular hex: across flats = 2 * apothem = 2 * r * cos(30)
    // => r (circumradius) = (af/2) / cos(30)
    r = (af/2) / cos(30);
    cylinder(h=h, r=r, $fn=6, center=center);
}

module threaded_shank(major_d, len, pitch, depth, start_taper=1.0) {
    // Place with top at z=0 and extend down to z=-len
    // Major radius at crest:
    r_major = major_d/2;
    // Minor radius at root:
    r_minor = r_major - depth;

    // Helical ridge (triangular-ish) using linear_extrude with twist
    // Ridge is a thin wedge that protrudes from the minor cylinder to the major radius.
    turns = len / pitch;
    twist_deg = -360 * turns; // right-hand thread when viewed from top

    union() {
        // Core (minor diameter)
        translate([0,0,-len/2])
            cylinder(h=len, r=r_minor, center=true);

        // Helical ridge
        // Build a 2D wedge at +X and twist-extrude it along Z.
        // The wedge spans from r_minor to r_major.
        translate([0,0,-len])
            linear_extrude(height=len, twist=twist_deg, slices=max(ceil(turns*40), 80), convexity=10)
                polygon(points=[
                    [r_minor, -pitch*0.18],
                    [r_major,  0],
                    [r_minor,  pitch*0.18]
                ]);

        // Tip taper (slight chamfer/cone) to avoid a blunt end
        if (start_taper > 0) {
            taper_h = min(start_taper, len);
            translate([0,0,-len + taper_h/2])
                cylinder(h=taper_h, r1=r_minor, r2=r_minor*0.6, center=true);
        }
    }
}

module socket_head_cap_screw() {
    shank_r = shank_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Coordinate system:
    // underside of head at z=0
    // head spans z=[0, head_height]
    // shank spans z=[-length_under_head, 0]
    difference() {
        union() {
            // Threaded shank (connected to head at z=0 with overlap)
            translate([0,0,0])  // top of shank at z=0 by construction
                threaded_shank(
                    major_d = shank_diameter_mm,
                    len     = length_under_head_mm + eps,
                    pitch   = thread_pitch_mm,
                    depth   = thread_depth_mm,
                    start_taper = thread_start_taper_mm
                );

            // Head (slight overlap into shank to guarantee connectivity)
            translate([0, 0, head_height_mm/2 - eps/2])
                cylinder(h=head_height_mm + eps, r=head_r, center=true);
        }

        // Allen socket recess cut from top of head
        // Top of head at z=head_height_mm; recess extends down by socket_depth_mm
        translate([0, 0, head_height_mm - socket_depth_mm/2 + eps/2])
            hex_prism_af(socket_af_mm, socket_depth_mm + eps, center=true);

        // Small top chamfer inside socket (visual, keeps it clearly a recess)
        chamfer_h = 0.6;
        translate([0,0,head_height_mm - chamfer_h/2 + eps/2])
            cylinder(h=chamfer_h + eps,
                     r1=((socket_af_mm/2)/cos(30))*1.05,
                     r2=((socket_af_mm/2)/cos(30))*0.98,
                     $fn=6,
                     center=true);
    }
}

socket_head_cap_screw();