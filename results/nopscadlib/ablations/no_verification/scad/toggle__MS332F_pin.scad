// Toggle switch (miniature) - 1.0mm body diameter, 4.7mm overall height
// One connected solid, all placements derived from dimensions.

$fn = 96;

// Parameters
body_diameter_mm = 1.0;          //[0.5:2.0:0.05]
overall_height_mm = 4.7;         //[2.35:9.4:0.1]

// Visual proportions (kept small; overall height is enforced exactly)
base_flange_diameter_mm = 1.25;  //[0.6:2.4:0.05]
base_flange_thickness_mm = 0.25; //[0.1:0.6:0.01]

collar_diameter_mm = 0.85;       //[0.4:1.6:0.05]
collar_height_mm = 0.35;         //[0.1:1.0:0.05]

lever_diameter_mm = 0.28;        //[0.15:0.6:0.01]
tip_diameter_mm = 0.45;          //[0.2:0.9:0.01]

lever_tilt_deg = 18;             //[0:35:1]
lever_offset_mm = 0.18;          //[0:0.4:0.01]

overlap_mm = 0.06;               //[0.02:0.2:0.01]

// Derived dimensions (enforce exact overall height)
tip_r = tip_diameter_mm/2;
lever_h_eff = max(0.01, overall_height_mm - base_flange_thickness_mm - collar_height_mm - 2*tip_r);
body_height_mm = max(0.01, overall_height_mm - base_flange_thickness_mm - collar_height_mm - lever_h_eff - 2*tip_r);

// Z stack (bottom at z=0)
z_flange_top = base_flange_thickness_mm;
z_body_top   = z_flange_top + body_height_mm;
z_collar_top = z_body_top + collar_height_mm;
z_tip_bot    = z_collar_top + lever_h_eff;
z_tip_ctr    = z_tip_bot + tip_r;

module toggle_switch() {
    union() {
        // Base flange (disc)
        translate([0, 0, base_flange_thickness_mm/2])
            cylinder(h=base_flange_thickness_mm, r=base_flange_diameter_mm/2, center=true);

        // Switch body (1.0mm diameter)
        translate([0, 0, z_flange_top + body_height_mm/2 - overlap_mm])
            cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true);

        // Top collar/shoulder (suggests switch housing top)
        translate([0, 0, z_body_top + collar_height_mm/2 - overlap_mm])
            cylinder(h=collar_height_mm, r=collar_diameter_mm/2, center=true);

        // Toggle lever (tilted, connected into collar)
        translate([0, 0, z_collar_top - overlap_mm])
            rotate([0, lever_tilt_deg, 0])
                translate([lever_offset_mm, 0, lever_h_eff/2])
                    cylinder(h=lever_h_eff + 2*overlap_mm, r=lever_diameter_mm/2, center=true);

        // Rounded tip (ball) at lever end, kept within overall height
        translate([0, 0, z_collar_top - overlap_mm])
            rotate([0, lever_tilt_deg, 0])
                translate([lever_offset_mm, 0, lever_h_eff + tip_r - overlap_mm])
                    sphere(r=tip_r);
    }
}

toggle_switch();