// M3x10 Pan Head Screw (single connected solid)

// Parameters (mm)
shaft_diameter_mm = 3.0;   // shank diameter
length_mm         = 10.0;  // under-head length
head_diameter_mm  = 5.4;   // head max diameter
head_height_mm    = 2.0;   // head height
overlap_mm        = 0.2;   // small overlap to guarantee watertight union
head_fillet_mm    = 0.6;   // pan-head edge rounding control

$fn = 96;

module pan_head_screw(
    d_shank = shaft_diameter_mm,
    L       = length_mm,
    d_head  = head_diameter_mm,
    h_head  = head_height_mm,
    fillet  = head_fillet_mm,
    ov      = overlap_mm
){
    r_shank = d_shank/2;
    r_head  = d_head/2;

    // Keep fillet within bounds
    fillet_r = min(fillet, r_head - r_shank);
    fillet_z = min(fillet, h_head);

    union() {
        // Shank: from z=0 down to z=-L
        translate([0,0,-L/2])
            cylinder(r=r_shank, h=L, center=true);

        // Pan head: from z=0 up to z=h_head, overlapping into shank by ov
        translate([0,0,-ov])
            rotate_extrude()
                polygon(points=[
                    [0, 0],
                    [r_head - fillet_r, 0],
                    [r_head, fillet_z],
                    [r_head, h_head + ov],
                    [0, h_head + ov]
                ]);
    }
}

pan_head_screw();