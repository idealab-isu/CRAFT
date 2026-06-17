// Brushless DC motor (single connected solid)
// Target: 28.0mm stator diameter, 27.0mm stator height

$fn = 128;

// -------------------- Parameters --------------------
stator_diameter = 28.0; //[14.0:56.0:0.5]
stator_height   = 27.0; //[13.5:54.0:0.5]

airgap              = 0.4;  // visual airgap between stator OD and rotor ID
rotor_can_thickness = 1.0;  //[0.5:2.0:0.1]
endbell_thickness   = 2.0;  //[1.0:4.0:0.1]

shaft_diameter = 5.0;  //[2.5:10.0:0.1]
shaft_length   = 40.0; //[20.0:80.0:0.5]

mounting_flange_diameter  = 34.0; //[17.0:68.0:0.5]
mounting_flange_thickness = 2.5;  //[1.25:5.0:0.1]

num_mount_holes   = 4;
mount_hole_d      = 3.0;
mount_hole_circle = 25.0;

num_stator_teeth = 12;
tooth_depth      = 2.0;
tooth_width      = 3.0;

num_can_ribs = 12;     // external ribs to avoid "buzzer can" look
rib_depth    = 0.8;
rib_width    = 2.2;

wire_exit_w = 6.0;     // small wire grommet block on side
wire_exit_h = 4.0;
wire_exit_l = 6.0;

clearance = 0.5; //[0.2:1.5:0.1]
overlap   = 1.0; //[0.5:2.0:0.1]

// -------------------- Derived --------------------
stator_r = stator_diameter/2;

// Rotor outer diameter derived from stator + airgap + can thickness (keeps stator diameter verifiable)
rotor_outer_diameter = stator_diameter + 2*(airgap + rotor_can_thickness);
rotor_r  = rotor_outer_diameter/2;

motor_body_h = stator_height + 2*endbell_thickness; // overall can height (excluding flange)
z_top_can    =  motor_body_h/2;
z_bot_can    = -motor_body_h/2;

// -------------------- Modules --------------------
module stator_with_teeth() {
    // Stator core + outward teeth (visual)
    union() {
        cylinder(r=stator_r, h=stator_height, center=true);

        for (i = [0:num_stator_teeth-1]) {
            rotate([0,0,i*360/num_stator_teeth])
                translate([stator_r + tooth_depth/2 - overlap, 0, 0])
                    cube([tooth_depth, tooth_width, stator_height], center=true);
        }
    }
}

module rotor_can_solid() {
    // Outer can (solid)
    cylinder(r=rotor_r, h=motor_body_h, center=true);
}

module can_ribs() {
    // External ribs connected to can OD
    for (i = [0:num_can_ribs-1]) {
        rotate([0,0,i*360/num_can_ribs])
            translate([rotor_r + rib_depth/2 - overlap, 0, 0])
                cube([rib_depth, rib_width, motor_body_h - 2*endbell_thickness], center=true);
    }
}

module endbell(zsign=1) {
    translate([0,0, zsign*(stator_height/2 + endbell_thickness/2 - overlap)])
        cylinder(r=rotor_r - rotor_can_thickness + overlap, h=endbell_thickness, center=true);
}

module mounting_flange() {
    translate([0,0, -(stator_height/2 + endbell_thickness + mounting_flange_thickness/2 - overlap)])
        cylinder(r=mounting_flange_diameter/2, h=mounting_flange_thickness, center=true);
}

module shaft() {
    cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
}

module wire_exit() {
    // Small side block to suggest wire exit; must connect to can
    translate([rotor_r + wire_exit_l/2 - overlap, 0, 0])
        cube([wire_exit_l, wire_exit_w, wire_exit_h], center=true);
}

module motor_solid() {
    difference() {
        union() {
            // Outer can + ribs
            rotor_can_solid();
            can_ribs();

            // Internal stator (unioned so still one connected solid)
            stator_with_teeth();

            // Endbells
            endbell(+1);
            endbell(-1);

            // Mounting flange
            mounting_flange();

            // Shaft
            shaft();

            // Wire exit feature
            wire_exit();
        }

        // Mounting holes through flange
        for (i = [0:num_mount_holes-1]) {
            rotate([0,0,i*360/num_mount_holes])
                translate([mount_hole_circle/2, 0,
                           -(stator_height/2 + endbell_thickness + mounting_flange_thickness/2 - overlap)])
                    cylinder(r=mount_hole_d/2, h=mounting_flange_thickness + 2*overlap, center=true, $fn=64);
        }

        // Front face recess (visual cue)
        translate([0,0, z_top_can - endbell_thickness/2])
            cylinder(r=rotor_r*0.55, h=endbell_thickness + 2*overlap, center=true, $fn=128);

        // Small flat on wire exit (suggest grommet opening)
        translate([rotor_r + wire_exit_l - wire_exit_l*0.35, 0, 0])
            rotate([0,90,0])
                cylinder(r=wire_exit_w*0.22, h=wire_exit_l + 2*overlap, center=true, $fn=48);
    }
}

motor_solid();