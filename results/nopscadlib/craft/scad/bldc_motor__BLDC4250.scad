// Brushless DC motor (single connected solid)
// Target: 42.5mm stator diameter, 48.0mm motor height (can height)

stator_diameter_mm = 42.5;          //[21.25:85:0.1]
motor_height_mm = 48.0;             //[24:96:0.1]

// Outer can
can_outer_diameter_mm = 45.5;       //[22.75:91:0.1]
can_wall_thickness_mm = 1.5;        //[0.75:3:0.1]

// Endcaps / face features
endcap_thickness_mm = 2.0;          //[1:4:0.1]
front_face_step_depth_mm = 0.8;     //[0:2:0.1]
front_face_step_diameter_mm = 28.0; //[10:40:0.1]

// Shaft
shaft_diameter_mm = 5.0;            //[2.5:10:0.1]
shaft_protrusion_front_mm = 15.0;   //[0:30:0.1]
shaft_protrusion_rear_mm = 0.0;     //[0:20:0.1]

// Mounting flange + holes
mounting_flange_diameter_mm = 50.0; //[25:100:0.1]
flange_thickness_mm = 2.5;          //[1:6:0.1]
mounting_hole_count = 4;            //[2:8:1]
mounting_hole_diameter_mm = 3.0;    //[1.5:6:0.1]
mounting_hole_circle_diameter_mm = 44.0; //[22:88:0.1]

// Visual stator/rotor cues (external + internal, still ONE solid)
stator_height_ratio = 0.85;         //[0.6:0.95:0.01]
stator_tooth_count = 12;            //[6:24:1]
stator_tooth_radial_mm = 1.2;       //[0.5:2.5:0.1]
stator_tooth_width_mm = 3.0;        //[1:6:0.1]
rotor_hub_diameter_mm = 18.0;       //[10:30:0.1]

// External cooling fins (recognizable BLDC can)
fin_count = 12;                     //[6:24:1]
fin_radial_mm = 0.8;                //[0.2:2:0.1]
fin_width_mm = 2.2;                 //[0.8:6:0.1]
fin_height_ratio = 0.75;            //[0.4:0.95:0.01]

// Rear cable grommet
cable_grommet_diameter_mm = 8.0;    //[4:16:0.1]
cable_grommet_length_mm = 6.0;      //[2:20:0.1]
cable_exit_angle_deg = 25;          //[0:60:1]

overlap_mm = 1.0;                   //[0.5:2:0.1]
$fn = 128;

// ---------- Derived ----------
can_r = can_outer_diameter_mm/2;
stator_r = stator_diameter_mm/2;

front_z = motor_height_mm/2;
rear_z  = -motor_height_mm/2;

stator_h = motor_height_mm * stator_height_ratio;
rotor_h  = stator_h;

fin_h = motor_height_mm * fin_height_ratio;

// ---------- Modules ----------
module radial_fins() {
    // Fins protrude outward from can OD and overlap into can by overlap_mm
    fin_len = fin_radial_mm + overlap_mm;
    for (i = [0:fin_count-1]) {
        rotate([0,0,i*360/fin_count])
            translate([can_r + fin_len/2 - overlap_mm, 0, 0])
                cube([fin_len, fin_width_mm, fin_h], center=true);
    }
}

module stator_teeth() {
    // Teeth protrude outward from stator OD and overlap into stator by overlap_mm
    tooth_len = stator_tooth_radial_mm + overlap_mm;
    for (i = [0:stator_tooth_count-1]) {
        rotate([0,0,i*360/stator_tooth_count])
            translate([stator_r + tooth_len/2 - overlap_mm, 0, 0])
                cube([tooth_len, stator_tooth_width_mm, stator_h], center=true);
    }
}

module motor_solid() {
    union() {
        // Outer can
        cylinder(r=can_r, h=motor_height_mm, center=true);

        // External cooling fins (connected)
        radial_fins();

        // Front endcap (slight step)
        translate([0,0, front_z - endcap_thickness_mm/2 + overlap_mm])
            cylinder(r=can_r, h=endcap_thickness_mm, center=true);

        // Rear endcap
        translate([0,0, rear_z + endcap_thickness_mm/2 - overlap_mm])
            cylinder(r=can_r, h=endcap_thickness_mm, center=true);

        // Mounting flange (connected to front endcap with overlap)
        translate([0,0, front_z + flange_thickness_mm/2 - overlap_mm])
            cylinder(r=mounting_flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        // Front face step (raised boss around shaft; connected)
        step_h = front_face_step_depth_mm;
        step_r = min(front_face_step_diameter_mm/2, can_r);
        translate([0,0, front_z + step_h/2 - overlap_mm])
            cylinder(r=step_r, h=step_h, center=true);

        // Central shaft (connected through motor)
        shaft_total_h = motor_height_mm + shaft_protrusion_front_mm + shaft_protrusion_rear_mm;
        shaft_center_z = (shaft_protrusion_front_mm - shaft_protrusion_rear_mm)/2;
        translate([0,0,shaft_center_z])
            cylinder(r=shaft_diameter_mm/2, h=shaft_total_h, center=true, $fn=64);

        // Internal stator core (visual cue; diameter matches requested stator_diameter_mm)
        cylinder(r=stator_r, h=stator_h, center=true);

        // Stator teeth (visual cue)
        stator_teeth();

        // Internal rotor hub (visual cue)
        cylinder(r=rotor_hub_diameter_mm/2, h=rotor_h, center=true);

        // Rear cable grommet (connected to rear endcap; angled)
        grommet_center_z = rear_z - cable_grommet_length_mm/2 + overlap_mm;
        rotate([0, cable_exit_angle_deg, 0])
            translate([0,0,grommet_center_z])
                cylinder(r=cable_grommet_diameter_mm/2, h=cable_grommet_length_mm, center=true, $fn=64);
    }
}

module motor_with_holes() {
    difference() {
        motor_solid();

        // Mounting holes through flange (and slightly into endcap for clean cut)
        hole_h = flange_thickness_mm + 2*overlap_mm;
        hole_z = front_z + flange_thickness_mm/2 - overlap_mm; // flange center
        for (i = [0:mounting_hole_count-1]) {
            rotate([0,0,i*360/mounting_hole_count])
                translate([mounting_hole_circle_diameter_mm/2, 0, hole_z])
                    cylinder(r=mounting_hole_diameter_mm/2, h=hole_h, center=true, $fn=48);
        }

        // Front face recess around shaft (cut into front endcap/step)
        recess_r = max(shaft_diameter_mm/2 + 2.0, 5.0);
        recess_h = 0.8;
        translate([0,0, front_z - recess_h/2 + overlap_mm])
            cylinder(r=recess_r, h=recess_h + 2*overlap_mm, center=true, $fn=96);
    }
}

// ---------- Final ----------
motor_with_holes();