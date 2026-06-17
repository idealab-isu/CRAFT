$fn = 128;

// ===== Target motor: BLDC with 11.5mm stator diameter and 9.5mm height =====
stator_diameter = 11.5;          // mm (requested)
stator_height   = 9.5;           // mm (requested)

// ===== Motor construction parameters (motor-like features) =====
housing_wall_thickness   = 0.6;  // mm
housing_clearance_radial = 0.3;  // mm (gap between stator OD and housing ID)
endcap_thickness         = 0.8;  // mm (visual endcaps)

shaft_diameter           = 2.0;  // mm
shaft_length_above_top   = 6.0;  // mm
shaft_length_below_bottom= 2.0;  // mm

// Derived housing size from stator + clearance + wall
overall_diameter = stator_diameter + 2*(housing_clearance_radial + housing_wall_thickness);
overall_height   = stator_height + 2*endcap_thickness;

// Mount flange (simple base ring)
mount_flange_thickness = 1.2;
mount_flange_diameter  = max(overall_diameter + 2.0, 16);

// Mount holes (visual/functional)
mount_hole_count    = 4;
mount_hole_diameter = 1.6;
mount_hole_circle_d = mount_flange_diameter - 3.0; // keep edge margin by formula

// Cooling slots (cutouts)
cooling_slot_count  = 6;
cooling_slot_width  = 1.2;
cooling_slot_height = min(stator_height*0.75, overall_height - 2*endcap_thickness);
cooling_slot_depth  = 1.2;

// Wire notch (cutout)
wire_notch_width  = 2.2;
wire_notch_height = 2.2;
wire_notch_depth  = 2.0;

// Internal rotor (visual)
rotor_clearance = 0.25;
rotor_diameter  = stator_diameter - 2*rotor_clearance;
rotor_height    = stator_height - 0.6;

// Stator teeth (visual)
tooth_count        = 12;
tooth_radial_len   = 0.9;
tooth_tangential_w = 0.9;

// Overlap for watertight unions/differences
overlap = 0.8;

// ===== Helpers =====
module ring(r_out, r_in, h, center=true) {
    difference() {
        cylinder(r=r_out, h=h, center=center);
        cylinder(r=r_in,  h=h + 2*overlap, center=center);
    }
}

// ===== Motor =====
module bldc_motor() {

    // Z references (all formulas)
    z_top    =  overall_height/2;
    z_bottom = -overall_height/2;

    // Housing radii
    r_housing_out = overall_diameter/2;
    r_housing_in  = r_housing_out - housing_wall_thickness;

    // Stator radii
    r_stator_out = stator_diameter/2;
    r_stator_in  = max(0.1, r_stator_out - 1.2); // visual core thickness

    // Rotor radii
    r_rotor_out = rotor_diameter/2;
    r_rotor_in  = max(0.1, r_rotor_out - 1.0);

    // Shaft total length and center placement
    shaft_total_h  = overall_height + shaft_length_above_top + shaft_length_below_bottom;
    shaft_center_z = (shaft_length_above_top - shaft_length_below_bottom)/2;

    // Active stack centered in can
    z_active_center = 0;

    // Bearing boss (visual) inside endcaps, also helps "motor-like" look
    bearing_boss_r = max(shaft_diameter/2 + 0.8, 1.8);
    bearing_boss_h = endcap_thickness + 0.6;

    // Ensure internal parts are connected to the outer shell by a thin web
    // (keeps model ONE connected solid even though interior is hollowed)
    web_thickness = 0.6;
    web_w         = 1.2;
    web_h         = stator_height; // spans active stack

    union() {

        // ===== Outer housing with endcaps, flange, and cutouts =====
        difference() {
            union() {
                // Main can
                cylinder(r=r_housing_out, h=overall_height, center=true);

                // Endcap lips (slight step)
                translate([0,0, z_top - endcap_thickness/2])
                    cylinder(r=r_housing_out - housing_wall_thickness*0.2, h=endcap_thickness, center=true);
                translate([0,0, z_bottom + endcap_thickness/2])
                    cylinder(r=r_housing_out - housing_wall_thickness*0.2, h=endcap_thickness, center=true);

                // Mount flange (connected with overlap)
                translate([0,0, z_bottom - mount_flange_thickness/2 + overlap])
                    cylinder(r=mount_flange_diameter/2, h=mount_flange_thickness, center=true);
            }

            // Hollow interior (leave endcaps thickness)
            cylinder(r=r_housing_in,
                     h=overall_height - 2*endcap_thickness + 2*overlap,
                     center=true);

            // Wire exit notch (cut from side, located near bottom endcap)
            translate([r_housing_out - wire_notch_depth/2, 0,
                       z_bottom + endcap_thickness + wire_notch_height/2])
                cube([wire_notch_depth, wire_notch_width, wire_notch_height], center=true);

            // Cooling slots (radial array, cut into can wall)
            for (i = [0:cooling_slot_count-1]) {
                rotate([0,0, i*360/cooling_slot_count])
                    translate([r_housing_out - cooling_slot_depth/2, 0, 0])
                        cube([cooling_slot_depth, cooling_slot_width, cooling_slot_height], center=true);
            }

            // Mount holes through flange
            for (i = [0:mount_hole_count-1]) {
                rotate([0,0, i*360/mount_hole_count])
                    translate([mount_hole_circle_d/2, 0, z_bottom - mount_flange_thickness/2 + overlap])
                        cylinder(r=mount_hole_diameter/2,
                                 h=mount_flange_thickness + 2*overlap,
                                 center=true, $fn=48);
            }
        }

        // ===== Shaft (connected through endcaps) =====
        translate([0,0, shaft_center_z])
            cylinder(r=shaft_diameter/2, h=shaft_total_h, center=true, $fn=64);

        // ===== Bearing bosses (visual, connected to endcaps) =====
        translate([0,0, z_top - endcap_thickness/2])
            cylinder(r=bearing_boss_r, h=bearing_boss_h, center=true);
        translate([0,0, z_bottom + endcap_thickness/2])
            cylinder(r=bearing_boss_r, h=bearing_boss_h, center=true);

        // ===== Internal stator (visual ring + teeth) =====
        translate([0,0, z_active_center])
            ring(r_stator_out, r_stator_in, stator_height, center=true);

        // Stator teeth protruding inward from stator inner radius (connected via overlap)
        for (i = [0:tooth_count-1]) {
            rotate([0,0, i*360/tooth_count])
                translate([r_stator_in - tooth_radial_len/2 + 0.35, 0, z_active_center])
                    cube([tooth_radial_len, tooth_tangential_w, stator_height - 0.2], center=true);
        }

        // ===== Internal rotor (visual ring + hub) =====
        translate([0,0, z_active_center])
            ring(r_rotor_out, r_rotor_in, rotor_height, center=true);

        // Rotor hub to shaft (ensures internal connection)
        translate([0,0, z_active_center])
            cylinder(r=max(shaft_diameter/2 + 0.4, 1.2), h=rotor_height, center=true);

        // ===== Connectivity web: ties internal stack to outer can (one connected solid) =====
        // A thin rib from stator OD to housing ID, spanning the active height.
        // Placed at +X, overlaps both stator and housing by overlap.
        translate([ (r_stator_out + r_housing_in)/2, 0, z_active_center ])
            cube([ (r_housing_in - r_stator_out) + 2*overlap, web_w, web_h ], center=true);
    }
}

bldc_motor();