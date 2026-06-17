// Brushless DC motor (simplified) with stator diameter 28.0mm and stator height 17.25mm
// One connected solid; all placements derived from dimensions (no arbitrary offsets).

$fn = 128;

// Requested key dimensions
stator_diameter_mm = 28;      //[14:56:0.25]
stator_height_mm   = 17.25;   //[8.625:34.5:0.25]

// Motor feature parameters (derived/related to stator size)
airgap_mm              = 0.6;
can_wall_mm            = 0.8;
endcap_thickness_mm    = 1.2;

shaft_diameter_mm      = 3.0;
shaft_front_len_mm     = 10.0;
shaft_back_len_mm      = 2.0;

front_boss_diameter_mm = 10.0;
front_boss_height_mm   = 2.0;

mount_flange_diameter_mm   = stator_diameter_mm + 6.0;
mount_flange_thickness_mm  = 1.6;

mount_hole_count            = 4;
mount_hole_diameter_mm      = 3.0;
mount_hole_circle_diameter_mm = stator_diameter_mm + 2.0;

wire_exit_w_mm = 6.0;
wire_exit_t_mm = 3.0;
wire_exit_h_mm = 4.0;

attach_overlap_mm = 0.6; // small overlap to guarantee manifold union

// Derived radii/heights
stator_r = stator_diameter_mm/2;
stator_h = stator_height_mm;

can_r   = stator_r + can_wall_mm;
rotor_r = max(0.1, stator_r - airgap_mm);

// Total motor body height (endcap-to-endcap)
total_body_h = stator_h + 2*endcap_thickness_mm;

// Z references (centered assembly)
z_body_center = 0;
z_body_top    = z_body_center + total_body_h/2;
z_body_bot    = z_body_center - total_body_h/2;

// Visual feature sizes
tooth_count = 12;
tooth_len   = 2.2;
tooth_w     = 2.0;
tooth_h     = max(1, stator_h - 2.0);

module motor_solid() {
    union() {
        // Outer can
        cylinder(r=can_r, h=total_body_h, center=true);

        // Front endcap boss (bearing housing)
        translate([0, 0, z_body_top - endcap_thickness_mm + front_boss_height_mm/2 - attach_overlap_mm])
            cylinder(r=front_boss_diameter_mm/2, h=front_boss_height_mm, center=true);

        // Mounting flange ring at front (kept as solid ring; holes subtracted later)
        translate([0, 0, z_body_top - endcap_thickness_mm + mount_flange_thickness_mm/2 - attach_overlap_mm])
            difference() {
                cylinder(r=mount_flange_diameter_mm/2, h=mount_flange_thickness_mm, center=true);
                // inner relief so it reads as a flange, but still connected to can via overlap
                cylinder(r=can_r - 0.2, h=mount_flange_thickness_mm + 2, center=true);
            }

        // Shaft (front + back), connected through body
        cylinder(r=shaft_diameter_mm/2,
                 h=total_body_h + shaft_front_len_mm + shaft_back_len_mm,
                 center=true);

        // Wire exit block on side (connected to can)
        translate([can_r - wire_exit_t_mm/2 + attach_overlap_mm, 0,
                   z_body_bot + endcap_thickness_mm + wire_exit_h_mm/2])
            cube([wire_exit_t_mm, wire_exit_w_mm, wire_exit_h_mm], center=true);

        // Stator lamination stack (visual) - ensure it is exactly the requested stator size
        // Connected to the rest via overlap with endcaps/can.
        cylinder(r=stator_r, h=stator_h + 2*attach_overlap_mm, center=true);

        // Rotor (visual) inside stator (solid, connected via overlap)
        cylinder(r=rotor_r, h=max(1, stator_h - 1.0), center=true);

        // Stator teeth (visual) - protrude inward from stator ID region, but remain connected
        for (i = [0:tooth_count-1]) {
            rotate([0, 0, i*360/tooth_count])
                // Place so inner edge overlaps into rotor region slightly, outer edge overlaps into stator
                translate([stator_r - tooth_len/2 + attach_overlap_mm, 0, 0])
                    cube([tooth_len, tooth_w, tooth_h], center=true);
        }
    }
}

module motor() {
    difference() {
        motor_solid();

        // Mount holes through flange thickness only
        z_flange_center = z_body_top - endcap_thickness_mm + mount_flange_thickness_mm/2 - attach_overlap_mm;

        for (i = [0:mount_hole_count-1]) {
            rotate([0, 0, i*360/mount_hole_count])
                translate([mount_hole_circle_diameter_mm/2, 0, z_flange_center])
                    cylinder(r=mount_hole_diameter_mm/2,
                             h=mount_flange_thickness_mm + 2,
                             center=true);
        }
    }
}

motor();