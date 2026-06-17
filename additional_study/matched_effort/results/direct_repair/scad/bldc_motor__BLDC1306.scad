$fn = 128;

// Brushless DC motor (simplified) based on stator diameter and height
stator_d = 17.75;
stator_h = 14.5;

// Assumptions for a typical small BLDC "outrunner"-style motor envelope
air_gap = 0.35;
can_wall = 0.8;
can_overhang = 1.2;
base_thk = 1.6;

can_od = stator_d + 2*(air_gap + can_wall + can_overhang);
can_h  = stator_h + 2.0;

shaft_d = 2.0;
shaft_len_above = 10.0;
shaft_len_below = 2.0;

mount_boss_d = can_od * 0.72;
mount_boss_h = base_thk;

wire_exit_w = 4.0;
wire_exit_h = 2.2;
wire_exit_len = 6.0;

module motor()
{
    union()
    {
        // Outer can (rotor housing)
        difference()
        {
            translate([0,0,base_thk])
                cylinder(d=can_od, h=can_h);

            // Hollow interior
            translate([0,0,base_thk + 0.6])
                cylinder(d=can_od - 2*can_wall, h=can_h - 1.2);

            // Top opening recess (gives a lip)
            translate([0,0,base_thk + can_h - 1.2])
                cylinder(d=can_od - 2*can_wall, h=2.0);

            // Wire exit notch
            translate([can_od/2 - can_wall - 0.2, 0, base_thk + 2.0])
                rotate([0,90,0])
                    cube([wire_exit_len, wire_exit_w, wire_exit_h], center=true);
        }

        // Base plate / mount boss
        difference()
        {
            cylinder(d=can_od*0.92, h=base_thk);

            // Center clearance
            translate([0,0,-0.1])
                cylinder(d=stator_d*0.55, h=base_thk+0.2);

            // Simple mounting holes (4x)
            hole_r = 1.1;
            bolt_circle = can_od*0.33;
            for (a = [0:90:270])
                translate([bolt_circle*cos(a), bolt_circle*sin(a), -0.1])
                    cylinder(r=hole_r, h=base_thk+0.2);
        }

        // Stator core (inside)
        translate([0,0,base_thk + (can_h - stator_h)/2])
            color([0.35,0.35,0.35])
                cylinder(d=stator_d, h=stator_h);

        // Stator teeth hint (simple radial bumps)
        teeth = 12;
        tooth_w = 1.2;
        tooth_r = stator_d/2 + 0.6;
        tooth_h = stator_h*0.85;
        translate([0,0,base_thk + (can_h - stator_h)/2 + (stator_h-tooth_h)/2])
            color([0.45,0.45,0.45])
            for (i=[0:teeth-1])
                rotate([0,0,i*360/teeth])
                    translate([tooth_r,0,0])
                        cube([1.6,tooth_w,tooth_h], center=true);

        // Shaft
        translate([0,0,base_thk + can_h])
            color([0.75,0.75,0.78])
                cylinder(d=shaft_d, h=shaft_len_above);

        translate([0,0,-shaft_len_below])
            color([0.75,0.75,0.78])
                cylinder(d=shaft_d, h=shaft_len_below + 0.01);

        // Top hub (where shaft meets can)
        translate([0,0,base_thk + can_h - 1.0])
            color([0.6,0.6,0.62])
                cylinder(d=can_od*0.35, h=2.0);

        // Simple wire bundle
        translate([can_od/2 + 1.0, 0, base_thk + 2.0])
            color([0.2,0.2,0.2])
                rotate([0,90,0])
                    cylinder(d=1.6, h=10);
        translate([can_od/2 + 1.0, 2.0, base_thk + 2.0])
            color([0.8,0.1,0.1])
                rotate([0,90,0])
                    cylinder(d=1.2, h=10);
        translate([can_od/2 + 1.0, -2.0, base_thk + 2.0])
            color([0.1,0.2,0.8])
                rotate([0,90,0])
                    cylinder(d=1.2, h=10);
    }
}

motor();