$fn=128;

// Brushless DC motor (simplified) with 28mm stator diameter and 27mm height
stator_d = 28.0;
motor_h  = 27.0;

// Simple proportions for a typical small BLDC motor
can_wall = 1.0;
can_d    = stator_d + 2*can_wall;     // outer can diameter
base_h   = 2.0;
can_h    = motor_h - base_h;

shaft_d  = 3.0;
shaft_h  = 10.0;

mount_hole_d = 2.0;
mount_hole_r = (stator_d/2) - 3.0;    // approximate bolt circle radius
mount_hole_z = 0.0;

module motor_can() {
    // Outer can with hollow interior
    difference() {
        cylinder(d=can_d, h=can_h);
        translate([0,0,0.5])
            cylinder(d=stator_d, h=can_h); // hollow to stator diameter
    }
}

module motor_base() {
    // Base plate with mounting holes
    difference() {
        cylinder(d=can_d, h=base_h);
        for (a = [0:90:270]) {
            translate([mount_hole_r*cos(a), mount_hole_r*sin(a), mount_hole_z])
                cylinder(d=mount_hole_d, h=base_h+0.5);
        }
    }
}

module motor_shaft() {
    translate([0,0,can_h])
        cylinder(d=shaft_d, h=shaft_h);
}

module motor() {
    union() {
        // Can sits on base
        translate([0,0,base_h]) motor_can();
        motor_base();
        motor_shaft();
    }
}

motor();