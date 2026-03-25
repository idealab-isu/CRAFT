// Brushless DC motor (single connected solid) with verifiable:
// - Stator diameter = 42.5mm (internal stator ring OD)
// - Motor height    = 48.0mm (overall can+endbells, excluding shaft)
//
// Adds recognizable BLDC details while staying ONE connected solid:
// - Endbells with lip + rear bearing boss
// - Front mounting face with 4 shallow dimples on a PCD
// - Vent/slot cues as shallow grooves (do not cut through)
// - Stator/rotor cues as raised ring + ribs (no internal voids)
// - Side connector/buzzer kept and connected with formula placement

$fn = 128;

// Primary requirements
stator_diameter_mm = 42.5;   //[21.25:85:0.1]
motor_height_mm    = 48.0;   //[24:96:0.1]

// Motor feature parameters (typical BLDC proportions)
stator_clearance_mm = 0.6;   //[0.2:2:0.1]   // radial clearance between stator OD and can ID (visual)
can_wall_mm         = 1.2;   //[0.8:2:0.1]
endbell_len_mm      = 6.0;   //[3:12:0.1]
mount_face_thk_mm   = 3.0;   //[2:6:0.1]
shaft_d_mm          = 5.0;   //[2:10:0.1]
shaft_len_mm        = 18.0;  //[8:30:0.1]
boss_d_mm           = 12.0;  //[8:20:0.1]
boss_thk_mm         = 2.5;   //[1:6:0.1]
rear_bearing_boss_d_mm = 14.0; //[10:22:0.1]
rear_bearing_boss_thk_mm = 2.2; //[1:6:0.1]

// Mounting holes (visual only; shallow dimples)
mount_hole_count    = 4;
mount_hole_pcd_mm   = 25.0;  //[15:35:0.1]
mount_hole_d_mm     = 3.2;   //[2:5:0.1]
mount_hole_depth_mm = 1.2;   //[0.5:3:0.1]

// Vent/slot cues (shallow grooves on can)
slot_count          = 12;
slot_w_mm           = 3.0;
slot_depth_mm       = 0.7;   //[0.3:1.5:0.1]
slot_len_frac       = 0.65;  //[0.3:0.9:0.05]

// Internal stator/rotor visual (raised features; no voids)
stator_tooth_count  = 12;
stator_tooth_rad_mm = 1.0;
stator_tooth_w_mm   = 2.2;
rotor_ring_thk_mm   = 1.0;

// Side connector/buzzer parameters (connected)
buzzer_diameter_mm     = 12; //[6:24:0.1]
buzzer_height_mm       = 7;  //[3.5:14:0.1]
buzzer_pin_diameter_mm = 2;  //[1:4:0.1]
buzzer_pin_height_mm   = 4;  //[2:8:0.1]
attach_overlap_mm      = 1;  //[0.5:2:0.1]

// Derived radii/heights
stator_r = stator_diameter_mm/2;                 // REQUIRED: 21.25mm
can_r    = stator_r + stator_clearance_mm + can_wall_mm;
H        = motor_height_mm;                      // REQUIRED: 48.0mm

// Z layout (motor body centered at origin)
z_bot = -H/2;
z_top =  H/2;

can_len_mm = H - 2*endbell_len_mm;
z_can_center = 0;

z_endbell_front_center = z_top - endbell_len_mm/2;
z_endbell_back_center  = z_bot + endbell_len_mm/2;

z_mount_face_center = z_top - mount_face_thk_mm/2;

// Shaft on front (top)
z_shaft_center = z_top + shaft_len_mm/2 - attach_overlap_mm;

// Side buzzer placement: attached to side of can, centered vertically
buzzer_r = buzzer_diameter_mm/2;
buzzer_x = can_r + buzzer_r - attach_overlap_mm;
buzzer_z = 0;

// Helper: shallow mounting dimples (do not cut through)
module mounting_dimples() {
    for (i = [0:mount_hole_count-1]) {
        rotate([0,0,i*360/mount_hole_count])
            translate([mount_hole_pcd_mm/2, 0, z_top - mount_hole_depth_mm/2])
                cylinder(d=mount_hole_d_mm, h=mount_hole_depth_mm, center=true, $fn=48);
    }
}

// Helper: stator teeth as outward ribs (visual cue)
module stator_teeth_ribs() {
    tooth_h = can_len_mm * 0.70;
    for (i = [0:stator_tooth_count-1]) {
        rotate([0,0,i*360/stator_tooth_count])
            translate([can_r - stator_tooth_rad_mm/2, 0, 0])
                cube([stator_tooth_rad_mm, stator_tooth_w_mm, tooth_h], center=true);
    }
}

// Helper: shallow ventilation grooves on can (difference later; does not disconnect)
module can_vent_grooves() {
    groove_h = can_len_mm * slot_len_frac;
    // Place grooves centered on can length
    for (i = [0:slot_count-1]) {
        rotate([0,0,i*360/slot_count])
            translate([can_r - slot_depth_mm/2, 0, 0])
                cube([slot_depth_mm, slot_w_mm, groove_h], center=true);
    }
}

// Motor body (single solid)
module BLDC_motor_solid() {
    union() {
        // Main can (outer shell)
        translate([0,0,z_can_center])
            cylinder(r=can_r, h=can_len_mm, center=true);

        // Endbells (slightly smaller radius)
        translate([0,0,z_endbell_front_center])
            cylinder(r=can_r*0.985, h=endbell_len_mm, center=true);

        translate([0,0,z_endbell_back_center])
            cylinder(r=can_r*0.985, h=endbell_len_mm, center=true);

        // Front mounting face lip (slightly larger)
        translate([0,0,z_mount_face_center])
            cylinder(r=can_r*1.03, h=mount_face_thk_mm, center=true);

        // Rear endbell lip (subtle)
        translate([0,0,z_bot + mount_face_thk_mm/2])
            cylinder(r=can_r*1.02, h=mount_face_thk_mm, center=true);

        // Front boss around shaft
        translate([0,0,z_top + boss_thk_mm/2 - attach_overlap_mm])
            cylinder(d=boss_d_mm, h=boss_thk_mm, center=true);

        // Rear bearing boss (visual)
        translate([0,0,z_bot - rear_bearing_boss_thk_mm/2 + attach_overlap_mm])
            cylinder(d=rear_bearing_boss_d_mm, h=rear_bearing_boss_thk_mm, center=true);

        // Shaft (protruding)
        translate([0,0,z_shaft_center])
            cylinder(d=shaft_d_mm, h=shaft_len_mm, center=true);

        // Verifiable stator OD ring (exact 42.5mm diameter)
        // Slightly shorter than full height so it reads as internal stator stack
        stator_stack_h = H - 2*endbell_len_mm - 2;
        translate([0,0,0])
            cylinder(d=stator_diameter_mm, h=stator_stack_h, center=true);

        // Rotor ring cue (slightly larger than stator OD, still inside can)
        rotor_d = min(2*(can_r - can_wall_mm*0.6), stator_diameter_mm + 2.6);
        translate([0,0,0])
            cylinder(d=rotor_d, h=stator_stack_h*0.92, center=true);

        // Stator teeth ribs on can (external cue)
        stator_teeth_ribs();
    }
}

// Side buzzer/connector (connected)
module buzzer_side() {
    union() {
        // Buzzer body (connected to can by overlap)
        translate([buzzer_x, 0, buzzer_z])
            cylinder(r=buzzer_r, h=buzzer_height_mm, center=true, $fn=96);

        // Pin on buzzer (connected to buzzer body)
        translate([buzzer_x, 0, buzzer_z + buzzer_height_mm/2 + buzzer_pin_height_mm/2 - attach_overlap_mm])
            cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true, $fn=48);

        // Bridge to ensure robust connection to can
        hull() {
            translate([can_r - attach_overlap_mm, 0, buzzer_z])
                cylinder(r=1.4, h=buzzer_height_mm*0.75, center=true, $fn=36);
            translate([buzzer_x - buzzer_r + attach_overlap_mm, 0, buzzer_z])
                cylinder(r=1.4, h=buzzer_height_mm*0.75, center=true, $fn=36);
        }
    }
}

// Final assembly: ONE connected solid.
// Use difference only for shallow surface details (dimples + vent grooves).
difference() {
    union() {
        BLDC_motor_solid();
        buzzer_side();
    }
    // Shallow mounting dimples on front face (visual holes without cutting through)
    mounting_dimples();

    // Shallow ventilation grooves on can (do not cut through)
    can_vent_grooves();
}