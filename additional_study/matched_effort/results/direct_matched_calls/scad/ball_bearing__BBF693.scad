$fn = 128;

// Bearing dimensions (mm)
bore_d = 3.0;
od_d   = 8.0;
width  = 3.0;

// Flange dimensions (mm)
flange_d = 9.5;
flange_th = 0.6;          // typical small flange thickness
flange_z  = 0.0;          // flange at one face (bottom)

// Simple visual detailing (optional)
shield_recess_d = 7.2;    // shallow recess to suggest shields
shield_recess_depth = 0.15;

module flanged_ball_bearing() {
    difference() {
        union() {
            // Main outer ring body
            cylinder(d=od_d, h=width);

            // Flange (one side)
            translate([0,0,flange_z])
                cylinder(d=flange_d, h=flange_th);
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(d=bore_d, h=width + flange_th + 1.0);

        // Shallow recesses on both faces to suggest shields
        translate([0,0,0])
            cylinder(d=shield_recess_d, h=shield_recess_depth);

        translate([0,0,width - shield_recess_depth])
            cylinder(d=shield_recess_d, h=shield_recess_depth);
    }
}

flanged_ball_bearing();