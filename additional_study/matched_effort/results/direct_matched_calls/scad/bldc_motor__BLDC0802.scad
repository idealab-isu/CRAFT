$fn=128;

// Brushless DC motor (simplified) with stator: 11.5mm diameter, 9.5mm height
// Model includes: stator core, outer can, top cap, bottom base, shaft, and 3 phase wires.

stator_d = 11.5;
stator_h = 9.5;

// Assumed proportions for a small BLDC motor around the given stator size
air_gap = 0.25;
can_wall = 0.6;

rotor_od = stator_d + 2*air_gap;
can_od   = rotor_od + 2*can_wall;

motor_h = stator_h + 3.0;     // total motor height (approx)
base_h  = 1.2;
top_h   = 1.0;

shaft_d = 2.0;
shaft_above = 6.0;
shaft_below = 1.5;

wire_d = 0.9;
wire_len = 18;

module wire_cylinder(len, d){
    rotate([0,90,0]) cylinder(h=len, d=d, center=false);
}

module motor(){
    union(){
        // Outer can (shell)
        color([0.65,0.65,0.68])
        difference(){
            translate([0,0,base_h])
                cylinder(h=motor_h-base_h, d=can_od);
            translate([0,0,base_h+0.2])
                cylinder(h=motor_h-base_h-0.4, d=can_od-2*can_wall);
        }

        // Bottom base plate
        color([0.55,0.55,0.58])
        cylinder(h=base_h, d=can_od);

        // Top cap
        color([0.55,0.55,0.58])
        translate([0,0,motor_h-top_h])
            cylinder(h=top_h, d=can_od);

        // Stator core (given dimensions)
        color([0.25,0.25,0.28])
        translate([0,0,(motor_h-stator_h)/2])
            cylinder(h=stator_h, d=stator_d);

        // Rotor (inside can, around stator)
        color([0.35,0.35,0.38])
        translate([0,0,(motor_h-stator_h)/2])
        difference(){
            cylinder(h=stator_h, d=rotor_od);
            cylinder(h=stator_h+0.2, d=stator_d+0.2);
        }

        // Shaft
        color([0.75,0.75,0.78])
        translate([0,0,-shaft_below])
            cylinder(h=motor_h + shaft_above + shaft_below, d=shaft_d);

        // Simple wire bundle exiting near bottom side
        wire_z = base_h*0.6;
        wire_r = can_od/2 - 0.2;

        color([0.9,0.1,0.1])
        translate([wire_r, 0, wire_z]) wire_cylinder(wire_len, wire_d);

        color([0.1,0.7,0.1])
        translate([wire_r, 1.4, wire_z]) wire_cylinder(wire_len, wire_d);

        color([0.1,0.2,0.9])
        translate([wire_r, -1.4, wire_z]) wire_cylinder(wire_len, wire_d);
    }
}

motor();