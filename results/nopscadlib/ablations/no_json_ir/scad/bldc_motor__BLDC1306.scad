$fn = 140;

// Brushless DC motor target (verifiable outer envelope)
stator_d = 17.75;   // mm (outer diameter of motor can)
motor_h  = 14.5;    // mm (overall can height, excluding shaft)

// Small overlap to guarantee one connected solid
eps = 0.25;

// Derived
can_r = stator_d/2;
can_h = motor_h;

// Visual BLDC features (kept within the stator diameter envelope)
endcap_step = 0.35;                 // slight OD reduction at endcaps
endcap_r = can_r - endcap_step;
endcap_h = 1.3;

front_face_h = 0.9;                 // subtle front face ring
rear_face_h  = 0.9;

boss_r = 3.4;
boss_h = 1.0;

shaft_d = 2.0;
shaft_r = shaft_d/2;
shaft_front_len = 7.0;
shaft_back_len  = 1.8;

// External ribs to suggest laminations / can features
rib_count = 12;
rib_out = 0.55;                     // protrusion beyond can OD
rib_w   = 1.05;
rib_h   = can_h - (endcap_h*2) - 0.8;

// Rear wire leads (two)
wire_r = 0.7;
wire_len = 5.0;

// Rear mounting bumps (4)
lug_count = 4;
lug_r = 0.95;
lug_h = 0.85;

// Small front "rotor hub" hint (still within OD)
hub_r = can_r - 1.6;
hub_h = 0.7;

module motor_assembly() {
    union() {

        // Main can (OD = stator_d, height = motor_h)
        cylinder(h=can_h, r=can_r, center=true);

        // Endcap steps (slight OD reduction) - connected with overlap
        translate([0,0,  can_h/2 - endcap_h/2 + eps/2])
            cylinder(h=endcap_h + eps, r=endcap_r, center=true);
        translate([0,0, -can_h/2 + endcap_h/2 - eps/2])
            cylinder(h=endcap_h + eps, r=endcap_r, center=true);

        // Subtle front/rear face rings (adds detail in orthographic views)
        translate([0,0,  can_h/2 - front_face_h/2 + eps/2])
            cylinder(h=front_face_h + eps, r=can_r - 0.15, center=true);
        translate([0,0, -can_h/2 + rear_face_h/2 - eps/2])
            cylinder(h=rear_face_h + eps, r=can_r - 0.15, center=true);

        // Front boss around shaft (connected)
        translate([0,0, can_h/2 + boss_h/2 - eps/2])
            cylinder(h=boss_h + eps, r=boss_r, center=true);

        // Front hub hint (connected, within OD)
        translate([0,0, can_h/2 - endcap_h - hub_h/2 + eps/2])
            cylinder(h=hub_h + eps, r=hub_r, center=true);

        // Shaft (single connected piece passing through can)
        // Centered so it extends shaft_front_len out the front and shaft_back_len out the rear.
        shaft_total = can_h + shaft_front_len + shaft_back_len;
        shaft_center_z = (shaft_front_len - shaft_back_len)/2;
        translate([0,0, shaft_center_z])
            cylinder(h=shaft_total + eps, r=shaft_r, center=true);

        // External ribs (protrude outward, overlap into can for connectivity)
        rib_inner_overlap = 0.35; // how much rib sinks into can
        for (i = [0:rib_count-1]) {
            rotate([0,0, i*360/rib_count])
                translate([can_r + rib_out/2 - rib_inner_overlap, 0, 0])
                    cube([rib_out + rib_inner_overlap*2, rib_w, rib_h], center=true);
        }

        // Rear wire leads (two), connected to rear endcap by overlap
        wire_z = -can_h/2 + endcap_h*0.55;
        wire_x = can_r - wire_r - 0.15;
        for (s = [-1, 1]) {
            translate([s*wire_x, 0, wire_z])
                rotate([0,90,0])
                    cylinder(h=wire_len + eps, r=wire_r, center=true);
        }

        // Rear mounting lugs (bumps), connected to rear face
        lug_z = -can_h/2 + lug_h/2 - eps/2;
        lug_radial = can_r - lug_r - 0.25;
        for (i = [0:lug_count-1]) {
            rotate([0,0, i*360/lug_count + 45])
                translate([lug_radial, 0, lug_z])
                    cylinder(h=lug_h + eps, r=lug_r, center=true);
        }
    }
}

motor_assembly();