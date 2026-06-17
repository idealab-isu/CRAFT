$fn = 128;

// Requested dimensions (mm)
shaft_diameter_mm = 4.2;
length_mm         = 10;     // under-head length
head_diameter_mm  = 8.2;
head_height_mm    = 3.05;

// Simple visual thread parameters (approximate, for appearance)
thread_pitch_mm   = 0.8;
thread_depth_mm   = 0.22;   // radial depth (kept small so major dia stays ~4.2)

// Pan head shaping
head_crown_h_mm   = 1.55;   // rounded crown height (part of head height)
head_skirt_h_mm   = head_height_mm - head_crown_h_mm; // straight skirt height

// Tip (machine screw style: flat/blunt with small chamfer, not pointed)
tip_chamfer_h_mm  = 0.6;

// Small overlap to ensure one connected solid
overlap_mm        = 0.08;

module pan_head_screw(
    d_shaft = shaft_diameter_mm,
    L = length_mm,
    d_head = head_diameter_mm,
    h_head = head_height_mm,
    pitch = thread_pitch_mm,
    depth = thread_depth_mm,
    crown_h = head_crown_h_mm,
    chamfer_h = tip_chamfer_h_mm,
    ov = overlap_mm
){
    r_major = d_shaft/2;
    r_minor = max(0.01, r_major - depth);

    // Derived head parts
    skirt_h = max(0, h_head - crown_h);
    crown_r = d_head/2;

    // Place underside of head at z=0, head above, shank below
    union() {
        // --- PAN HEAD (rounded dome + short cylindrical skirt) ---
        // Skirt (vertical side) to avoid "washer/cone" look
        if (skirt_h > 0)
            translate([0,0,skirt_h/2])
                cylinder(r=crown_r, h=skirt_h + ov, center=true);

        // Rounded crown: intersection of a sphere with a cylinder to keep diameter correct
        // Crown base sits at z=skirt_h, top at z=h_head
        translate([0,0,skirt_h])
        intersection() {
            // Cylinder bounds the crown to head diameter
            translate([0,0,crown_h/2])
                cylinder(r=crown_r, h=crown_h + ov, center=true);

            // Sphere creates the rounded top; center chosen so crown height matches
            // Sphere center at z=crown_h gives crown base at z=0 and top at z=2*crown_h
            translate([0,0,crown_h])
                sphere(r=crown_r);
        }

        // --- SHANK CORE (minor diameter) ---
        // Under-head length spans z in [-L, 0]
        translate([0,0,-L/2])
            cylinder(r=r_minor, h=L + ov, center=true);

        // --- VISUAL THREAD (helical ridge) ---
        turns = max(1, ceil(L/pitch));
        twist_deg = -turns * 360;

        // Start at z=-L and end at z=0 (slight overlap into head underside)
        translate([0,0,-L - ov/2])
            linear_extrude(height=L + ov, twist=twist_deg, slices=turns*28, convexity=10)
                translate([r_minor, 0, 0])
                    polygon(points=[
                        [0, -pitch*0.18],
                        [depth, 0],
                        [0,  pitch*0.18]
                    ]);

        // --- TIP (blunt end with small chamfer) ---
        // Flat end at z = -L - chamfer_h, with chamfer up to full major radius at z=-L
        translate([0,0,-L - chamfer_h/2])
            cylinder(r1=r_major*0.65, r2=r_major, h=chamfer_h + ov, center=true);

        // Small flat at very end to avoid a point
        flat_h = 0.25;
        translate([0,0,-L - chamfer_h - flat_h/2])
            cylinder(r=r_major*0.65, h=flat_h + ov, center=true);
    }
}

pan_head_screw();