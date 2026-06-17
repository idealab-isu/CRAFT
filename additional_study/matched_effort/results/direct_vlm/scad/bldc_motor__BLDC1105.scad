$fn = 128;

// Brushless DC motor (simplified) with stator: Ø14.0mm x 11.75mm height
// ONE connected solid. All placements are formula-based (no arbitrary offsets).

stator_d = 14.0;
stator_h = 11.75;

// Can around stator
can_wall = 0.6;
can_clearance = 0.4;
can_d = stator_d + 2*(can_wall + can_clearance);   // outer can diameter
can_h = stator_h + 2.0;                            // overall can height (not stator height)

// End features
endcap_h = 1.2;
base_h   = 1.6;

mount_boss_d = can_d + 2.0;
mount_boss_h = base_h;

// Shaft
shaft_d = 2.0;
shaft_len_front = 10.0;
shaft_len_back  = 2.0;

// Wire exit
wire_exit_w = 4.0;
wire_exit_t = 2.0;
wire_exit_h = 3.0;

// Visual features (still one solid)
front_hub_d = 6.0;
front_hub_h = 1.0;

rear_boss_d = 5.0;
rear_boss_h = 0.8;

lug_w = 2.2;
lug_t = 1.2;
lug_h = 1.0;
lug_count = 4;

ov = 0.2;

// Z layout (built from z=0 upward; some features extend below 0)
z_base0      = 0;
z_base1      = z_base0 + base_h;

z_can0       = z_base1 - ov;
z_can1       = z_can0 + can_h;

z_stator0    = z_can0 + (can_h - stator_h)/2;
z_stator1    = z_stator0 + stator_h;

z_frontcap0  = z_can1 - endcap_h - ov;
z_frontcap1  = z_frontcap0 + endcap_h;

module motor_solid() {
    union() {
        // Base / rear boss (solid)
        cylinder(d=mount_boss_d, h=mount_boss_h);

        // Main can (solid)
        translate([0,0,z_can0])
            cylinder(d=can_d, h=can_h + ov);

        // Front endcap (solid)
        translate([0,0,z_frontcap0])
            cylinder(d=can_d, h=endcap_h + ov);

        // Stator (solid, exact requested dimensions)
        translate([0,0,z_stator0])
            cylinder(d=stator_d, h=stator_h);

        // Front hub (gives front view a non-flat silhouette)
        translate([0,0,z_can1 - front_hub_h - ov])
            cylinder(d=front_hub_d, h=front_hub_h + ov);

        // Front shaft (connected to hub/endcap with overlap)
        translate([0,0,z_can1 - ov])
            cylinder(d=shaft_d, h=shaft_len_front + ov);

        // Back shaft stub (connected into base with overlap)
        translate([0,0,-shaft_len_back])
            cylinder(d=shaft_d, h=shaft_len_back + ov);

        // Rear boss around shaft (adds rear detail)
        translate([0,0,z_base0 - ov])
            cylinder(d=rear_boss_d, h=rear_boss_h + ov);

        // Wire exit block (connected to base/can region)
        translate([can_d/2 - wire_exit_t/2 + ov, 0, base_h/2])
            cube([wire_exit_t + 2*ov, wire_exit_w, wire_exit_h], center=true);

        // Mounting lugs on base flange (breaks circular silhouette in orthographic views)
        for (i = [0:lug_count-1]) {
            rotate([0,0,i*360/lug_count])
                translate([mount_boss_d/2 + lug_t/2 - ov, 0, lug_h/2])
                    cube([lug_t + 2*ov, lug_w, lug_h], center=true);
        }

        // Small side flat / notch (subtle feature, still connected)
        translate([can_d/2 - 0.6, 0, z_can0 + can_h*0.55])
            cube([1.2, can_d*0.22, can_h*0.35], center=true);
    }
}

motor_solid();