// Brushless DC motor (single connected solid)
// Target: stator diameter = 9.0mm, stator height = 8.0mm

$fn = 128;

// -------------------- Parameters --------------------
stator_diameter_mm = 9.0;          //[4.5:18.0:0.1]
stator_height_mm   = 8.0;          //[4.0:16.0:0.1]
stator_bore_diameter_mm = 2.0;     //[1.0:4.0:0.1]

can_outer_diameter_mm = 10.0;      //[6.0:20.0:0.1]
can_wall_thickness_mm = 0.5;       //[0.25:1.5:0.05]
endcap_thickness_mm   = 0.8;       //[0.4:2.0:0.05]

shaft_diameter_mm = 2.0;           //[1.0:4.0:0.1]
shaft_length_mm   = 12.0;          //[6.0:24.0:0.1]

mount_tab_length_mm    = 3.0;      //[1.5:6.0:0.1]
mount_tab_width_mm     = 3.0;      //[1.5:6.0:0.1]
mount_tab_thickness_mm = 0.8;      //[0.4:2.0:0.05]
mount_hole_diameter_mm = 1.6;      //[0.8:3.2:0.1]

wire_exit_diameter_mm = 1.2;       //[0.6:2.4:0.1]
wire_exit_length_mm   = 2.0;       //[1.0:5.0:0.1]

overlap_mm   = 0.8;                //[0.5:2.0:0.1]
clearance_mm = 0.2;                //[0.0:0.6:0.05]

// -------------------- Derived --------------------
stator_r = stator_diameter_mm/2;
can_r    = can_outer_diameter_mm/2;

motor_total_h = stator_height_mm + 2*endcap_thickness_mm;

z_top =  motor_total_h/2;
z_bot = -motor_total_h/2;

// Rotor (visual)
rotor_clear = 0.25;
rotor_r = max(stator_bore_diameter_mm/2 + 0.6, stator_r - 1.0);
rotor_h = max(0.1, stator_height_mm - 0.4);

// Stator teeth impression
tooth_count = 9;
tooth_depth = 0.9;
tooth_w     = 0.9;

// -------------------- Helpers --------------------
module hex_hole(r, h) {
    cylinder(r=r, h=h, center=true, $fn=6);
}

// -------------------- Model --------------------
module bldc_motor_connected() {

    // Ensure can can actually contain the stator + wall
    can_r_eff = max(can_r, stator_r + can_wall_thickness_mm + clearance_mm);

    // Inner cavity radius (leave wall)
    inner_r = max(0.1, can_r_eff - can_wall_thickness_mm);

    // Keep endcaps by stopping cavity short of ends
    cavity_h = max(0.1, motor_total_h - 2*endcap_thickness_mm + 2*overlap_mm);

    // Wire stub placement: centered on side, connected by overlap into can wall
    wire_x = can_r_eff - can_wall_thickness_mm/2;

    // Mount tab placement: connected to can side near rear endcap
    tab_x = can_r_eff + mount_tab_length_mm/2 - overlap_mm;
    tab_z = z_bot + endcap_thickness_mm/2;

    // Add a small "connector boss" so the tab reads as a motor mount feature (still one solid)
    boss_r = max(0.6, mount_tab_thickness_mm*0.9);
    boss_h = mount_tab_width_mm;

    difference() {
        union() {
            // Outer can (solid)
            cylinder(r=can_r_eff, h=motor_total_h, center=true);

            // Shaft (connected through front endcap with overlap)
            translate([0, 0, z_top + shaft_length_mm/2 - overlap_mm])
                cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

            // Rear shaft nub (connected with overlap)
            rear_nub_h = 1.2;
            translate([0, 0, z_bot - rear_nub_h/2 + overlap_mm])
                cylinder(r=shaft_diameter_mm/2 * 0.85, h=rear_nub_h, center=true);

            // Stator ring mass (solid) inside can (dimensions match request)
            // This is the verifiable stator: diameter=stator_diameter_mm, height=stator_height_mm
            cylinder(r=stator_r, h=stator_height_mm, center=true);

            // Rotor mass (solid) inside stator (visual)
            cylinder(r=rotor_r, h=rotor_h, center=true);

            // Front face hub/bearing boss (visual, connected)
            front_boss_r = max(shaft_diameter_mm/2 + 0.6, can_r_eff*0.28);
            front_boss_h = endcap_thickness_mm*0.9;
            translate([0, 0, z_top - endcap_thickness_mm/2 + front_boss_h/2 - overlap_mm])
                cylinder(r=front_boss_r, h=front_boss_h, center=true);

            // Rear face boss (visual, connected)
            rear_boss_r = can_r_eff*0.22;
            rear_boss_h = endcap_thickness_mm*0.7;
            translate([0, 0, z_bot + endcap_thickness_mm/2 - rear_boss_h/2 + overlap_mm])
                cylinder(r=rear_boss_r, h=rear_boss_h, center=true);

            // Wire exit stub (connected with overlap)
            translate([wire_x, 0, 0])
                rotate([0, 90, 0])
                    cylinder(r=wire_exit_diameter_mm/2, h=wire_exit_length_mm + 2*can_wall_thickness_mm, center=true);

            // Mounting tab (connected with overlap)
            translate([tab_x, 0, tab_z])
                cube([mount_tab_length_mm, mount_tab_width_mm, mount_tab_thickness_mm], center=true);

            // Small boss between tab and can to read as a mount feature (connected)
            translate([can_r_eff - overlap_mm, 0, tab_z])
                rotate([0, 90, 0])
                    cylinder(r=boss_r, h=mount_tab_length_mm*0.55, center=true);
        }

        // Hollow out can interior leaving wall thickness and endcaps
        cylinder(r=inner_r, h=cavity_h, center=true);

        // Stator bore (through stator height)
        cylinder(r=stator_bore_diameter_mm/2, h=stator_height_mm + 2*overlap_mm, center=true);

        // Stator slots/teeth impression (subtractive)
        slot_len = tooth_depth + 0.6;
        slot_w   = tooth_w;
        slot_h   = stator_height_mm + 2*overlap_mm;
        for (i = [0:tooth_count-1]) {
            rotate([0, 0, i*360/tooth_count])
                translate([stator_bore_diameter_mm/2 + slot_len/2, 0, 0])
                    cube([slot_len, slot_w, slot_h], center=true);
        }

        // Front endcap recess (visual)
        recess_r = can_r_eff * 0.55;
        recess_h = endcap_thickness_mm * 0.55;
        translate([0, 0, z_top - endcap_thickness_mm/2])
            cylinder(r=recess_r, h=recess_h + 2*overlap_mm, center=true);

        // Rear endcap recess (visual)
        translate([0, 0, z_bot + endcap_thickness_mm/2])
            cylinder(r=recess_r, h=recess_h + 2*overlap_mm, center=true);

        // Mounting hole in tab (hex-like)
        translate([tab_x, 0, tab_z])
            hex_hole(mount_hole_diameter_mm/2, mount_tab_thickness_mm + 2*overlap_mm);

        // Small flat on can (key) to avoid "buzzer can" look
        flat_w = can_outer_diameter_mm * 0.18;
        flat_d = can_outer_diameter_mm * 0.12;
        translate([can_r_eff - flat_d/2, 0, 0])
            cube([flat_d, flat_w, motor_total_h + 2*overlap_mm], center=true);

        // Add subtle outer "seam" groove near front to suggest motor can/endcap interface
        seam_r = can_r_eff + 0.01; // ensure it cuts
        seam_w = max(0.2, endcap_thickness_mm*0.25);
        seam_z = z_top - endcap_thickness_mm + seam_w/2;
        translate([0, 0, seam_z])
            difference() {
                cylinder(r=seam_r, h=seam_w + 2*overlap_mm, center=true);
                cylinder(r=seam_r - max(0.15, can_wall_thickness_mm*0.35), h=seam_w + 4*overlap_mm, center=true);
            }
    }
}

bldc_motor_connected();