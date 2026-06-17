$fn=128;

// Brushless DC motor (generic outrunner-style) sized to:
// Stator diameter: 28.0 mm
// Stator height:   17.25 mm

stator_d = 28.0;
stator_h = 17.25;

// Simple parametric proportions for a plausible motor body
airgap = 0.6;
can_wall = 1.2;
can_overhang_r = 2.0;
can_overhang_top = 2.0;

can_od = stator_d + 2*(airgap + can_wall + can_overhang_r);
can_h  = stator_h + can_overhang_top;

base_h = 3.0;
base_od = can_od - 2.0;

shaft_d = 3.175;     // 1/8" typical small BLDC shaft
shaft_len = 18.0;

mount_boss_d = 10.0;
mount_boss_h = 2.0;

bolt_circle_d = 16.0;
bolt_hole_d = 3.0;
bolt_hole_depth = base_h + mount_boss_h + 0.5;

wire_exit_w = 6.0;
wire_exit_h = 3.0;
wire_exit_len = 8.0;

module bolt_holes(z0=0){
    for (a=[0:90:270]){
        rotate([0,0,a])
            translate([bolt_circle_d/2,0,z0])
                cylinder(d=bolt_hole_d, h=bolt_hole_depth, center=false);
    }
}

module motor(){
    union(){
        // Base / stator housing
        difference(){
            union(){
                cylinder(d=base_od, h=base_h, center=false);
                translate([0,0,base_h])
                    cylinder(d=mount_boss_d, h=mount_boss_h, center=false);
            }
            // Bolt holes
            bolt_holes(0);
            // Wire exit notch
            translate([base_od/2 - 1.0, -wire_exit_w/2, 0.8])
                cube([wire_exit_len, wire_exit_w, wire_exit_h], center=false);
        }

        // Rotor can (outer shell)
        translate([0,0,base_h])
        difference(){
            cylinder(d=can_od, h=can_h, center=false);
            // Hollow inside
            translate([0,0,can_wall])
                cylinder(d=can_od - 2*can_wall, h=can_h, center=false);
            // Bottom opening (leave a lip)
            translate([0,0,-0.1])
                cylinder(d=can_od - 2*(can_wall+0.6), h=can_wall+0.2, center=false);
        }

        // Stator core (visual)
        translate([0,0,base_h + 0.6])
            color([0.25,0.25,0.25])
                cylinder(d=stator_d, h=stator_h, center=false);

        // Shaft
        translate([0,0,base_h + can_h])
            color([0.7,0.7,0.7])
                cylinder(d=shaft_d, h=shaft_len, center=false);

        // Top hub (simple)
        translate([0,0,base_h + can_h - 1.5])
            cylinder(d=12.0, h=3.0, center=false);
    }
}

motor();