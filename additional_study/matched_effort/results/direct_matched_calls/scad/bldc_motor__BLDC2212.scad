$fn=128;

// Parameters
stator_d = 28.0;
motor_h  = 27.0;

// Simple BLDC motor representation (approximate outer can + base + shaft)
can_wall = 1.2;
can_d    = stator_d + 2*can_wall;   // outer can diameter
base_h   = 2.5;
top_h    = 2.0;
shaft_d  = 3.0;
shaft_h  = 10.0;

module bldc_motor() {
    // Body (outer can)
    color([0.75,0.75,0.78])
    difference() {
        cylinder(d=can_d, h=motor_h);
        // Hollow interior (leave some thickness and a base)
        translate([0,0,base_h])
            cylinder(d=can_d-2*can_wall, h=motor_h-base_h-top_h);
    }

    // Base plate
    color([0.55,0.55,0.58])
    cylinder(d=can_d, h=base_h);

    // Top cap
    color([0.65,0.65,0.68])
    translate([0,0,motor_h-top_h])
        cylinder(d=can_d, h=top_h);

    // Stator (visual reference)
    color([0.25,0.25,0.28])
    translate([0,0,base_h])
        cylinder(d=stator_d, h=motor_h-base_h-top_h);

    // Shaft
    color([0.85,0.85,0.88])
    translate([0,0,motor_h])
        cylinder(d=shaft_d, h=shaft_h);

    // Simple mounting holes on base (optional visual)
    hole_d = 2.0;
    hole_r = (can_d/2) - 3.0;
    color([0.75,0.75,0.78])
    difference() {
        // no-op solid to subtract from: use thin ring at base for holes
        translate([0,0,0])
            cylinder(d=can_d, h=base_h);
        for (a=[0:90:270]) {
            translate([hole_r*cos(a), hole_r*sin(a), -0.1])
                cylinder(d=hole_d, h=base_h+0.2);
        }
    }
}

bldc_motor();