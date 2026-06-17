// Socket head cap screw (single connected solid)
// Requested: 3.0mm shank dia, 5.5mm head dia, 2.0mm head height, 10mm long

$fn = 96;

// Parameters (mm)
thread_major_diameter_mm = 3.0;
overall_length_mm        = 10.0;   // under-head length
head_diameter_mm         = 5.5;
head_height_mm           = 2.0;

// Socket (typical for M3 SHCS; adjustable)
socket_across_flats_mm   = 2.5;
socket_depth_mm          = 1.3;

// Small edge details
under_head_chamfer_h_mm  = 0.35;
tip_chamfer_h_mm         = 0.6;

// Structural overlap to guarantee connection (1–2mm as required)
overlap_mm               = 1.0;

module socket_head_cap_screw() {
    shank_r = thread_major_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // z=0 at underside of head; shank extends to negative z; head extends to positive z.
    difference() {
        union() {
            // Head: z = 0 .. +head_height
            translate([0,0, head_height_mm/2])
                cylinder(h=head_height_mm, r=head_r, center=true);

            // Shank: z = -overall_length .. +overlap (overlaps into head)
            translate([0,0, (-overall_length_mm + overlap_mm)/2])
                cylinder(h=overall_length_mm + overlap_mm, r=shank_r, center=true);

            // Under-head frustum/collar (FIXED): explicitly spans across z=0 and overlaps
            // Bottom at z = -(under_head_chamfer_h + overlap), top at z = +overlap
            // This guarantees it is fused to BOTH shank and head (no floating/disconnected collar).
            translate([0,0, (-under_head_chamfer_h_mm)/2])
                cylinder(h=under_head_chamfer_h_mm + 2*overlap_mm,
                         r1=shank_r,
                         r2=head_r,
                         center=true);

            // Tip chamfer: overlaps into shank by overlap_mm to avoid any seam
            // Tip region near z = -overall_length
            translate([0,0, -overall_length_mm + tip_chamfer_h_mm/2 + overlap_mm/2])
                cylinder(h=tip_chamfer_h_mm + overlap_mm,
                         r1=shank_r,
                         r2=max(shank_r - tip_chamfer_h_mm, shank_r*0.2),
                         center=true);
        }

        // Hex socket recess (cut into head from top), with slight extra depth to avoid coplanar artifacts
        socket_r = socket_across_flats_mm/(2*cos(30)); // across flats -> circumscribed radius
        translate([0,0, head_height_mm - socket_depth_mm/2 + 0.2])
            cylinder(h=socket_depth_mm + 0.4,
                     r=socket_r,
                     $fn=6,
                     center=true);
    }
}

socket_head_cap_screw();