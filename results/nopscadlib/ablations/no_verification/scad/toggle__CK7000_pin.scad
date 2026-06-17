$fn = 64;

// Parameters
body_diameter_mm = 0.76; //[0.38:1.52:0.01]
overall_height_mm = 4.7; //[2.35:9.4:0.05]
body_height_mm = 3.8; //[1.9:7.6:0.05]
actuator_height_mm = 0.9; //[0.45:1.8:0.05]
base_flange_diameter_mm = 1; //[0.5:2:0.01]
base_flange_thickness_mm = 0.2; //[0.1:0.4:0.01]
connection_overlap_mm = 0.05; //[0.02:0.2:0.01]
toggle_ball_diameter_mm = 0.32; //[0.16:0.64:0.01]
lever_diameter_mm = 0.22; //[0.11:0.44:0.01]

// Derived (enforce exact overall height by adjusting body height if needed)
body_r = body_diameter_mm/2;
flange_r = base_flange_diameter_mm/2;
lever_r = lever_diameter_mm/2;
ball_r  = toggle_ball_diameter_mm/2;

effective_body_h = max(0.01, overall_height_mm - base_flange_thickness_mm - actuator_height_mm - toggle_ball_diameter_mm + 2*connection_overlap_mm);

// Toggle switch - one connected solid
module toggle() {
    union() {
        // Base flange (bottom)
        translate([0,0, base_flange_thickness_mm/2])
            cylinder(r=flange_r, h=base_flange_thickness_mm, center=true);

        // Cylindrical body (connected to flange with overlap)
        translate([0,0, base_flange_thickness_mm - connection_overlap_mm + effective_body_h/2])
            cylinder(r=body_r, h=effective_body_h, center=true);

        // Toggle lever (connected to body with overlap)
        translate([0,0,
            (base_flange_thickness_mm - connection_overlap_mm + effective_body_h) - connection_overlap_mm + actuator_height_mm/2
        ])
            cylinder(r=lever_r, h=actuator_height_mm, center=true);

        // Toggle tip ball (connected to lever with overlap)
        translate([0,0,
            (base_flange_thickness_mm - connection_overlap_mm + effective_body_h) - connection_overlap_mm + actuator_height_mm - connection_overlap_mm + ball_r
        ])
            sphere(r=ball_r);
    }
}

toggle();