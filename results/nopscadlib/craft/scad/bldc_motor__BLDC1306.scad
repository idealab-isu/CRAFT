$fn = 128;

// ===== Parameters (requested) =====
stator_diameter_mm = 17.75;                 //[8.875:35.5:0.05]
stator_height_mm   = 14.5;                  //[7.25:29:0.1]

// ===== Connectivity / robustness =====
fit_overlap_mm = 0.6;                       //[0.2:2:0.05]

// ===== Motor feature parameters =====
// Can / rotor (outer shell)
motor_can_wall_thickness_mm = 0.7;          //[0.25:2:0.05]
air_gap_mm = 0.35;                          //[0.1:1:0.05]
can_extra_radius_mm = 0.9;                  //[0.2:2:0.05]

// Endbells / face features
endbell_thickness_mm = 1.2;                 //[0.6:3:0.05]
front_boss_diameter_mm = 6.0;               //[3:12:0.1]
front_boss_height_mm   = 1.2;               //[0.5:4:0.05]

// Mounting holes (recesses)
mount_hole_diameter_mm = 1.6;               //[1:3:0.05]
mount_hole_circle_diameter_mm = 12.0;       //[6:18:0.1]
mount_hole_depth_mm = endbell_thickness_mm + 0.6;

// Ventilation slots (recesses) on can
num_vents = 10;                             //[6:18:1]
vent_w_mm = 2.0;                            //[1:4:0.05]
vent_h_mm = 6.0;                            //[3:10:0.1]
vent_depth_mm = 0.6;                        //[0.2:1.2:0.05]

// Stator bore + teeth
stator_center_bore_diameter_mm = 5.0;       //[2.5:10:0.05]
num_teeth = 12;                             //[6:18:1]
tooth_radial_len_mm = 1.2;                  //[0.5:3:0.05]
tooth_tangential_w_mm = 1.6;                //[0.6:3:0.05]

// Shaft
shaft_diameter_mm = 2.0;                    //[1:6:0.05]
shaft_protrusion_front_mm = 6.0;            //[1:15:0.1]
shaft_protrusion_back_mm  = 1.5;            //[0:8:0.1]

// Wiring pigtail (solid, connected)
wire_diameter_mm = 1.2;                     //[0.6:2.5:0.05]
wire_exit_angle_deg = 35;                   //[0:90:1]
wire_exit_len_mm = 8.0;                     //[3:20:0.1]
wire_exit_z_from_back_mm = 3.0;             //[1:10:0.1]

// ===== Derived dimensions =====
stator_r = stator_diameter_mm/2;

motor_can_inner_r = stator_r + air_gap_mm;
motor_can_outer_r = motor_can_inner_r + motor_can_wall_thickness_mm + can_extra_radius_mm;

motor_height = stator_height_mm;            // overall motor body height matches requested 14.5mm
z_front =  motor_height/2;
z_back  = -motor_height/2;

// Keep vents within the can wall and within height
vent_center_r = motor_can_outer_r - max(0.25, vent_depth_mm/2);
vent_center_z = 0;

// ===== Modules =====
module stator_with_teeth() {
    union() {
        // Stator ring with center bore
        difference() {
            cylinder(r=stator_r, h=stator_height_mm, center=true);
            cylinder(r=stator_center_bore_diameter_mm/2,
                     h=stator_height_mm + 2*fit_overlap_mm, center=true);
        }

        // Teeth protruding outward from stator OD (connected via overlap)
        for (i = [0:num_teeth-1]) {
            rotate([0,0,i*360/num_teeth])
                translate([stator_r + tooth_radial_len_mm/2 - fit_overlap_mm, 0, 0])
                    cube([tooth_radial_len_mm, tooth_tangential_w_mm, stator_height_mm],
                         center=true);
        }
    }
}

module motor_can_shell_with_vents() {
    // Hollow can with shallow external vent recesses (still one solid after union)
    difference() {
        // Can shell
        difference() {
            cylinder(r=motor_can_outer_r, h=motor_height, center=true);
            cylinder(r=motor_can_inner_r,
                     h=motor_height + 2*fit_overlap_mm, center=true);
        }

        // Vent recesses: subtract small boxes that bite into the outer wall
        for (i = [0:num_vents-1]) {
            rotate([0,0,i*360/num_vents])
                translate([vent_center_r, 0, vent_center_z])
                    cube([vent_depth_mm*2, vent_w_mm, vent_h_mm], center=true);
        }
    }
}

module endbell_front() {
    // Front endbell disk + boss; holes are shallow recesses (not through)
    difference() {
        union() {
            // Endbell disk overlaps into can for connectivity
            translate([0,0, z_front - endbell_thickness_mm/2 + fit_overlap_mm/2])
                cylinder(r=motor_can_outer_r, h=endbell_thickness_mm + fit_overlap_mm, center=true);

            // Front boss around shaft (overlaps into endbell)
            translate([0,0, z_front + front_boss_height_mm/2 - fit_overlap_mm/2])
                cylinder(r=front_boss_diameter_mm/2, h=front_boss_height_mm + fit_overlap_mm, center=true);
        }

        // Mounting hole recesses on a bolt circle
        for (a = [0:90:270]) {
            rotate([0,0,a])
                translate([mount_hole_circle_diameter_mm/2, 0,
                           z_front - mount_hole_depth_mm/2 + fit_overlap_mm/2])
                    cylinder(r=mount_hole_diameter_mm/2,
                             h=mount_hole_depth_mm + fit_overlap_mm, center=true);
        }
    }
}

module endbell_back() {
    // Back endbell disk with a small cable grommet boss (solid) to look more motor-like
    grommet_r = max(wire_diameter_mm*0.9, 1.0);
    grommet_h = 1.0;

    union() {
        // Endbell disk overlaps into can for connectivity
        translate([0,0, z_back + endbell_thickness_mm/2 - fit_overlap_mm/2])
            cylinder(r=motor_can_outer_r, h=endbell_thickness_mm + fit_overlap_mm, center=true);

        // Small grommet boss on back face near edge (connected)
        translate([motor_can_outer_r - grommet_r - 0.6, 0,
                   z_back - endbell_thickness_mm/2 + grommet_h/2 + fit_overlap_mm/2])
            cylinder(r=grommet_r, h=grommet_h + fit_overlap_mm, center=true);
    }
}

module shaft() {
    // Shaft passes through bore and protrudes out front/back
    shaft_total_h = motor_height + shaft_protrusion_front_mm + shaft_protrusion_back_mm;
    z_center = (shaft_protrusion_front_mm - shaft_protrusion_back_mm)/2;

    translate([0,0,z_center])
        cylinder(r=shaft_diameter_mm/2, h=shaft_total_h, center=true);
}

module wire_pigtail() {
    // Solid wire exiting from back grommet area; connected by overlap into back endbell
    // Start point on back face near edge
    start_x = motor_can_outer_r - max(wire_diameter_mm, 1.0) - 0.6;
    start_z = z_back - endbell_thickness_mm/2 + wire_diameter_mm/2 + fit_overlap_mm/2;

    // Build as a hull between two short cylinders to form a smooth connected pigtail
    // Direction: angled upward (positive Z) and outward (positive X)
    dx = wire_exit_len_mm * cos(wire_exit_angle_deg);
    dz = wire_exit_len_mm * sin(wire_exit_angle_deg);

    hull() {
        translate([start_x, 0, start_z])
            rotate([90,0,0]) cylinder(r=wire_diameter_mm/2, h=wire_diameter_mm, center=true);

        translate([start_x + dx, 0, start_z + dz])
            rotate([90,0,0]) cylinder(r=wire_diameter_mm/2, h=wire_diameter_mm, center=true);
    }
}

// ===== Assembly (ONE connected solid) =====
module bldc_motor() {
    union() {
        // Can + endbells
        motor_can_shell_with_vents();
        endbell_front();
        endbell_back();

        // Stator inside can (visual feature)
        stator_with_teeth();

        // Shaft (connected via front boss overlap)
        shaft();

        // Wire pigtail (connected via back endbell overlap)
        wire_pigtail();
    }
}

bldc_motor();