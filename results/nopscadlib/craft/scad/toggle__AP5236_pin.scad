// Toggle switch (stylized) — 0.8mm body diameter, 4.7mm overall height
// One connected solid; all translations derived from dimensions.

body_diameter_mm = 0.8;        //[0.4:1.6:0.05]
overall_height_mm = 4.7;       //[2.35:9.4:0.1]

lever_height_mm = 1.35;        //[0.5:2.0:0.05]
lever_diameter_mm = 0.22;      //[0.1:0.4:0.01]

connect_overlap_mm = 0.06;     //[0.02:0.2:0.01]

// Proportions tuned to look like a small toggle: short body + collar + base + lever
collar_height_mm = 0.35;
collar_diameter_mm = 0.95;

base_flange_height_mm = 0.30;
base_flange_diameter_mm = 1.05;

lever_tip_ball_d_mm = 0.30;
lever_tilt_deg = 22;

$fn = 64;

module toggle_switch() {
    body_r   = body_diameter_mm/2;
    collar_r = collar_diameter_mm/2;
    flange_r = base_flange_diameter_mm/2;
    lever_r  = lever_diameter_mm/2;
    tip_r    = lever_tip_ball_d_mm/2;

    // Stack from Z=0 upward; guarantee exact overall height:
    // overall = flange_h + body_h + collar_h + lever_h - 2*overlap
    body_h = overall_height_mm
             - base_flange_height_mm
             - collar_height_mm
             - lever_height_mm
             + 2*connect_overlap_mm;

    // Prevent invalid geometry if parameters are edited
    body_h_final = max(body_h, 0.01);

    // Z references (all derived)
    z_flange_center = base_flange_height_mm/2;
    z_body_center   = base_flange_height_mm + body_h_final/2 - connect_overlap_mm;
    z_collar_center = base_flange_height_mm + body_h_final + collar_height_mm/2 - 2*connect_overlap_mm;

    // Lever base at top of collar, with overlap into collar
    z_lever_base = base_flange_height_mm + body_h_final + collar_height_mm - 2*connect_overlap_mm;

    union() {
        // Bottom flange
        translate([0, 0, z_flange_center])
            cylinder(h=base_flange_height_mm, r=flange_r, center=true);

        // Main body (shorter, toggle-like)
        translate([0, 0, z_body_center])
            cylinder(h=body_h_final, r=body_r, center=true);

        // Top collar
        translate([0, 0, z_collar_center])
            cylinder(h=collar_height_mm, r=collar_r, center=true);

        // Toggle lever (tilted), connected via overlap into collar
        translate([0, 0, z_lever_base])
            rotate([0, lever_tilt_deg, 0])
                translate([0, 0, lever_height_mm/2 - connect_overlap_mm/2])
                    cylinder(h=lever_height_mm, r=lever_r, center=true);

        // Lever tip knob
        translate([0, 0, z_lever_base])
            rotate([0, lever_tilt_deg, 0])
                translate([0, 0, lever_height_mm - tip_r])
                    sphere(r=tip_r);
    }
}

toggle_switch();