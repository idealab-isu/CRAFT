// Brushless DC motor (ONE connected solid)
// Target: stator_diameter_mm = 14.0, stator_height_mm = 11.75
// Notes:
// - Stator is modeled as a cylinder of exactly 14.0mm OD and 11.75mm height.
// - Rotor bell surrounds stator with clearance; vents and mounting details are added.
// - All placements use formulas from dimensions; no arbitrary floating parts.

$fn = 128;

// -------------------- Parameters --------------------
stator_diameter_mm = 14.0;   //[7.0:28.0:0.25]
stator_height_mm   = 11.75;  //[5.875:23.5:0.25]

// Clearances / thicknesses
radial_clearance_mm     = 0.25; //[0.1:1.0:0.05]
can_wall_thickness_mm   = 0.7;  //[0.3:1.5:0.05]
endcap_thickness_mm     = 1.0;  //[0.5:2.0:0.1]
overlap_mm              = 0.6;  //[0.3:2.0:0.1]

// Shaft
shaft_diameter_mm = 2.0;   //[1.0:4.0:0.1]
shaft_length_mm   = 20.0;  //[10.0:40.0:0.5]

// Visual features
num_teeth = 12;
tooth_radial_len = 1.0;
tooth_tangential_w = 1.2;
tooth_h_frac = 0.85;

num_magnets = 14;
magnet_radial_th = 0.6;
magnet_tangential_w = 1.2;
magnet_h_frac = 0.75;

num_vents = 12;
vent_w = 0.9;
vent_depth = 1.2; // radial depth into bell wall
vent_h_frac = 0.55;

num_bolt_holes = 4;
bolt_circle_d = 10.0;
bolt_hole_d = 2.0;

// -------------------- Derived geometry --------------------
stator_r = stator_diameter_mm/2;
stator_h = stator_height_mm;

shaft_r = shaft_diameter_mm/2;
shaft_h = shaft_length_mm;

// Bell (rotor can) around stator
bell_inner_r = stator_r + radial_clearance_mm;
bell_wall    = can_wall_thickness_mm;
bell_outer_r = bell_inner_r + bell_wall;

// Make bell slightly taller than stator to show endcaps
bell_h = stator_h + 2*endcap_thickness_mm;

// Base / mount behind stator
base_th = 1.2;
base_r  = max(0.1, stator_r - 0.6);

// Front hub boss
hub_r = 3.2;
hub_h = 1.6;

// Teeth/magnets heights
tooth_h  = stator_h * tooth_h_frac;
magnet_h = stator_h * magnet_h_frac;

// Vent height
vent_h = bell_h * vent_h_frac;

// -------------------- Modules --------------------
module stator_with_teeth() {
    union() {
        // Stator core (exact requested dimensions)
        cylinder(r=stator_r, h=stator_h, center=true);

        // Teeth protruding outward from stator OD (connected via overlap)
        for (i = [0:num_teeth-1]) {
            rotate([0,0,i*360/num_teeth])
                translate([stator_r + tooth_radial_len/2 - overlap_mm, 0, 0])
                    cube([tooth_radial_len, tooth_tangential_w, tooth_h], center=true);
        }
    }
}

module bell_shell_with_vents() {
    // Bell shell with vents cut through the wall (difference keeps it one solid piece)
    difference() {
        // Outer bell
        cylinder(r=bell_outer_r, h=bell_h, center=true);

        // Hollow interior (clear stator)
        cylinder(r=bell_inner_r, h=bell_h + 2*overlap_mm, center=true);

        // Open back side (rear opening typical of outrunner bell)
        translate([0,0,-bell_h/2])
            cylinder(r=bell_outer_r + overlap_mm, h=bell_h/2 + overlap_mm, center=false);

        // Side vents (slots) cut into bell wall
        // Place slot centers at mid-wall radius so they cut through the wall.
        vent_center_r = bell_inner_r + bell_wall/2;
        for (i = [0:num_vents-1]) {
            rotate([0,0,i*360/num_vents])
                translate([vent_center_r, 0, 0])
                    cube([vent_depth + bell_wall, vent_w, vent_h], center=true);
        }
    }
}

module bell_with_magnets_and_face() {
    union() {
        // Shell with vents
        bell_shell_with_vents();

        // Front face ring (lip) to suggest bell face (connected)
        translate([0,0, bell_h/2 - endcap_thickness_mm/2])
            cylinder(r=bell_outer_r, h=endcap_thickness_mm, center=true);

        // Front hub boss (connected to bell face with overlap)
        translate([0,0, bell_h/2 + hub_h/2 - overlap_mm])
            cylinder(r=hub_r, h=hub_h, center=true);

        // Inner magnets (protrude inward from bell inner wall)
        magnet_center_r = bell_inner_r - magnet_radial_th/2 + overlap_mm;
        for (i = [0:num_magnets-1]) {
            rotate([0,0,i*360/num_magnets])
                translate([magnet_center_r, 0, 0])
                    cube([magnet_radial_th, magnet_tangential_w, magnet_h], center=true);
        }
    }
}

module base_and_mount() {
    // Base plate behind stator (connected)
    base_z = -stator_h/2 - base_th/2 + overlap_mm;

    union() {
        translate([0,0,base_z])
            cylinder(r=base_r, h=base_th, center=true);

        // Two opposite mounting lugs (connected to base)
        lug_len = 3.0;
        lug_w   = 3.0;
        lug_th  = base_th;
        lug_r_center = base_r + lug_len/2 - overlap_mm;

        for (a = [0,180]) {
            rotate([0,0,a])
                translate([lug_r_center, 0, base_z])
                    cube([lug_len, lug_w, lug_th], center=true);
        }
    }
}

module front_mount_flange_with_holes() {
    // A thin flange at the front to create visible features in orthographic views.
    // It is connected to the bell face via overlap.
    flange_th = 1.0;
    flange_r  = bell_outer_r + 1.2;

    flange_z = bell_h/2 + flange_th/2 - overlap_mm;

    difference() {
        translate([0,0,flange_z])
            cylinder(r=flange_r, h=flange_th, center=true);

        // Bolt holes on a bolt circle
        bcd_r = bolt_circle_d/2;
        for (i = [0:num_bolt_holes-1]) {
            rotate([0,0,i*360/num_bolt_holes])
                translate([bcd_r, 0, flange_z])
                    cylinder(r=bolt_hole_d/2, h=flange_th + 2*overlap_mm, center=true);
        }
    }
}

module shaft() {
    // Shaft passes through entire assembly; overlaps hub/base to ensure connectivity
    cylinder(r=shaft_r, h=shaft_h, center=true);
}

// -------------------- Assembly (ONE connected solid) --------------------
module bldc_motor_connected() {
    union() {
        // Stator + teeth (exact stator dimensions)
        stator_with_teeth();

        // Base/mount behind stator
        base_and_mount();

        // Bell/rotor around stator
        bell_with_magnets_and_face();

        // Front flange with bolt holes (adds visible orthographic detail)
        front_mount_flange_with_holes();

        // Shaft (centered)
        shaft();
    }
}

bldc_motor_connected();