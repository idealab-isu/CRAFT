// Pan head screw (single connected solid)
// Target: 4.0mm shank diameter, 7.8mm head diameter, 3.3mm head height, 10mm long (under head)

shaft_diameter_mm = 4.0;   //[2:8:0.1]
head_diameter_mm  = 7.8;   //[3.9:15.6:0.1]
head_height_mm    = 3.3;   //[1.65:6.6:0.1]
length_mm         = 10.0;  //[5:20:0.5]

// Optional simple thread look (kept subtle; still one solid)
thread_pitch_mm   = 0.8;   //[0.4:1.5:0.05]
thread_depth_mm   = 0.25;  //[0:0.6:0.05]  // set to 0 for smooth shank

tip_length_mm     = 1.2;   //[0.6:2.4:0.1]

// Use 1–2mm overlap to guarantee watertight connections
overlap_mm        = 1.2;   //[1:2:0.1]
$fn = 128;

module helical_ridge(r_base, ridge_r, pitch, turns, z0, slices_per_turn=28) {
    // Thin helical ridge (visual thread). Always connected to shank by overlap.
    steps = max(10, ceil(turns * slices_per_turn));
    for (i = [0:steps-1]) {
        a1 = 360 * (i/steps) * turns;
        a2 = 360 * ((i+1)/steps) * turns;
        z1 = z0 + pitch * (i/steps) * turns;
        z2 = z0 + pitch * ((i+1)/steps) * turns;

        hull() {
            translate([r_base*cos(a1), r_base*sin(a1), z1])
                sphere(r=ridge_r, $fn=24);
            translate([r_base*cos(a2), r_base*sin(a2), z2])
                sphere(r=ridge_r, $fn=24);
        }
    }
}

module pan_head_screw() {
    r_shaft = shaft_diameter_mm/2;
    r_head  = head_diameter_mm/2;

    // Head on Z=[0..head_height], shank on Z=[-length..0], tip below shank.
    // Critical connectivity fix: make the tip start BELOW the shank end by overlap_mm
    // so it intersects the shank (no gap / no floating).
    union() {
        // Shank (under head) - overlaps into head by overlap_mm
        translate([0, 0, -length_mm])
            cylinder(h=length_mm + overlap_mm, r=r_shaft, center=false);

        // Tip (simple cone) - MUST overlap into shank by overlap_mm
        // Shank bottom is at Z = -length_mm.
        // Tip top is at Z = (-length_mm) + overlap_mm (inside shank).
        translate([0, 0, -length_mm - tip_length_mm])
            cylinder(h=tip_length_mm + overlap_mm, r1=r_shaft, r2=0, center=false);

        // Pan head: cylindrical skirt + rounded dome
        skirt_h = head_height_mm * 0.60;
        dome_h  = head_height_mm - skirt_h;

        // Skirt (starts slightly below Z=0 to guarantee connection to shank)
        translate([0, 0, -overlap_mm])
            cylinder(h=skirt_h + overlap_mm, r=r_head, center=false);

        // Dome: intersection of a scaled sphere with a bounding cylinder to keep pan-head profile
        // Also overlaps slightly into skirt by starting at (skirt_h - overlap_mm)
        translate([0, 0, skirt_h - overlap_mm])
            intersection() {
                // Scaled sphere creates the rounded top
                scale([r_head, r_head, dome_h + overlap_mm])
                    sphere(r=1, $fn=96);
                // Limit to the dome height above skirt (with overlap)
                cylinder(h=dome_h + overlap_mm, r=r_head, center=false);
            }

        // Optional helical ridge to suggest threads (kept connected to shank)
        if (thread_depth_mm > 0) {
            z_start = -length_mm + tip_length_mm*0.35;
            z_end   = 0 - overlap_mm*0.5;
            usable_h = max(0, z_end - z_start);
            usable_turns = usable_h / thread_pitch_mm;

            helical_ridge(
                r_base = r_shaft + thread_depth_mm*0.35,
                ridge_r = thread_depth_mm*0.55,
                pitch = thread_pitch_mm,
                turns = usable_turns,
                z0 = z_start,
                slices_per_turn = 30
            );
        }
    }
}

pan_head_screw();