$fn = 180;

// Brushless DC motor (recognizable, one connected solid)
// Requirement: stator OD = 23.0mm, stator height = 12.0mm
stator_d = 23.0;
stator_h = 12.0;

eps = 0.25;
overlap = 0.6; // intentional overlaps to guarantee connectivity

// Can / housing proportions (typical small outrunner/inrunner can)
can_wall = 0.9;
can_d = stator_d + 2*can_wall;          // outer can diameter
can_h = stator_h + 4.0;                 // endbells add height

// Endbells
front_endbell_h = 2.0;                  // shaft side
rear_endbell_h  = 2.0;                  // wire side
endbell_step_h  = 0.8;
endbell_step_d  = can_d - 1.2;

// Shaft
shaft_d = 3.0;
shaft_above = 10.0;
shaft_below = 2.0;

// Rear mounting boss + holes
mount_boss_d = 12.0;
mount_boss_h = 1.6;
mount_hole_d = 2.2;
mount_hole_r = 7.5;                     // bolt circle radius

// Side wire exit
wire_exit_w = 6.0;
wire_exit_t = 2.6;
wire_exit_h = 3.2;

// Internal stator/rotor (visible via silhouette features)
stator_id = 14.0;
rotor_d = stator_id - 0.6;

// Stator tooth hints (external bumps aligned to stator region)
tooth_count = 12;
tooth_w = 2.2;                          // tangential width
tooth_len = 1.2;                        // radial protrusion
tooth_h = stator_h * 0.85;              // axial height of bumps

// Placement along Z (motor axis)
z0 = 0;
z_can_top = z0 + can_h;

z_front_endbell_bot = z0;
z_front_endbell_top = z_front_endbell_bot + front_endbell_h;

z_rear_endbell_top = z_can_top;
z_rear_endbell_bot = z_rear_endbell_top - rear_endbell_h;

z_inner_bot = z_front_endbell_top;
z_inner_top = z_rear_endbell_bot;
inner_h = z_inner_top - z_inner_bot;

// Stator centered in inner cavity
z_stator_bot = z_inner_bot + (inner_h - stator_h)/2;
z_stator_top = z_stator_bot + stator_h;
z_stator_mid = (z_stator_bot + z_stator_top)/2;

z_rotor_bot  = z_stator_bot + 0.3;

// ---------- Modules ----------
module can_shell() {
    // Outer can with subtle side ribs; interior hollowed (endbells remain solid)
    difference() {
        union() {
            // Main can
            cylinder(d=can_d, h=can_h);

            // Two shallow external ribs (opposite) for recognizable can features
            rib_t = 1.2;
            rib_w = can_d*0.35;
            rib_h = can_h*0.85;
            for (a = [0, 180]) {
                rotate([0,0,a])
                    translate([can_d/2 - rib_t/2 + overlap/2, 0, can_h/2])
                        cube([rib_t, rib_w, rib_h], center=true);
            }
        }

        // Hollow interior (leave endbells solid)
        translate([0,0,z_inner_bot - eps])
            cylinder(d=stator_d + 0.8, h=inner_h + 2*eps);

        // Front bearing pocket (visual recess)
        translate([0,0,z_front_endbell_bot + 0.4])
            cylinder(d=8.0, h=front_endbell_h - 0.6);

        // Rear recess (visual)
        translate([0,0,z_rear_endbell_bot + 0.4])
            cylinder(d=10.0, h=rear_endbell_h - 0.6);
    }
}

module endbell_steps() {
    union() {
        // Front step
        translate([0,0,z_front_endbell_top - endbell_step_h])
            cylinder(d=endbell_step_d, h=endbell_step_h);

        // Rear step
        translate([0,0,z_rear_endbell_bot])
            cylinder(d=endbell_step_d, h=endbell_step_h);
    }
}

module shaft_solid() {
    // Shaft overlaps into endbells and out of can
    translate([0,0,-shaft_below])
        cylinder(d=shaft_d, h=can_h + shaft_above + shaft_below);
}

module rear_mount_boss() {
    // Boss on rear face (wire side). Ensure it overlaps into rear endbell.
    translate([0,0,z0])
        cylinder(d=mount_boss_d, h=mount_boss_h + overlap);
}

module wire_exit_block() {
    // Side wire exit on rear end (connected to can)
    x = can_d/2 - wire_exit_t/2 + overlap; // overlap into can
    z = z_rear_endbell_bot + wire_exit_h/2;
    translate([x, 0, z])
        rotate([0,90,0])
            cube([wire_exit_h, wire_exit_w, wire_exit_t], center=true);
}

module internal_stator_rotor_solid() {
    // Internal solids (not subtracted) to suggest BLDC structure
    union() {
        // Stator ring (OD exactly 23mm, height exactly 12mm)
        translate([0,0,z_stator_bot])
            difference() {
                cylinder(d=stator_d, h=stator_h);
                translate([0,0,-eps]) cylinder(d=stator_id, h=stator_h + 2*eps);
            }

        // Rotor sleeve
        translate([0,0,z_rotor_bot])
            cylinder(d=rotor_d, h=stator_h - 0.6);
    }
}

module stator_tooth_bumps() {
    // External bumps aligned with stator region to make stator size recognizable in silhouette
    // Bumps start slightly inside can surface and protrude outward.
    bump_h = tooth_h;
    bump_z = z_stator_mid;
    // Place bumps so their inner face overlaps into the can by 'overlap'
    // Inner edge radius = can_d/2 - overlap
    translate([0,0,bump_z])
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*360/tooth_count])
                translate([can_d/2 + tooth_len/2 - overlap, 0, 0])
                    cube([tooth_len, tooth_w, bump_h], center=true);
        }
}

module mount_holes_cut() {
    // 4 mounting holes through rear boss
    for (i = [0:3]) {
        rotate([0,0,i*90])
            translate([mount_hole_r, 0, -eps])
                cylinder(d=mount_hole_d, h=mount_boss_h + overlap + 2*eps);
    }
}

module bldc_motor() {
    // One connected solid; holes cut at end.
    difference() {
        union() {
            can_shell();
            endbell_steps();
            shaft_solid();
            rear_mount_boss();
            wire_exit_block();
            internal_stator_rotor_solid();
            stator_tooth_bumps();
        }
        mount_holes_cut();
    }
}

bldc_motor();