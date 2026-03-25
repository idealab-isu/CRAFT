// Toggle switch (stylized) - ONE connected solid
// Target: body diameter = 12.6mm, body height = 13.1mm

$fn = 96;

// Parameters
body_diameter_mm = 12.6; //[6.3:25.2:0.1]
body_height_mm   = 13.1; //[6.55:26.2:0.1]

// Lever/actuator
lever_d_mm        = 3.0;  //[1.5:6:0.1]
lever_h_mm        = 10.0; //[5:25:0.1]
lever_tilt_deg    = 18;   //[0:35:1]

// Mounting hardware (kept within body diameter envelope)
bushing_d_mm      = 8.0;  //[6:12.6:0.1]
bushing_h_mm      = 2.2;  //[1:5:0.1]
washer_d_mm       = 12.0; //[8:12.6:0.1]
washer_h_mm       = 0.8;  //[0.4:2:0.1]

// Bottom terminals (stylized)
terminal_w_mm     = 1.6;  //[1:3:0.1]
terminal_t_mm     = 0.9;  //[0.6:2:0.1]
terminal_h_mm     = 4.0;  //[2:8:0.1]
terminal_spacing_mm = 4.2; //[3:6:0.1]

// Connectivity overlap
overlap_mm        = 0.6;  //[0.2:2:0.1]

// Derived
body_r = body_diameter_mm/2;

module toggle_switch() {
    union() {
        // Main cylindrical body (exact requested envelope)
        cylinder(r=body_r, h=body_height_mm, center=true);

        // Top mounting bushing (connected to body)
        translate([0,0, body_height_mm/2 + bushing_h_mm/2 - overlap_mm])
            cylinder(r=bushing_d_mm/2, h=bushing_h_mm, center=true);

        // Washer/flange (connected to bushing)
        translate([0,0, body_height_mm/2 + bushing_h_mm - overlap_mm + washer_h_mm/2 - overlap_mm])
            cylinder(r=washer_d_mm/2, h=washer_h_mm, center=true);

        // Toggle lever (tilted) connected into bushing
        // Place lever base slightly inside bushing for guaranteed connection.
        lever_base_z = body_height_mm/2 + bushing_h_mm - overlap_mm; // top of bushing (approx)
        translate([0,0, lever_base_z - overlap_mm])
            rotate([0, lever_tilt_deg, 0])
                translate([0,0, lever_h_mm/2])
                    cylinder(r=lever_d_mm/2, h=lever_h_mm, center=true);

        // Lever tip knob (connected to lever)
        knob_d_mm = 4.2;
        knob_h_mm = 3.2;
        translate([0,0, lever_base_z - overlap_mm])
            rotate([0, lever_tilt_deg, 0])
                translate([0,0, lever_h_mm + knob_h_mm/2 - overlap_mm])
                    cylinder(r=knob_d_mm/2, h=knob_h_mm, center=true);

        // Bottom terminals (3) connected to body bottom
        // Terminals start slightly inside the body to ensure union connectivity.
        term_center_z = -body_height_mm/2 - terminal_h_mm/2 + overlap_mm;

        for (x = [-terminal_spacing_mm, 0, terminal_spacing_mm]) {
            translate([x, 0, term_center_z])
                cube([terminal_w_mm, terminal_t_mm, terminal_h_mm], center=true);
        }

        // Small bottom boss to visually blend terminals into body (still within body diameter)
        boss_d_mm = 7.0;
        boss_h_mm = 1.6;
        translate([0,0, -body_height_mm/2 - boss_h_mm/2 + overlap_mm])
            cylinder(r=boss_d_mm/2, h=boss_h_mm, center=true);
    }
}

toggle_switch();