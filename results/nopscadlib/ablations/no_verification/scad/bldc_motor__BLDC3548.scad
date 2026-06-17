$fn = 128;

// =====================
// Requested parameters
// =====================
stator_diameter_mm = 35.0; //[17.5:70.0:0.5]
motor_height_mm    = 45.0; //[22.5:90.0:0.5]

// =====================
// Motor feature params
// =====================
can_wall_thickness_mm      = 1.0;  //[0.5:2.0:0.1]
endcap_thickness_mm        = 2.0;  //[1.0:4.0:0.25]
can_clearance_mm           = 1.5;  // radial clearance between stator OD and can ID

flange_outer_diameter_mm   = 44.0; //[22.0:88.0:0.5]
flange_thickness_mm        = 2.5;  //[1.25:5.0:0.25]

shaft_diameter_mm          = 5.0;  //[2.5:10.0:0.1]
shaft_protrusion_front_mm  = 12.0; //[6.0:24.0:0.5]
shaft_protrusion_rear_mm   = 0.0;  //[0.0:24.0:0.5]
shaft_step_diameter_mm     = 7.0;  //[3.5:14.0:0.1]
shaft_step_length_mm       = 4.0;  //[2.0:8.0:0.25]

mount_hole_d_mm            = 3.2;
mount_hole_bcd_mm          = 31.0;
mount_hole_count           = 4;

// Internal recognizable BLDC cues (kept solid and connected)
stator_height_mm           = 22.0; //[10.0:40.0:0.5]
spoke_count                = 6;
spoke_thickness_mm         = 2.0;

rotor_thickness_mm         = 3.0;
magnet_count               = 12;
magnet_radial_thickness_mm = 1.6;
magnet_arc_deg             = 18;

// External recognizable cues
vent_slot_count            = 12;
vent_slot_w_mm             = 2.2;
vent_slot_h_mm             = 6.0;
vent_slot_depth_mm         = 0.9;  // shallow cut into can wall

rear_rib_count             = 10;
rear_rib_w_mm              = 2.0;
rear_rib_h_mm              = 1.0;  // radial protrusion
rear_rib_len_mm            = 6.0;  // axial length near rear

// Rear wire exit boss (connected)
wire_boss_w = 9;
wire_boss_t = 4;
wire_boss_h = 7;

// Connectivity / overlap
overlap_mm = 0.6; //[0.2:2.0:0.1]

// =====================
// Derived dimensions
// =====================
can_inner_diameter_mm = stator_diameter_mm + 2*can_clearance_mm;
can_outer_diameter_mm = can_inner_diameter_mm + 2*can_wall_thickness_mm;

can_h = motor_height_mm;
z_front_face =  can_h/2;
z_rear_face  = -can_h/2;

shaft_total_h  = motor_height_mm + shaft_protrusion_front_mm + shaft_protrusion_rear_mm;
shaft_center_z = (shaft_protrusion_front_mm - shaft_protrusion_rear_mm)/2;

stator_center_z = 0;

can_id_r = can_inner_diameter_mm/2;
can_od_r = can_outer_diameter_mm/2;
stator_r = stator_diameter_mm/2;

// Place rotor/magnets near front inside can
rotor_center_z = z_front_face - endcap_thickness_mm - rotor_thickness_mm/2 + overlap_mm;

// =====================
// Helper modules
// =====================
module radial_magnets(r_inner, r_outer, h, n, arc_deg) {
    // Solid magnet segments around rotor ring (connected via overlap into rotor ring)
    for (i = [0:n-1]) {
        rotate([0,0,i*360/n])
            rotate([0,0,-arc_deg/2])
                rotate_extrude(angle=arc_deg, convexity=10)
                    translate([r_inner, 0, 0])
                        square([r_outer - r_inner, h], center=false);
    }
}

module motor_solid() {
    union() {
        // Outer can (solid)
        cylinder(d=can_outer_diameter_mm, h=can_h, center=true);

        // Front flange (solid, connected with overlap)
        translate([0,0, z_front_face + flange_thickness_mm/2 - overlap_mm])
            cylinder(d=flange_outer_diameter_mm, h=flange_thickness_mm, center=true);

        // Rear endcap lip (subtle step, solid and connected)
        rear_lip_h = 1.2;
        rear_lip_d = can_outer_diameter_mm + 1.2;
        translate([0,0, z_rear_face - rear_lip_h/2 + overlap_mm])
            cylinder(d=rear_lip_d, h=rear_lip_h, center=true);

        // Shaft (solid, passes through motor)
        translate([0,0, shaft_center_z])
            cylinder(d=shaft_diameter_mm, h=shaft_total_h, center=true);

        // Shaft step at front (solid, connected with overlap)
        translate([0,0, z_front_face + shaft_step_length_mm/2 - overlap_mm])
            cylinder(d=shaft_step_diameter_mm, h=shaft_step_length_mm, center=true);

        // Stator core (solid reference)
        translate([0,0, stator_center_z])
            cylinder(d=stator_diameter_mm, h=stator_height_mm, center=true);

        // Spokes connecting stator to can ID (ensures internal features are connected)
        spoke_len = (can_id_r - stator_r) + overlap_mm;
        spoke_w   = spoke_thickness_mm;
        spoke_h   = stator_height_mm;

        for (i = [0:spoke_count-1]) {
            rotate([0,0,i*360/spoke_count])
                translate([stator_r + spoke_len/2 - overlap_mm, 0, stator_center_z])
                    cube([spoke_len, spoke_w, spoke_h], center=true);
        }

        // Rotor ring (solid) near front
        rotor_r_outer = can_id_r - 0.6;
        rotor_r_inner = rotor_r_outer - rotor_thickness_mm;
        translate([0,0, rotor_center_z])
            difference() {
                cylinder(r=rotor_r_outer, h=rotor_thickness_mm, center=true);
                cylinder(r=rotor_r_inner, h=rotor_thickness_mm + 2*overlap_mm, center=true);
            }

        // Magnet segments (solid) on rotor OD (connected by overlap into rotor ring)
        mag_r_outer = rotor_r_outer + magnet_radial_thickness_mm;
        mag_r_inner = rotor_r_outer - overlap_mm;
        translate([0,0, rotor_center_z - rotor_thickness_mm/2])
            radial_magnets(mag_r_inner, mag_r_outer, rotor_thickness_mm, magnet_count, magnet_arc_deg);

        // Rear wire exit boss (solid, connected to can)
        translate([
            can_od_r - wire_boss_t/2 + overlap_mm,
            0,
            z_rear_face + endcap_thickness_mm + wire_boss_h/2 - overlap_mm
        ])
            cube([wire_boss_t, wire_boss_w, wire_boss_h], center=true);

        // Rear ribs (external cooling/motor-can detail), solid and connected
        rib_r = can_od_r + rear_rib_h_mm/2 - overlap_mm;
        rib_z = z_rear_face + endcap_thickness_mm + rear_rib_len_mm/2 - overlap_mm;
        for (i = [0:rear_rib_count-1]) {
            rotate([0,0,i*360/rear_rib_count])
                translate([rib_r, 0, rib_z])
                    cube([rear_rib_h_mm, rear_rib_w_mm, rear_rib_len_mm], center=true);
        }
    }
}

module motor_final() {
    difference() {
        motor_solid();

        // Mounting holes through flange (and slightly into can for clean cut)
        for (i = [0:mount_hole_count-1]) {
            rotate([0,0,i*360/mount_hole_count])
                translate([mount_hole_bcd_mm/2, 0, z_front_face + flange_thickness_mm/2 - overlap_mm])
                    cylinder(d=mount_hole_d_mm, h=flange_thickness_mm + 2*overlap_mm, center=true);
        }

        // Front face recess around shaft (visual cue)
        translate([0,0, z_front_face + 0.2])
            cylinder(d=stator_diameter_mm*0.62, h=0.9, center=true);

        // Ventilation slots near front perimeter (shallow cuts into can wall)
        // Positioned so they clearly read in orthographic side/top views.
        slot_z = z_front_face - flange_thickness_mm - vent_slot_h_mm/2 - 1.0;
        slot_r = can_od_r - vent_slot_depth_mm/2 + overlap_mm; // ensure it intersects can
        for (i = [0:vent_slot_count-1]) {
            rotate([0,0,i*360/vent_slot_count])
                translate([slot_r, 0, slot_z])
                    cube([vent_slot_depth_mm + 2*overlap_mm, vent_slot_w_mm, vent_slot_h_mm], center=true);
        }

        // Rear endcap shallow circular recess (visual cue)
        translate([0,0, z_rear_face - 0.2])
            cylinder(d=stator_diameter_mm*0.55, h=0.8, center=true);
    }
}

motor_final();