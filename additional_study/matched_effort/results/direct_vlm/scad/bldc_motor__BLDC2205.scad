$fn = 128;

// Brushless DC motor with 28.0mm stator diameter and 17.25mm height
// One connected solid; all placements derived from dimensions (no arbitrary offsets).

stator_d = 28.0;     // overall can OD (matches requested stator diameter)
motor_h  = 17.25;    // overall can height (matches requested height)

// Can / bell
can_wall      = 1.0;
top_cap_h     = 1.2;
bottom_cap_h  = 1.6;

// Shaft
shaft_d     = 3.0;
shaft_above = 10.0;
shaft_below = 2.0;

// Mounting flange + pattern
flange_h   = 1.2;
flange_od  = stator_d * 0.92;
flange_id  = flange_od - 3.0;

bolt_circle_d = flange_od * 0.72;
bolt_hole_d   = 2.2;
bolt_count    = 4;

// Bosses
top_boss_d = 8.0;
top_boss_h = 1.5;

bot_boss_d = 7.0;
bot_boss_h = 1.2;

// Side wire exit (attached)
wire_nub_w = 5.0;
wire_nub_t = 2.5;
wire_nub_h = 3.0;

// Vent slots (cutouts)
vent_count = 10;
vent_w     = 2.0;
vent_len   = 6.0;
vent_h     = top_cap_h + 0.4;

// Overlap to guarantee manifold unions
ov = 0.25;

module can_shell() {
    // Outer can with internal cavity
    difference() {
        cylinder(d=stator_d, h=motor_h);

        // Inner cavity: leave bottom and top caps
        translate([0, 0, bottom_cap_h])
            cylinder(d=stator_d - 2*can_wall, h=motor_h - bottom_cap_h - top_cap_h);

        // Vent slots cut into top cap region
        for (i = [0:vent_count-1]) {
            rotate([0, 0, i*360/vent_count])
                translate([stator_d/2 - can_wall - vent_len/2 + 0.2, 0, motor_h - top_cap_h/2])
                    cube([vent_len, vent_w, vent_h], center=true);
        }
    }
}

module flange_with_holes() {
    // Bottom mounting flange ring with bolt holes
    difference() {
        cylinder(d=flange_od, h=flange_h);
        translate([0,0,-0.01]) cylinder(d=flange_id, h=flange_h + 0.02);

        for (i = [0:bolt_count-1]) {
            rotate([0, 0, i*360/bolt_count])
                translate([bolt_circle_d/2, 0, -0.01])
                    cylinder(d=bolt_hole_d, h=flange_h + 0.02);
        }
    }
}

module wire_exit() {
    // Nub + strain relief, intersecting can wall by ov for connectivity
    x_face = stator_d/2 - wire_nub_t/2 - ov;

    union() {
        // Round nub (axis along X)
        translate([x_face, 0, flange_h + wire_nub_h/2])
            rotate([0, 90, 0])
                cylinder(d=wire_nub_h, h=wire_nub_t + 2*ov, center=true);

        // Strain relief block
        translate([stator_d/2 - wire_nub_t - ov, -wire_nub_w/2, flange_h])
            cube([wire_nub_t + 2*ov, wire_nub_w, wire_nub_h], center=false);
    }
}

module shaft_and_bosses() {
    union() {
        // Shaft through motor, protruding above/below
        translate([0, 0, -shaft_below])
            cylinder(d=shaft_d, h=motor_h + shaft_above + shaft_below);

        // Top boss overlaps into can by ov
        translate([0, 0, motor_h - top_boss_h - ov])
            cylinder(d=top_boss_d, h=top_boss_h + ov);

        // Bottom boss overlaps into flange/can by ov
        translate([0, 0, 0])
            cylinder(d=bot_boss_d, h=bot_boss_h + ov);
    }
}

module rotor_ribs() {
    // External ribs fused to can; ensure they protrude slightly beyond can OD
    rib_count = 12;
    rib_w     = 1.2;
    rib_len   = 2.0;
    rib_h     = motor_h * 0.65;

    rib_z0 = bottom_cap_h + (motor_h - bottom_cap_h - top_cap_h - rib_h)/2;

    for (i = [0:rib_count-1]) {
        rotate([0, 0, i*360/rib_count])
            translate([stator_d/2 - rib_len/2 - ov, 0, rib_z0])
                cube([rib_len + 2*ov, rib_w, rib_h], center=false);
    }
}

union() {
    // Main motor body: can + flange + ribs + wire exit
    union() {
        can_shell();

        // Bottom cap lip (slight step) - stays within stator_d
        cylinder(d=stator_d*0.96, h=bottom_cap_h);

        // Top cap lip (slight step) - stays within stator_d
        translate([0, 0, motor_h - top_cap_h])
            cylinder(d=stator_d*0.98, h=top_cap_h);

        // Mounting flange attached at z=0 (overlaps into can by ov)
        translate([0, 0, 0])
            union() {
                flange_with_holes();
                // tiny overlap collar to guarantee fusion with can even if flange_od < stator_d
                cylinder(d=min(stator_d, flange_od) + 2*ov, h=ov);
            }

        rotor_ribs();
        wire_exit();
    }

    // Shaft and bosses (connected through can)
    shaft_and_bosses();
}