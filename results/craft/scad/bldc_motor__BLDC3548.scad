// Brushless DC motor (single connected solid)
// Target: 35.0mm stator diameter, 45.0mm motor height

$fn = 96;

// Parameters
stator_diameter_mm = 35.0; //[17.5:70.0:0.5]
motor_height_mm    = 45.0; //[22.5:90.0:0.5]

can_outer_diameter_mm = 35.0; //[17.5:70.0:0.5]
shaft_diameter_mm     = 5.0;  //[2.5:10.0:0.1]
shaft_length_mm       = 10.0; //[5.0:20.0:0.5]

overlap_mm = 1.0; //[0.5:2.0:0.1]

// Feature sizing (kept proportional; derived from main dims)
can_wall_mm        = max(1.2, can_outer_diameter_mm * 0.045);
endbell_thk_mm     = max(2.0, motor_height_mm * 0.06);
stator_h_mm        = motor_height_mm - 2*endbell_thk_mm;

stator_r_mm        = stator_diameter_mm/2;
can_r_mm           = can_outer_diameter_mm/2;

rotor_gap_mm       = 0.6;
rotor_r_mm         = max(stator_r_mm + rotor_gap_mm, can_r_mm - can_wall_mm - 0.6);

mount_bolt_r_mm    = 1.6; // M3-ish clearance visual
mount_circle_r_mm  = can_r_mm * 0.72;

vent_slot_w_mm     = max(2.0, can_outer_diameter_mm * 0.08);
vent_slot_h_mm     = max(10.0, motor_height_mm * 0.35);
vent_slot_depth_mm = can_wall_mm + 0.8;

wire_exit_w_mm     = max(6.0, can_outer_diameter_mm * 0.18);
wire_exit_h_mm     = max(4.0, motor_height_mm * 0.10);
wire_exit_depth_mm = can_wall_mm + 1.2;

module BLDC_motor_solid() {
    union() {
        // Outer can with endbells, vents, and mounting holes (all as subtractions)
        difference() {
            // Main can
            cylinder(h=motor_height_mm, r=can_r_mm, center=true);

            // Slight seam groove around mid-height (visual)
            translate([0,0,0])
                cylinder(h=1.2, r=can_r_mm - 0.6, center=true);

            // Vent slots around the can (cut through wall)
            for (i = [0:7]) {
                rotate([0,0,i*360/8])
                    translate([can_r_mm - vent_slot_depth_mm/2, 0, 0])
                        cube([vent_slot_depth_mm, vent_slot_w_mm, vent_slot_h_mm], center=true);
            }

            // Wire exit notch on side near bottom endbell
            translate([can_r_mm - wire_exit_depth_mm/2, 0, -motor_height_mm/2 + endbell_thk_mm + wire_exit_h_mm/2])
                cube([wire_exit_depth_mm, wire_exit_w_mm, wire_exit_h_mm], center=true);

            // Front endbell mounting holes (4x)
            for (i = [0:3]) {
                rotate([0,0,i*90])
                    translate([mount_circle_r_mm, 0, motor_height_mm/2 - endbell_thk_mm/2])
                        cylinder(h=endbell_thk_mm + 2*overlap_mm, r=mount_bolt_r_mm, center=true);
            }

            // Back endbell mounting holes (4x)
            for (i = [0:3]) {
                rotate([0,0,i*90])
                    translate([mount_circle_r_mm, 0, -motor_height_mm/2 + endbell_thk_mm/2])
                        cylinder(h=endbell_thk_mm + 2*overlap_mm, r=mount_bolt_r_mm, center=true);
            }
        }

        // Internal stator/rotor suggestion as shallow external ribs (keeps one solid, adds recognizable detail)
        // Stator band (slightly proud ring)
        translate([0,0,0])
            difference() {
                cylinder(h=stator_h_mm, r=can_r_mm, center=true);
                cylinder(h=stator_h_mm + 2*overlap_mm, r=can_r_mm - 0.9, center=true);
            }

        // "Stator teeth" bumps around mid-body (protrude outward slightly)
        tooth_count = 12;
        tooth_len_mm = 1.4;
        tooth_w_mm   = can_outer_diameter_mm * 0.10;
        tooth_h_mm   = stator_h_mm * 0.55;

        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*360/tooth_count])
                translate([can_r_mm + tooth_len_mm/2 - 0.6, 0, 0])
                    cube([tooth_len_mm, tooth_w_mm, tooth_h_mm], center=true);
        }

        // Front shaft (connected with overlap)
        translate([0, 0, motor_height_mm/2 + shaft_length_mm/2 - overlap_mm])
            cylinder(h=shaft_length_mm, r=shaft_diameter_mm/2, center=true);

        // Back shaft stub (small) to look like rear bearing boss (still connected)
        back_stub_len_mm = max(3.0, shaft_length_mm*0.35);
        back_stub_d_mm   = shaft_diameter_mm * 0.85;
        translate([0, 0, -motor_height_mm/2 - back_stub_len_mm/2 + overlap_mm])
            cylinder(h=back_stub_len_mm, r=back_stub_d_mm/2, center=true);
    }
}

BLDC_motor_solid();