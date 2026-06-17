$fn=128;

// Brushless DC motor (approximate) with 35mm stator diameter and 45mm height
stator_d = 35.0;
motor_h  = 45.0;

// Simple proportions for a typical outrunner-style BLDC
can_wall = 1.5;
can_d    = stator_d + 2*can_wall;   // outer can diameter
can_h    = motor_h * 0.78;          // main can height
base_h   = motor_h - can_h;         // base/mount height

shaft_d  = 5.0;
shaft_h  = motor_h * 0.35;

mount_boss_d = stator_d * 0.55;
mount_boss_h = base_h * 0.65;

wire_exit_w = 8.0;
wire_exit_h = 4.0;
wire_exit_l = 10.0;

module motor_body() {
    // Base + mount boss
    union() {
        // Base plate
        difference() {
            cylinder(d=stator_d*0.98, h=base_h);
            // center relief
            translate([0,0,-0.1]) cylinder(d=stator_d*0.55, h=base_h+0.2);
            // mounting holes (4x)
            for (a=[0:90:270]) {
                rotate([0,0,a])
                    translate([stator_d*0.33,0,-0.1])
                        cylinder(d=3.0, h=base_h+0.2);
            }
        }

        // Mount boss
        translate([0,0,base_h - mount_boss_h])
            cylinder(d=mount_boss_d, h=mount_boss_h);

        // Outer can (shell)
        translate([0,0,base_h])
        difference() {
            cylinder(d=can_d, h=can_h);
            translate([0,0,0.8])
                cylinder(d=stator_d+0.6, h=can_h); // inner cavity
            // ventilation slots
            for (a=[0:30:330]) {
                rotate([0,0,a])
                    translate([can_d*0.38,0,can_h*0.25])
                        cube([can_wall*1.2, 6.0, can_h*0.55], center=true);
            }
        }

        // Top cap lip
        translate([0,0,base_h+can_h-1.2])
            cylinder(d=can_d*0.98, h=1.2);

        // Shaft
        translate([0,0,base_h+can_h-0.2])
            cylinder(d=shaft_d, h=shaft_h);

        // Wire exit block on base side
        translate([stator_d*0.45, 0, base_h*0.35])
            cube([wire_exit_l, wire_exit_w, wire_exit_h], center=true);
    }
}

module stator_hint() {
    // Visual hint of stator inside (not physically accurate)
    translate([0,0,base_h+1.5])
    color([0.6,0.6,0.6])
    difference() {
        cylinder(d=stator_d, h=can_h-3.0);
        translate([0,0,-0.1]) cylinder(d=stator_d*0.55, h=can_h-2.8);
        for (a=[0:20:340]) {
            rotate([0,0,a])
                translate([stator_d*0.38,0,(can_h-3.0)/2])
                    cube([2.0, 4.0, can_h-3.0], center=true);
        }
    }
}

motor_body();
stator_hint();