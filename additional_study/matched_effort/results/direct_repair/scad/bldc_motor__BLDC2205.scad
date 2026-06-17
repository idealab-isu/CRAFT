$fn = 128;

// Brushless DC motor (generic) based on stator diameter 28.0mm and height 17.25mm
// Dimensions are approximate for a typical outrunner-style motor around a 28mm stator class.

stator_d = 28.0;
stator_h = 17.25;

// Derived / assumed dimensions
motor_od = 35.0;          // outer can diameter (typical for 28mm stator class)
can_h = stator_h + 2.75;  // outer can height slightly taller than stator
base_h = 3.0;             // mounting base thickness
base_od = motor_od + 4.0; // base flange diameter
shaft_d = 3.175;          // 1/8" shaft common
shaft_len = 18.0;         // exposed shaft length above can
top_boss_d = 10.0;        // top hub/boss around shaft
top_boss_h = 2.0;

mount_hole_d = 3.0;
mount_hole_circle_d = 25.0; // typical M3 pattern for this size
mount_hole_count = 4;

wire_exit_w = 6.0;
wire_exit_h = 3.0;
wire_exit_len = 10.0;

module bolt_circle_holes(count, circle_d, hole_d, h, z0=0) {
    for (i = [0:count-1]) {
        a = 360*i/count;
        translate([circle_d/2*cos(a), circle_d/2*sin(a), z0])
            cylinder(d=hole_d, h=h, center=false);
    }
}

module motor() {
    union() {
        // Base / mounting plate
        difference() {
            cylinder(d=base_od, h=base_h);
            // center clearance
            translate([0,0,-0.1]) cylinder(d=stator_d-6, h=base_h+0.2);
            // mounting holes
            translate([0,0,-0.1])
                bolt_circle_holes(mount_hole_count, mount_hole_circle_d, mount_hole_d, base_h+0.2);
        }

        // Stator (internal reference geometry)
        translate([0,0,base_h])
            color([0.6,0.6,0.6])
                cylinder(d=stator_d, h=stator_h);

        // Outer can (rotor housing)
        translate([0,0,base_h])
        difference() {
            color([0.2,0.2,0.2])
                cylinder(d=motor_od, h=can_h);
            // hollow interior
            translate([0,0,1.0])
                cylinder(d=motor_od-2.0, h=can_h-1.0);
            // bottom opening to show stator area
            translate([0,0,-0.1])
                cylinder(d=motor_od-1.0, h=1.2);
        }

        // Top boss
        translate([0,0,base_h+can_h])
            color([0.25,0.25,0.25])
                cylinder(d=top_boss_d, h=top_boss_h);

        // Shaft
        translate([0,0,base_h+can_h+top_boss_h])
            color([0.75,0.75,0.75])
                cylinder(d=shaft_d, h=shaft_len);

        // Simple wire exit block on side near base
        translate([motor_od/2 - 1.0, 0, base_h + 2.0])
            rotate([0,90,0])
                color([0.1,0.1,0.1])
                    cube([wire_exit_len, wire_exit_w, wire_exit_h], center=true);
    }
}

motor();