$fn = 128;

// -------------------- Parameters --------------------
stator_diameter_mm = 35.0; //[17.5:70.0:0.5]
motor_height_mm    = 45.0; //[22.5:90.0:0.5]

// Visual/feature parameters (kept parametric, derived placements)
air_gap_mm                 = 0.5;  //[0.2:1.5:0.1]
rotor_shell_thickness_mm   = 1.5;  //[0.8:3.0:0.1]
can_wall_thickness_mm      = 1.0;  //[0.5:2.0:0.1]
endcap_thickness_mm        = 2.0;  //[1.0:4.0:0.25]
stator_axial_margin_mm     = 3.0;  //[1.0:8.0:0.5]

shaft_diameter_mm          = 5.0;  //[2.5:10.0:0.1]
shaft_extension_front_mm   = 12.0; //[0.0:24.0:0.5]
shaft_extension_rear_mm    = 0.0;  //[0.0:24.0:0.5]

mounting_flange_diameter_mm       = 40.0; //[20.0:80.0:0.5]
mounting_flange_thickness_mm      = 2.0;  //[1.0:6.0:0.25]
mounting_hole_count               = 4;    //[2:8:1]
mounting_hole_diameter_mm         = 3.0;  //[1.5:6.0:0.1]
mounting_hole_circle_diameter_mm  = 30.0; //[15.0:60.0:0.5]

wire_exit_diameter_mm             = 4.0;  //[2.0:8.0:0.1]
wire_exit_offset_from_center_mm   = 12.0; //[0.0:20.0:0.5]

overlap_mm = 1.0; //[0.5:2.0:0.1]

// -------------------- Derived dimensions --------------------
stator_r = stator_diameter_mm/2;

rotor_inner_r = stator_r + air_gap_mm;
rotor_outer_r = rotor_inner_r + rotor_shell_thickness_mm;

can_inner_r   = rotor_outer_r;
can_outer_r   = can_inner_r + can_wall_thickness_mm;

// Keep the overall motor body height exactly motor_height_mm (can/endcaps only)
body_h = motor_height_mm;

rotor_h = max(1, body_h - 2*endcap_thickness_mm - 2*stator_axial_margin_mm);

// Shaft total length
shaft_h = body_h + shaft_extension_front_mm + shaft_extension_rear_mm;

// Z references for the 45mm motor body
z_front_face =  body_h/2;
z_rear_face  = -body_h/2;

// -------------------- Helpers --------------------
module radial_slots(r_outer, slot_w, slot_h, count, z0, depth, overlap=0.2) {
    // Cuts shallow vent slots into the outer can wall
    for (i = [0:count-1]) {
        rotate([0,0,i*360/count])
            translate([r_outer - depth/2 + overlap, 0, z0])
                cube([depth + 2*overlap, slot_w, slot_h + 2*overlap], center=true);
    }
}

module bldc_motor() {
    // ONE connected solid: all features are unioned; holes/vents are subtracted.
    difference() {
        union() {
            // Outer can (shell) - height is exactly motor_height_mm
            difference() {
                cylinder(r=can_outer_r, h=body_h, center=true);
                cylinder(r=can_inner_r, h=body_h + 2*overlap_mm, center=true);
            }

            // Front endcap (solid disk) - flush with front face
            translate([0,0, z_front_face - endcap_thickness_mm/2])
                cylinder(r=can_outer_r, h=endcap_thickness_mm, center=true);

            // Rear endcap (solid disk) - flush with rear face
            translate([0,0, z_rear_face + endcap_thickness_mm/2])
                cylinder(r=can_outer_r, h=endcap_thickness_mm, center=true);

            // Front mounting flange (connected with overlap)
            translate([0,0, z_front_face + mounting_flange_thickness_mm/2 - overlap_mm])
                cylinder(r=mounting_flange_diameter_mm/2, h=mounting_flange_thickness_mm, center=true);

            // Front bearing boss (face detail)
            boss_r = max(shaft_diameter_mm*1.2, stator_r*0.35);
            boss_h = endcap_thickness_mm*1.2;
            translate([0,0, z_front_face - boss_h/2 + overlap_mm])
                cylinder(r=boss_r, h=boss_h, center=true);

            // Rear bearing boss
            translate([0,0, z_rear_face + boss_h/2 - overlap_mm])
                cylinder(r=boss_r*0.9, h=boss_h, center=true);

            // Shaft (passes through; connected)
            translate([0,0, (shaft_extension_front_mm - shaft_extension_rear_mm)/2])
                cylinder(r=shaft_diameter_mm/2, h=shaft_h, center=true);

            // Wire grommet (connected to rear endcap)
            grom_h = endcap_thickness_mm + 2*overlap_mm;
            translate([wire_exit_offset_from_center_mm, 0, z_rear_face + endcap_thickness_mm/2])
                cylinder(r=wire_exit_diameter_mm/2, h=grom_h, center=true);

            // External ribs on can (texture)
            rib_count = 12;
            rib_w = 1.2;
            rib_depth = 0.8;
            rib_h = body_h - 2*endcap_thickness_mm - 2; // leave a small margin
            for (i = [0:rib_count-1]) {
                rotate([0,0,i*360/rib_count])
                    translate([can_outer_r + rib_depth/2 - overlap_mm, 0, 0])
                        cube([rib_depth + 2*overlap_mm, rib_w, rib_h], center=true);
            }

            // Internal rotor ring (kept fully inside can so it doesn't create external ambiguity)
            // Ensure it overlaps endcaps slightly so it is part of the same connected solid.
            rotor_h_connected = min(body_h - 2*endcap_thickness_mm + 2*overlap_mm, body_h - 0.5);
            difference() {
                cylinder(r=rotor_outer_r, h=rotor_h_connected, center=true);
                cylinder(r=rotor_inner_r, h=rotor_h_connected + 2*overlap_mm, center=true);
            }
        }

        // Mounting holes through flange (and slightly into endcap)
        for (i = [0:mounting_hole_count-1]) {
            rotate([0,0,i*360/mounting_hole_count])
                translate([mounting_hole_circle_diameter_mm/2, 0,
                           z_front_face + mounting_flange_thickness_mm/2 - overlap_mm])
                    cylinder(r=mounting_hole_diameter_mm/2,
                             h=mounting_flange_thickness_mm + endcap_thickness_mm + 4*overlap_mm,
                             center=true);
        }

        // Add a center bore in the front boss for the shaft (recognizable motor face detail)
        translate([0,0, z_front_face - endcap_thickness_mm/2])
            cylinder(r=shaft_diameter_mm/2 + 0.3,
                     h=endcap_thickness_mm + boss_h + 4*overlap_mm,
                     center=true);

        // Vent slots around the can (shallow cuts; do not disconnect the solid)
        slot_count = 10;
        slot_w = 3.0;
        slot_h = body_h*0.55;
        slot_depth = min(can_wall_thickness_mm*0.8, 0.9);
        radial_slots(can_outer_r, slot_w, slot_h, slot_count, 0, slot_depth, overlap=0.2);

        // Small rear face wire notch (subtractive) aligned with grommet
        notch_w = wire_exit_diameter_mm*1.2;
        notch_h = endcap_thickness_mm + 2*overlap_mm;
        notch_d = can_outer_r*0.35;
        translate([wire_exit_offset_from_center_mm, 0, z_rear_face + endcap_thickness_mm/2])
            cube([notch_d, notch_w, notch_h], center=true);
    }
}

bldc_motor();