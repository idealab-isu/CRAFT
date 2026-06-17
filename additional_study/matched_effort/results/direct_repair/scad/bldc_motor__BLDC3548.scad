$fn=128;

// Brushless DC motor (approximate) with 35mm stator diameter and 45mm height
stator_d = 35.0;
motor_h  = 45.0;

// Simple param choices for a plausible BLDC can motor
can_wall = 1.2;
can_d    = stator_d + 2*can_wall;     // outer can diameter
endcap_h = 3.0;
body_h   = motor_h - 2*endcap_h;

shaft_d  = 5.0;
shaft_h  = 12.0;

mount_boss_d = 22.0;
mount_boss_h = 2.0;

wire_exit_w = 8.0;
wire_exit_h = 4.0;
wire_exit_l = 6.0;

module motor_can() {
    // Outer can with inner cavity
    difference() {
        union() {
            // main cylinder
            cylinder(d=can_d, h=motor_h);
            // slight lip at top
            translate([0,0,motor_h-1.0]) cylinder(d=can_d+0.6, h=1.0);
        }
        // inner cavity (leave endcaps solid-ish)
        translate([0,0,endcap_h])
            cylinder(d=stator_d+0.6, h=body_h);
    }
}

module endcap_details() {
    // Bottom mounting boss and wire exit
    union() {
        // bottom boss
        translate([0,0,0])
            cylinder(d=mount_boss_d, h=mount_boss_h);

        // wire exit block on side near bottom
        translate([can_d/2 - 0.5, 0, mount_boss_h + 2.0])
            rotate([0,90,0])
                hull() {
                    translate([0,0,0]) cylinder(d=wire_exit_h, h=wire_exit_l);
                    translate([0,wire_exit_w/2,0]) cylinder(d=wire_exit_h, h=wire_exit_l);
                    translate([0,-wire_exit_w/2,0]) cylinder(d=wire_exit_h, h=wire_exit_l);
                }

        // top endcap slight dome
        translate([0,0,motor_h-endcap_h])
            intersection() {
                cylinder(d=can_d, h=endcap_h);
                translate([0,0,-(can_d/2)])
                    sphere(d=can_d*1.05);
            }
    }
}

module shaft() {
    // Shaft protruding from top
    translate([0,0,motor_h])
        cylinder(d=shaft_d, h=shaft_h);
    // small shoulder at top face
    translate([0,0,motor_h-0.8])
        cylinder(d=10.0, h=0.8);
}

module mounting_holes() {
    // Typical 4x M3-ish pattern on 16mm bolt circle (approx)
    bolt_circle = 16.0;
    hole_d = 3.2;
    for (a=[0:90:270]) {
        translate([ (bolt_circle/2)*cos(a), (bolt_circle/2)*sin(a), -0.1 ])
            cylinder(d=hole_d, h=mount_boss_h+0.4);
    }
}

module motor() {
    difference() {
        union() {
            motor_can();
            endcap_details();
            shaft();
        }
        // mounting holes through bottom boss
        mounting_holes();

        // small flat on can side (for realism)
        translate([can_d/2 - 0.6, 0, motor_h/2])
            rotate([0,90,0])
                cylinder(d=10, h=2.0, center=true);
    }
}

motor();