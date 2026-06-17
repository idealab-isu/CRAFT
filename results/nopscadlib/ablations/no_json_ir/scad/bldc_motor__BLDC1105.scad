$fn = 128;

// Target motor spec (stator)
stator_d = 14.0;     // mm (requested)
stator_h = 11.75;    // mm (requested)

// Simple BLDC-like details (kept connected as ONE solid)
housing_wall = 0.6;          // radial wall thickness
shaft_d = 2.0;               // output shaft diameter
shaft_len = 6.0;             // shaft protrusion above top
boss_d = 6.0;                // top boss diameter around shaft
boss_h = 1.2;                // top boss height

mount_flange_d = 16.0;       // small mounting flange diameter
mount_flange_t = 1.0;        // flange thickness (below can)
mount_hole_d = 1.6;          // mounting hole diameter
mount_hole_r = 5.5;          // radius to hole centers
mount_hole_count = 4;

vent_count = 6;              // side vents (shallow)
vent_w = 1.2;
vent_h = 4.0;
vent_depth = 0.5;

eps = 0.02;

// Derived
outer_d = stator_d + 2*housing_wall;  // can OD
can_h   = stator_h;                   // can height equals requested stator height

module can_shell() {
    // Outer can with shallow side vents (difference)
    difference() {
        cylinder(d=outer_d, h=can_h, center=true);

        // Shallow vents cut into the side wall (do not fully penetrate)
        for (i = [0:vent_count-1]) {
            rotate([0,0,i*360/vent_count])
                translate([outer_d/2 - vent_depth/2, 0, 0])
                    cube([vent_depth + eps, vent_w, vent_h], center=true);
        }
    }
}

module endcap_rings() {
    // Slight endcap lips (external rings) to suggest endcaps; kept within overall height
    lip_t = 0.35;
    lip_rad = 0.35;

    union() {
        translate([0,0, can_h/2 - lip_t/2])
            cylinder(d=outer_d + 2*lip_rad, h=lip_t, center=true);
        translate([0,0,-can_h/2 + lip_t/2])
            cylinder(d=outer_d + 2*lip_rad, h=lip_t, center=true);
    }
}

module top_boss_and_shaft() {
    // Boss sits on top face; shaft protrudes upward from boss
    union() {
        // Ensure overlap into can for robust connectivity
        translate([0,0, can_h/2 + boss_h/2 - 1.0*eps])
            cylinder(d=boss_d, h=boss_h + 2*eps, center=true);

        // Shaft starts inside boss slightly to guarantee union
        translate([0,0, can_h/2 + boss_h - 1.0*eps + shaft_len/2])
            cylinder(d=shaft_d, h=shaft_len + 2*eps, center=true);
    }
}

module mounting_flange() {
    // Flange attached to bottom face; overlap into can for connectivity
    translate([0,0, -can_h/2 - mount_flange_t/2 + 1.0*eps])
        cylinder(d=mount_flange_d, h=mount_flange_t + 2*eps, center=true);
}

module mounting_holes() {
    // Through flange only (not through can)
    hole_h = mount_flange_t + 4*eps;
    zc = -can_h/2 - mount_flange_t/2 + 1.0*eps;

    for (i = [0:mount_hole_count-1]) {
        rotate([0,0,i*360/mount_hole_count])
            translate([mount_hole_r, 0, zc])
                cylinder(d=mount_hole_d, h=hole_h, center=true);
    }
}

module motor() {
    difference() {
        union() {
            can_shell();
            endcap_rings();
            top_boss_and_shaft();
            mounting_flange();
        }
        mounting_holes();
    }
}

motor();