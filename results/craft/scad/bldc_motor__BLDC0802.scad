$fn = 128;

// Brushless DC motor envelope (stator/can)
stator_diameter_mm = 11.5;   // outer can diameter
stator_height_mm   = 9.5;    // overall motor height (excluding shaft)

// Proportional details
can_wall_mm        = 0.6;
endcap_thk_mm      = 0.9;

shaft_d_mm         = 2.0;
shaft_front_len_mm = 6.0;
shaft_rear_len_mm  = 1.5;

front_boss_d_mm    = 6.0;
front_boss_thk_mm  = 0.9;

mount_hole_d_mm    = 1.6;    // visual mounting pattern (not through)
mount_pcd_mm       = 6.0;    // pitch circle diameter for 4 holes
mount_hole_depth_mm= 0.5;

vent_slot_count    = 8;      // bell/rotor can slots
vent_slot_w_mm     = 1.0;
vent_slot_h_mm     = 2.2;
vent_slot_depth_mm = 0.35;

wire_d_mm          = 0.8;
wire_len_mm        = 7.0;
wire_spacing_mm    = 1.2;    // spacing between wires (Y)
wire_exit_z_from_bot_mm = 1.6; // where wires exit above bottom face

connect_overlap_mm = 0.35;

// Derived
motor_r = stator_diameter_mm/2;
motor_h = stator_height_mm;

z_top =  motor_h/2;
z_bot = -motor_h/2;

can_inner_r = max(motor_r - can_wall_mm, 0.1);

// Helper: radial array
module radial_array(n) {
    for (i = [0:n-1]) rotate([0,0,i*360/n]) children();
}

// One connected solid BLDC-like motor
module bldc_motor_connected() {
    union() {

        // Outer can with shallow vent slots (difference keeps it one solid)
        difference() {
            cylinder(r=motor_r, h=motor_h, center=true);

            // Shallow vent/slot impressions around the side (recognizable BLDC bell detail)
            // Cut only a small depth so the can remains thick and robust.
            radial_array(vent_slot_count)
                translate([motor_r - vent_slot_depth_mm/2, 0, 0])
                    cube([vent_slot_depth_mm, vent_slot_w_mm, vent_slot_h_mm], center=true);

            // Slight seam line around mid-height (very shallow)
            translate([0,0,0])
                cylinder(r=motor_r + 0.01, h=0.25, center=true);
        }

        // Front endcap/boss (face detail)
        translate([0, 0, z_top - front_boss_thk_mm/2 + connect_overlap_mm/2])
            cylinder(r=front_boss_d_mm/2, h=front_boss_thk_mm + connect_overlap_mm, center=true);

        // Mounting pattern: 4 shallow dimples on the front boss (visual, not through)
        difference() {
            // Add a thin face ring to receive dimples (keeps dimples from touching main can too much)
            translate([0, 0, z_top - (front_boss_thk_mm + 0.25)/2 + connect_overlap_mm/2])
                cylinder(r=front_boss_d_mm/2, h=front_boss_thk_mm + 0.25 + connect_overlap_mm, center=true);

            for (a = [0:90:270]) {
                rotate([0,0,a])
                    translate([mount_pcd_mm/2, 0, z_top - mount_hole_depth_mm/2 + connect_overlap_mm/2])
                        cylinder(r=mount_hole_d_mm/2, h=mount_hole_depth_mm + connect_overlap_mm, center=true);
            }
        }

        // Shaft (front)
        translate([0, 0, z_top + shaft_front_len_mm/2 - connect_overlap_mm])
            cylinder(r=shaft_d_mm/2, h=shaft_front_len_mm + 2*connect_overlap_mm, center=true);

        // Shaft (rear stub)
        translate([0, 0, z_bot - shaft_rear_len_mm/2 + connect_overlap_mm])
            cylinder(r=shaft_d_mm/2, h=shaft_rear_len_mm + 2*connect_overlap_mm, center=true);

        // Rear endcap lip (subtle step)
        rear_lip_thk = 0.6;
        rear_lip_r   = motor_r - 0.5;
        translate([0, 0, z_bot + rear_lip_thk/2 - connect_overlap_mm/2])
            cylinder(r=rear_lip_r, h=rear_lip_thk + connect_overlap_mm, center=true);

        // Wire exit grommet/strain relief (connected to can)
        wire_exit_z = z_bot + wire_exit_z_from_bot_mm;
        grommet_len = 2.4;
        grommet_r   = 1.4;

        translate([motor_r - connect_overlap_mm, 0, wire_exit_z])
            rotate([0, 90, 0])
                cylinder(r=grommet_r, h=grommet_len + 2*connect_overlap_mm, center=true);

        // Three phase wires (A/B/C) exiting from the grommet (not pins)
        // Ensure they intersect the grommet by overlapping into it.
        for (s = [-1, 0, 1]) {
            translate([motor_r + (wire_len_mm/2) + (grommet_len/2) - connect_overlap_mm, s*wire_spacing_mm, wire_exit_z])
                rotate([0, 90, 0])
                    cylinder(r=wire_d_mm/2, h=wire_len_mm + 2*connect_overlap_mm, center=true);
        }

        // Small tie/boot around wires (adds recognizable wire bundle feature)
        boot_len = 1.6;
        boot_r   = 1.6;
        translate([motor_r + grommet_len - connect_overlap_mm, 0, wire_exit_z])
            rotate([0, 90, 0])
                cylinder(r=boot_r, h=boot_len + 2*connect_overlap_mm, center=true);
    }
}

bldc_motor_connected();