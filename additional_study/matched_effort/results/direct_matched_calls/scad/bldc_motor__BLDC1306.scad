$fn = 128;

// Brushless DC motor (simplified) with stator diameter 17.75mm and stator height 14.5mm
// Units: mm

stator_d = 17.75;
stator_h = 14.5;

// Simple proportions for a small BLDC motor representation
airgap = 0.35;
can_wall = 0.6;
can_overhang = 0.8;

can_d = stator_d + 2*(airgap + can_wall) + 2*can_overhang;
can_h = stator_h + 2.0;

endcap_h = 1.2;

shaft_d = 2.0;
shaft_front_len = 10.0;
shaft_rear_len  = 2.0;

mount_ring_h = 1.0;
mount_ring_d = can_d - 1.2;

wire_exit_w = 4.0;
wire_exit_t = 2.0;
wire_exit_h = 3.0;

module motor()
{
    union()
    {
        // Outer can
        color([0.65,0.65,0.68])
        difference()
        {
            cylinder(d=can_d, h=can_h);
            translate([0,0,can_wall])
                cylinder(d=can_d-2*can_wall, h=can_h-2*can_wall);
        }

        // Front endcap
        color([0.55,0.55,0.58])
        translate([0,0,0])
            cylinder(d=can_d-0.2, h=endcap_h);

        // Rear endcap
        color([0.55,0.55,0.58])
        translate([0,0,can_h-endcap_h])
            cylinder(d=can_d-0.2, h=endcap_h);

        // Stator (given dimensions)
        color([0.35,0.35,0.38])
        translate([0,0,(can_h-stator_h)/2])
            cylinder(d=stator_d, h=stator_h);

        // Rotor (simple inner cylinder)
        rotor_d = stator_d - 2.2;
        rotor_h = stator_h - 0.6;
        color([0.15,0.15,0.16])
        translate([0,0,(can_h-rotor_h)/2])
            cylinder(d=rotor_d, h=rotor_h);

        // Shaft
        color([0.75,0.75,0.78])
        translate([0,0,-shaft_front_len])
            cylinder(d=shaft_d, h=shaft_front_len + can_h + shaft_rear_len);

        // Mount ring detail (rear)
        color([0.45,0.45,0.48])
        translate([0,0,can_h-mount_ring_h])
            cylinder(d=mount_ring_d, h=mount_ring_h);

        // Wire exit block (rear side)
        color([0.1,0.1,0.1])
        translate([can_d/2 - wire_exit_t/2, 0, can_h - endcap_h - wire_exit_h])
            rotate([0,0,0])
                cube([wire_exit_t, wire_exit_w, wire_exit_h], center=true);
    }
}

motor();