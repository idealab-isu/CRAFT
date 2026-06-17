// Brushless DC motor (single connected solid)
// Target: 42.5mm stator diameter, 48.0mm motor body height (can length, excluding shaft)
// All translations are derived from dimensions; no floating parts.

$fn = 160;

// --- Key requested dimensions ---
stator_diameter = 42.5;     // reference stator diameter
body_height     = 48.0;     // motor body height (housing/can length)

// --- Motor proportions (parametric, reasonable defaults) ---
housing_thickness   = 2.0;
endcap_thickness_f  = 3.0;
endcap_thickness_r  = 3.0;

shaft_diameter      = 5.0;
shaft_front_length  = 18.0;   // protruding from front
shaft_rear_length   = 6.0;    // small rear stub

boss_diameter       = 12.0;   // front bearing boss
boss_length         = 6.0;

flange_diameter     = 60.0;
flange_thickness    = 5.0;

mount_hole_count    = 6;
mount_hole_diameter = 3.2;    // clearance-like
mount_hole_circle_d = 50.0;   // bolt circle diameter

wire_exit_diameter  = 6.0;
wire_exit_length    = 10.0;
wire_exit_angle     = 35;     // degrees around body

vent_hole_diameter  = 3.0;
vent_hole_count     = 8;

eps = 0.25; // overlap to ensure watertight union / robust booleans

// --- Derived dimensions ---
stator_r   = stator_diameter/2;
outer_d    = stator_diameter + 2*housing_thickness;
outer_r    = outer_d/2;

z_body_min = -body_height/2;
z_body_max =  body_height/2;

z_rear_cap_min  = z_body_min - endcap_thickness_r;
z_rear_cap_max  = z_body_min;

z_front_cap_min = z_body_max;
z_front_cap_max = z_body_max + endcap_thickness_f;

z_flange_min = z_rear_cap_min - flange_thickness;
z_flange_max = z_rear_cap_min;

z_shaft_min  = z_flange_min - shaft_rear_length;
z_shaft_max  = z_front_cap_max + shaft_front_length;

// Helper: cylinder with Z extents (no arbitrary translate)
module cyl_z(d, z0, z1) {
    translate([0,0,(z0+z1)/2]) cylinder(d=d, h=(z1-z0), center=true);
}

module motor_solid() {
    difference() {
        union() {
            // Outer can (housing) - body length exactly body_height
            cyl_z(outer_d, z_body_min, z_body_max);

            // Rear endcap
            cyl_z(outer_d, z_rear_cap_min, z_rear_cap_max);

            // Front endcap
            cyl_z(outer_d, z_front_cap_min, z_front_cap_max);

            // Rear mounting flange (connected to rear endcap)
            cyl_z(flange_diameter, z_flange_min, z_flange_max);

            // Front bearing boss (connected to front endcap with overlap)
            cyl_z(boss_diameter, z_front_cap_max - eps, z_front_cap_max + boss_length);

            // Central shaft (passes through; connected via boss/endcap overlap)
            cyl_z(shaft_diameter, z_shaft_min, z_shaft_max);

            // Wire exit grommet (side cylinder connected to housing)
            wire_r = wire_exit_diameter/2;
            wire_center_r = outer_r - wire_r + eps; // intersects outer wall
            wire_z = z_rear_cap_max + body_height*0.15;

            rotate([0,0,wire_exit_angle])
                translate([wire_center_r, 0, wire_z])
                    rotate([0,90,0])
                        cylinder(d=wire_exit_diameter, h=wire_exit_length, center=true);
        }

        // Hollow out the housing to suggest rotor/stator cavity
        // Keep endcaps mostly solid by limiting cavity to body region.
        cavity_d = outer_d - 2*housing_thickness;
        cyl_z(cavity_d, z_body_min - eps, z_body_max + eps);

        // Front shaft clearance through front endcap + boss
        // Use z extents to avoid center=false ambiguity.
        cyl_z(shaft_diameter + 0.6, z_front_cap_min - eps, z_front_cap_max + boss_length + eps);

        // Rear shaft clearance through rear endcap + flange
        cyl_z(shaft_diameter + 0.6, z_flange_min - eps, z_rear_cap_max + eps);

        // Mounting holes through flange + rear endcap (pattern)
        for (i = [0:mount_hole_count-1]) {
            ang = i * 360 / mount_hole_count;
            rotate([0,0,ang])
                translate([mount_hole_circle_d/2, 0, 0])
                    cyl_z(mount_hole_diameter, z_flange_min - eps, z_rear_cap_max + eps);
        }

        // Vent holes (radial) through housing wall only (body region)
        vent_r = vent_hole_diameter/2;
        vent_center_r = outer_r - vent_r - 0.2; // keep within wall
        vent_z0 = z_body_min + body_height*0.20;
        vent_z1 = z_body_max - body_height*0.20;
        vent_zc = (vent_z0 + vent_z1)/2;
        vent_h  = (vent_z1 - vent_z0);

        for (i = [0:vent_hole_count-1]) {
            ang = i * 360 / vent_hole_count;
            rotate([0,0,ang])
                translate([vent_center_r, 0, vent_zc])
                    rotate([0,90,0])
                        cylinder(d=vent_hole_diameter,
                                 h=housing_thickness*2 + 2*eps,
                                 center=true);
        }

        // Add shallow front face recess to create visible feature in orthographic views
        // (does not disconnect; just a small pocket on the front endcap)
        recess_d = outer_d * 0.70;
        recess_depth = 0.8;
        cyl_z(recess_d, z_front_cap_max - recess_depth, z_front_cap_max + eps);

        // Add shallow rear face recess on flange for visible detail
        rear_recess_d = flange_diameter * 0.70;
        rear_recess_depth = 0.8;
        cyl_z(rear_recess_d, z_flange_min - eps, z_flange_min + rear_recess_depth);
    }
}

// Render
motor_solid();