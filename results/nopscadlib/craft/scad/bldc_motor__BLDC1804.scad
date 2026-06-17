$fn = 128;

// Requested key dimensions
stator_diameter_mm = 23.0;   //[11.5:46.0:0.5]
stator_height_mm   = 12.0;   //[6.0:24.0:0.5]

// Motor construction parameters (kept simple but recognizable)
air_gap_radial_mm        = 0.5;  //[0.2:1.5:0.1]
can_wall_thickness_mm    = 0.8;  //[0.4:2.0:0.1]
endbell_thickness_mm     = 1.2;  //[0.5:3.0:0.1]
shaft_diameter_mm        = 3.0;  //[1.5:6.0:0.1]
shaft_front_length_mm    = 8.0;  //[2.0:20.0:0.5]
shaft_back_length_mm     = 3.0;  //[1.0:10.0:0.5]
boss_diameter_mm         = 10.0; //[6.0:16.0:0.5]
boss_height_mm           = 2.0;  //[1.0:6.0:0.2]
mount_hole_diameter_mm   = 2.0;  //[1.5:4.0:0.1]
mount_hole_circle_mm     = 16.0; //[10.0:22.0:0.5]
mount_hole_count         = 4;    //[2:8]
stator_tooth_count       = 12;   //[6:18]
stator_tooth_depth_mm    = 1.2;  //[0.6:2.5:0.1]
stator_tooth_width_mm    = 2.0;  //[1.0:4.0:0.1]
overlap_mm               = 0.4;  //[0.2:1.0:0.1]

// Derived dimensions
stator_r = stator_diameter_mm/2;
rotor_inner_r = stator_r + air_gap_radial_mm;
rotor_outer_r = rotor_inner_r + can_wall_thickness_mm;

motor_body_h = stator_height_mm; // enforce requested height for the motor body (excluding shaft)
z_top = motor_body_h/2;
z_bot = -motor_body_h/2;

// Safety clamps to avoid empty/invalid geometry
endbell_t = min(endbell_thickness_mm, motor_body_h/2 - 0.2);
boss_h    = boss_height_mm;
shaft_r   = max(0.2, shaft_diameter_mm/2);

module stator_teeth(r_base, h, n, tooth_depth, tooth_w) {
    // Teeth protrude outward from stator OD; overlap into stator for connectivity
    for (i = [0:n-1]) {
        rotate([0,0,i*360/n])
            translate([r_base + tooth_depth/2 - overlap_mm, 0, 0])
                cube([tooth_depth, tooth_w, h], center=true);
    }
}

module motor_solid() {
    union() {
        // Outer rotor can (solid exterior)
        cylinder(r=rotor_outer_r, h=motor_body_h, center=true);

        // Front endbell (slight lip) - overlaps into can
        translate([0,0, z_top - endbell_t/2])
            cylinder(r=rotor_outer_r, h=endbell_t + overlap_mm, center=true);

        // Back endbell - overlaps into can
        translate([0,0, z_bot + endbell_t/2])
            cylinder(r=rotor_outer_r, h=endbell_t + overlap_mm, center=true);

        // Front boss around shaft - overlaps into front endbell
        translate([0,0, z_top + boss_h/2 - overlap_mm])
            cylinder(r=boss_diameter_mm/2, h=boss_h + 2*overlap_mm, center=true);

        // Shaft (front + back), connected through body
        cylinder(r=shaft_r,
                 h=motor_body_h + shaft_front_length_mm + shaft_back_length_mm,
                 center=true);

        // Internal stator core + teeth (recognizable BLDC structure)
        // Ensure positive height and keep it inside the can
        stator_core_r = max(0.2, stator_r - 0.6);
        stator_h = max(0.5, motor_body_h - 2*endbell_t);

        union() {
            cylinder(r=stator_core_r, h=stator_h, center=true);
            stator_teeth(stator_r - 0.2, stator_h, stator_tooth_count,
                         stator_tooth_depth_mm, stator_tooth_width_mm);
        }
    }
}

module motor_voids() {
    union() {
        // Hollow inside rotor can (leave wall thickness)
        // Keep endbells mostly solid by limiting void height
        inner_void_h = max(0.5, motor_body_h - 2*endbell_t + 2*overlap_mm);
        cylinder(r=rotor_inner_r, h=inner_void_h, center=true);

        // Mounting holes through front endbell/boss region
        hole_h = endbell_t + boss_h + 2*overlap_mm;

        // Center holes within the boss+endbell stack so they always cut through it
        z_holes = z_top + (boss_h - endbell_t)/2 - overlap_mm;

        for (i = [0:mount_hole_count-1]) {
            rotate([0,0,i*360/mount_hole_count])
                translate([mount_hole_circle_mm/2, 0, z_holes])
                    cylinder(r=mount_hole_diameter_mm/2, h=hole_h, center=true);
        }
    }
}

difference() {
    motor_solid();
    motor_voids();
}