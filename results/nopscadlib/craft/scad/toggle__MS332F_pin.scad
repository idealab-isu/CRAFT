// Toggle switch (miniature) - ONE connected solid
// Target: 1.0mm body diameter, 4.7mm overall height

$fn = 96;

// Parameters
body_diameter_mm   = 1.0;   //[0.5:2.0:0.05]
overall_height_mm  = 4.7;   //[2.35:9.4:0.1]

// Proportions (kept parametric but constrained to match overall height)
body_height_mm     = 3.5;   //[1.75:7.0:0.1]
lever_height_mm    = overall_height_mm - body_height_mm;  // ensures exact overall height
lever_diameter_mm  = 0.35;  //[0.15:0.6:0.01]
lever_tip_d_mm     = 0.22;  //[0.10:0.5:0.01]
connect_overlap_mm = 0.20;  //[0.05:0.6:0.05]
toggle_angle_deg   = 18;    //[-30:30:1]

// Small collar
collar_h_mm        = 0.35;
collar_d_mm        = 0.70;

// Derived
body_r  = body_diameter_mm/2;
lever_r = lever_diameter_mm/2;

module toggle_switch() {
    union() {
        // Main cylindrical body: z = 0 .. body_height_mm
        translate([0, 0, body_height_mm/2])
            cylinder(h=body_height_mm, r=body_r, center=true);

        // Collar at top of body (overlaps slightly into body)
        translate([0, 0, body_height_mm - collar_h_mm/2 - connect_overlap_mm/2])
            cylinder(h=collar_h_mm + connect_overlap_mm, r=collar_d_mm/2, center=true);

        // Lever: rotate about the top of the body so it stays connected
        // Place lever so its bottom is slightly inside the collar/body (overlap)
        translate([0, 0, body_height_mm])
            rotate([toggle_angle_deg, 0, 0])
                translate([0, 0, lever_height_mm/2 - connect_overlap_mm/2])
                    cylinder(h=lever_height_mm + connect_overlap_mm,
                             r1=lever_r, r2=lever_tip_d_mm/2, center=true);
    }
}

toggle_switch();