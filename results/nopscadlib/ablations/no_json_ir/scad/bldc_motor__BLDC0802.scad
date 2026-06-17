$fn = 140;

// Brushless DC motor (stator) target dimensions
stator_d = 11.5;
stator_h = 9.5;

// Visual/feature parameters (all derived/connected)
airgap = 0.25;                 // visual clearance between stator and rotor
rotor_wall = 0.8;              // rotor can thickness
endcap_t = 0.8;                // top/bottom endcap thickness (inside can)
lip_t = 0.35;                  // seam lip thickness
lip_overhang = 0.35;           // seam lip radial overhang

shaft_d = 2.0;
shaft_len_top = 3.0;
shaft_len_bottom = 1.2;

mount_boss_d = 5.2;
mount_boss_h = 0.9;

stator_bore_d = 3.0;           // center bore through stator
stator_tooth_count = 9;
tooth_len = 1.2;               // tooth radial length (inward)
tooth_w = 1.0;                 // tooth tangential width
tooth_overlap = 0.35;          // overlap into stator ring for connectivity

// Housing/mounting details typical of small BLDCs
base_flange_t = 0.7;           // thin base flange
base_flange_overhang = 1.0;    // flange radial overhang beyond rotor can
mount_hole_count = 4;
mount_hole_d = 1.2;            // visual holes (not through entire motor)
mount_hole_r = (stator_d/2) + 1.6; // derived radius for hole circle

wire_exit_w = 2.2;             // small wire notch width
wire_exit_h = 1.2;             // notch height
wire_exit_depth = 1.2;         // notch depth into can

// Derived radii
stator_r = stator_d/2;
rotor_d = stator_d + 2*(airgap + rotor_wall);
rotor_r = rotor_d/2;

// Connectivity overlap
overlap = 0.18;

// Z layout (formulas only)
z0 = 0;
z_stator_bot = z0;
z_stator_top = z_stator_bot + stator_h;

z_rotor_bot = z_stator_bot - endcap_t;
z_rotor_top = z_stator_top + endcap_t;

z_shaft_top = z_rotor_top + shaft_len_top;
z_shaft_bot = z_rotor_bot - shaft_len_bottom;

z_flange_bot = z_rotor_bot - base_flange_t;
z_flange_top = z_rotor_bot + overlap; // overlap into can

module stator_core_with_teeth() {
    union() {
        // Stator ring with center bore
        difference() {
            cylinder(h=stator_h, r=stator_r, center=false);
            translate([0,0,-overlap])
                cylinder(h=stator_h + 2*overlap, d=stator_bore_d, center=false);
        }

        // Teeth protruding inward, overlapping into ring
        for (i = [0:stator_tooth_count-1]) {
            rotate([0,0,i*360/stator_tooth_count])
                translate([stator_r - tooth_len/2 - tooth_overlap, 0, stator_h/2])
                    cube([tooth_len, tooth_w, stator_h], center=true);
        }
    }
}

module rotor_can_shell() {
    // Outer can wall (hollow cylinder)
    difference() {
        translate([0,0,z_rotor_bot])
            cylinder(h=(z_rotor_top - z_rotor_bot), r=rotor_r, center=false);

        // Hollow interior (leave wall thickness)
        translate([0,0,z_rotor_bot - overlap])
            cylinder(h=(z_rotor_top - z_rotor_bot) + 2*overlap, r=rotor_r - rotor_wall, center=false);

        // Wire exit notch (small rectangular cut near bottom edge)
        // Cut from outside into the wall; positioned by formulas
        translate([rotor_r - wire_exit_depth/2, 0, z_rotor_bot + endcap_t + wire_exit_h/2])
            cube([wire_exit_depth + 2*overlap, wire_exit_w, wire_exit_h], center=true);
    }
}

module rotor_endcaps_and_lip() {
    union() {
        // Bottom endcap disk (inside can, connected)
        translate([0,0,z_rotor_bot])
            cylinder(h=endcap_t, r=rotor_r - rotor_wall + overlap, center=false);

        // Top endcap disk (inside can, connected)
        translate([0,0,z_rotor_top - endcap_t])
            cylinder(h=endcap_t, r=rotor_r - rotor_wall + overlap, center=false);

        // Seam lip near top (visual)
        translate([0,0,z_rotor_top - endcap_t - lip_t])
            difference() {
                cylinder(h=lip_t, r=rotor_r + lip_overhang, center=false);
                translate([0,0,-overlap])
                    cylinder(h=lip_t + 2*overlap, r=rotor_r - rotor_wall, center=false);
            }
    }
}

module base_flange_with_mount_holes() {
    // Flange is part of the same solid; holes are shallow recesses (difference)
    difference() {
        translate([0,0,z_flange_bot])
            cylinder(h=base_flange_t + overlap, r=rotor_r + base_flange_overhang, center=false);

        // Shallow mounting hole recesses (do not cut through entire motor)
        // Depth limited to flange thickness
        for (i = [0:mount_hole_count-1]) {
            rotate([0,0,i*360/mount_hole_count])
                translate([mount_hole_r, 0, z_flange_bot - overlap])
                    cylinder(h=base_flange_t + 2*overlap, d=mount_hole_d, center=false);
        }
    }
}

module shaft_and_mount() {
    union() {
        // Shaft through motor (connected via overlap into endcaps)
        translate([0,0,z_shaft_bot])
            cylinder(h=(z_shaft_top - z_shaft_bot), d=shaft_d, center=false);

        // Bottom mounting boss (connected to flange/endcap region)
        translate([0,0,z_rotor_bot - mount_boss_h + overlap])
            cylinder(h=mount_boss_h + overlap, d=mount_boss_d, center=false);
    }
}

module motor() {
    // ONE connected solid: can + endcaps + stator + flange + shaft/boss
    union() {
        rotor_can_shell();
        rotor_endcaps_and_lip();

        // Stator inside can; overlaps slightly into endcaps for guaranteed connectivity
        translate([0,0,z_stator_bot])
            stator_core_with_teeth();

        // Base flange with mounting details (connected to can at z_rotor_bot)
        base_flange_with_mount_holes();

        // Shaft and bottom boss
        shaft_and_mount();
    }
}

motor();