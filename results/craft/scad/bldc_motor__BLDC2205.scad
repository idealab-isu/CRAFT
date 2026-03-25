$fn = 128;

// Target dimensions (stator)
stator_outer_diameter_mm = 28.0;   //[14.0:56.0:0.1]
stator_height_mm         = 17.25;  //[8.625:34.5:0.05]

// General
connect_overlap_mm = 0.6;          //[0.2:2.0:0.1]

// Motor feature parameters (kept proportional to stator size)
stator_inner_diameter_mm = 14.0;   //[6.0:26.0:0.1]
airgap_mm                = 0.4;

can_wall_mm              = 1.0;
can_lip_h_mm             = 1.2;

base_plate_h_mm          = 2.0;
base_plate_d_mm          = stator_outer_diameter_mm * 0.92;

mount_boss_d_mm          = stator_outer_diameter_mm * 0.55;
mount_boss_h_mm          = 1.6;

shaft_d_mm               = 3.0;
shaft_above_mm           = 8.0;
shaft_below_mm           = 2.0;

wire_exit_w_mm           = 4.0;
wire_exit_t_mm           = 2.0;
wire_exit_h_mm           = 3.0;

// Stator tooth look (visual only)
num_teeth = 12;
tooth_radial_len_mm = (stator_outer_diameter_mm - stator_inner_diameter_mm)/2 * 0.55;
tooth_w_mm          = 2.0;

// Derived
stator_r = stator_outer_diameter_mm/2;
stator_h = stator_height_mm;

can_outer_r = stator_r + airgap_mm + can_wall_mm;
can_inner_r = stator_r + airgap_mm;

can_h = stator_h; // overall motor height matches stator height
z_top =  can_h/2;
z_bot = -can_h/2;

module ring(r_out, r_in, h, center=true) {
    difference() {
        cylinder(r=r_out, h=h, center=center);
        cylinder(r=r_in,  h=h + 2*connect_overlap_mm, center=center);
    }
}

module bldc_motor_connected() {
    union() {

        // Rotor can (bell) with a small top lip
        color("DimGray")
        union() {
            // Main can wall
            ring(can_outer_r, can_inner_r, can_h, center=true);

            // Top lip (slightly thicker ring) connected to can
            translate([0,0, z_top - can_lip_h_mm/2 + connect_overlap_mm/2])
                ring(can_outer_r, can_inner_r - 0.6, can_lip_h_mm + connect_overlap_mm, center=true);
        }

        // Stator core with center bore and tooth-like protrusions (all connected)
        color("Silver")
        union() {
            // Stator ring
            ring(stator_r, stator_inner_diameter_mm/2, stator_h - base_plate_h_mm, center=true);

            // Teeth protruding inward from stator ring (connected via overlap)
            for (i = [0:num_teeth-1]) {
                rotate([0,0, i*360/num_teeth])
                    translate([ (stator_inner_diameter_mm/2) + tooth_radial_len_mm/2 - connect_overlap_mm, 0, 0])
                        cube([tooth_radial_len_mm, tooth_w_mm, stator_h - base_plate_h_mm], center=true);
            }
        }

        // Bottom mounting base plate (connected to stator/can)
        color("DimGray")
        translate([0,0, z_bot + base_plate_h_mm/2 - connect_overlap_mm/2])
            cylinder(d=base_plate_d_mm, h=base_plate_h_mm + connect_overlap_mm, center=true);

        // Bottom mount boss (connected to base plate)
        color("DimGray")
        translate([0,0, z_bot + base_plate_h_mm + mount_boss_h_mm/2 - connect_overlap_mm])
            cylinder(d=mount_boss_d_mm, h=mount_boss_h_mm + connect_overlap_mm, center=true);

        // Shaft (connected through the motor; no floating)
        color("Black")
        translate([0,0, (shaft_above_mm - shaft_below_mm)/2])
            cylinder(d=shaft_d_mm, h=can_h + shaft_above_mm + shaft_below_mm, center=true);

        // Simple wire exit tab on side (connected to can)
        color("Black")
        translate([can_outer_r - wire_exit_t_mm/2 + connect_overlap_mm/2, 0,
                   z_bot + base_plate_h_mm + wire_exit_h_mm/2])
            cube([wire_exit_t_mm + connect_overlap_mm, wire_exit_w_mm, wire_exit_h_mm], center=true);
    }
}

bldc_motor_connected();