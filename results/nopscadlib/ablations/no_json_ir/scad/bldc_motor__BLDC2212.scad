$fn = 140;

// Target: BLDC motor with 28.0mm stator diameter and 27.0mm overall height
stator_d = 28.0;
motor_h  = 27.0;

// Housing / can
wall = 1.2;                 // housing wall thickness
can_d = stator_d + 2*wall;  // outer can diameter (keeps stator_d meaningful)
base_th = 2.2;              // bottom endbell thickness
top_th  = 2.2;              // top endbell thickness
can_h   = motor_h - base_th - top_th;

// Shaft / boss
shaft_d = 3.0;
shaft_above = 8.0;          // shaft protrusion above top
shaft_below = 2.0;          // small protrusion below base
boss_d = 10.0;
boss_h = 2.0;

// Mounting
mount_bolt_d = 3.0;
mount_circle_d = 19.0;
mount_hole_depth = base_th + 0.8;

// Visual features (external)
lip_h = 0.8;                // small endbell lip height
lip_over = 0.6;             // lip radial overhang
vent_count = 8;             // top endbell vents
vent_w = 2.2;
vent_l = (can_d/2) - 2.0;
vent_h = 0.9;

wire_exit_w = 6.0;          // wiring grommet block (connected)
wire_exit_t = 2.6;
wire_exit_h = 3.2;
wire_exit_z = base_th + 2.0; // on can wall, near base

// Internal visual detail (subtractive only; keeps one connected solid)
stator_ring_th = 2.0;
stator_inner_d = stator_d - 2*stator_ring_th;
rotor_clear = 0.6;
rotor_d = stator_inner_d - 2*rotor_clear;

eps = 0.05;
overlap = 0.6;

module motor_model() {

    difference() {
        union() {
            // Main outer can + endbells (single connected solid)
            cylinder(h = motor_h, d = can_d);

            // Endbell lips (connected, slight overhang)
            translate([0,0,0])
                cylinder(h = lip_h, d1 = can_d + 2*lip_over, d2 = can_d);
            translate([0,0,motor_h - lip_h])
                cylinder(h = lip_h, d1 = can_d, d2 = can_d + 2*lip_over);

            // Top boss (connected)
            translate([0, 0, motor_h - boss_h])
                cylinder(h = boss_h, d = boss_d);

            // Shaft (connected through top and into base)
            translate([0, 0, -shaft_below])
                cylinder(h = motor_h + shaft_above + shaft_below, d = shaft_d);

            // Top endbell vents/ribs (connected)
            for (i = [0:vent_count-1]) {
                rotate([0,0,i*360/vent_count])
                    translate([vent_l/2, 0, motor_h - top_th + vent_h/2])
                        cube([vent_l, vent_w, vent_h], center=true);
            }

            // Wiring exit / grommet block (connected to can wall)
            // Place so its inner face overlaps into the can by 'overlap'
            translate([ (can_d/2) + wire_exit_t/2 - overlap, 0, wire_exit_z + wire_exit_h/2 ])
                cube([wire_exit_t, wire_exit_w, wire_exit_h], center=true);

            // Small strain-relief bump on grommet (connected)
            translate([ (can_d/2) + wire_exit_t - overlap - 0.2, 0, wire_exit_z + wire_exit_h/2 ])
                rotate([0,90,0])
                    cylinder(h = 1.6, d = 3.0, center=true);
        }

        // Hollow interior (leave endbells solid)
        translate([0, 0, base_th])
            cylinder(h = can_h, d = can_d - 2*wall);

        // Internal stator/rotor suggestion: step + rotor cavity (subtractive)
        // Stator ring cavity (slight step)
        translate([0, 0, base_th + 0.3])
            cylinder(h = can_h - 0.6, d = stator_d + 0.2);

        // Rotor cavity
        translate([0, 0, base_th + 0.6])
            cylinder(h = can_h - 1.2, d = rotor_d);

        // Mounting holes in base (through base only)
        for (i = [0:3]) {
            rotate([0, 0, i*90])
                translate([mount_circle_d/2, 0, -eps])
                    cylinder(h = mount_hole_depth + 2*eps, d = mount_bolt_d);
        }

        // Bottom edge relief (visual chamfer-like)
        translate([0, 0, -eps])
            cylinder(h = 0.9, d1 = can_d + 0.8, d2 = can_d - 0.8);

        // Top face shallow recess around boss (visual)
        recess_d = boss_d + 6.0;
        recess_h = 0.6;
        translate([0,0,motor_h - recess_h + eps])
            cylinder(h = recess_h + eps, d = recess_d);

        // Wire exit notch (suggest cable path) - subtract a small channel in grommet
        channel_d = 2.2;
        channel_len = wire_exit_t + 1.2;
        translate([ (can_d/2) + channel_len/2 - overlap, 0, wire_exit_z + wire_exit_h/2 ])
            rotate([0,90,0])
                cylinder(h = channel_len, d = channel_d, center=true);
    }
}

motor_model();