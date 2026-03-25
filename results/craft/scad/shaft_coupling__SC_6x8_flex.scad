$fn = 128;

// Target dimensions
outer_diameter_mm = 19;          // OD
overall_length_mm = 25;          // total length

bore1_diameter_mm = 6;           // one end bore
bore2_diameter_mm = 8;           // other end bore
bore1_depth_mm = overall_length_mm/2;
bore2_depth_mm = overall_length_mm/2;
center_gap_mm = 0;               // keep solid at center (no split)

eps_mm = 0.15;

// Flexible (beam) coupling cuts
num_slots = 6;                   // visible flexible features
slot_width_mm = 1.2;             // tangential width of slot
slot_radial_depth_mm = 3.2;      // how far slot cuts inward from OD
slot_length_mm = overall_length_mm - 2.0; // leave small end lands
slot_twist_deg = 240;            // helical twist across length
slot_phase_deg = 0;              // rotate pattern if desired

// Grub screw holes (subtractive)
grub_screw_hole_radius_mm = 1.5;
grub_screw_hole_depth_mm = 5;
grub_screw_offset_from_end_mm = 5;
grub_screw_angles_deg_a = 0;
grub_screw_angles_deg_b = 90;

// --- FIX: add the two small side cylindrical features and ensure they UNION into the body ---
side_pin_diameter_mm = 3.0;      // small cylindrical feature diameter
side_pin_length_mm   = 4.0;      // how far it sticks out
side_pin_z_offset_mm = 0;        // centered along length (as seen in bottom view)
side_pin_angles_deg  = [0, 180]; // two opposite pins
attach_overlap_mm    = 1.5;      // 1–2mm overlap to guarantee connection

module helical_slot(slot_w, slot_len, r_outer, radial_depth, twist_deg, z0, phase_deg=0) {
    r_center = r_outer - radial_depth/2;
    rotate([0,0,phase_deg])
        translate([0,0,z0])
            linear_extrude(height=slot_len + 2*eps_mm, center=true, twist=twist_deg, slices=80)
                translate([r_center, 0, 0])
                    square([radial_depth + 2*eps_mm, slot_w], center=true);
}

module grub_screw_holes(z_pos) {
    for (angle = [grub_screw_angles_deg_a, grub_screw_angles_deg_b]) {
        rotate([0,0,angle])
            translate([outer_diameter_mm/2 - (grub_screw_hole_depth_mm + eps_mm)/2, 0, z_pos])
                rotate([0,90,0])
                    cylinder(r=grub_screw_hole_radius_mm, h=grub_screw_hole_depth_mm + eps_mm, center=true);
    }
}

module side_pins() {
    r_outer = outer_diameter_mm/2;
    pin_r = side_pin_diameter_mm/2;

    // Place each pin so it intersects the main cylinder by attach_overlap_mm.
    // Pin axis is radial (X direction after rotation), centered at z = side_pin_z_offset_mm.
    // Center position from origin along +X:
    //   x_center = r_outer + side_pin_length/2 - overlap
    x_center = r_outer + side_pin_length_mm/2 - attach_overlap_mm;

    for (a = side_pin_angles_deg) {
        rotate([0,0,a])
            translate([x_center, 0, side_pin_z_offset_mm])
                rotate([0,90,0])
                    cylinder(r=pin_r, h=side_pin_length_mm, center=true);
    }
}

module shaft_coupling() {
    r_outer = outer_diameter_mm/2;

    // FIX: union() ensures all additive parts become one connected solid
    union() {
        difference() {
            // Body
            cylinder(r=r_outer, h=overall_length_mm, center=true);

            // Stepped bores (6mm one side, 8mm other side)
            translate([0,0,-overall_length_mm/2 + bore1_depth_mm/2])
                cylinder(r=bore1_diameter_mm/2, h=bore1_depth_mm + 2*eps_mm, center=true);

            translate([0,0, overall_length_mm/2 - bore2_depth_mm/2])
                cylinder(r=bore2_diameter_mm/2, h=bore2_depth_mm + 2*eps_mm, center=true);

            // Flexible helical beam slots
            for (i = [0:num_slots-1]) {
                phase = slot_phase_deg + i*360/num_slots;
                helical_slot(
                    slot_width_mm,
                    slot_length_mm,
                    r_outer,
                    slot_radial_depth_mm,
                    (i % 2 == 0) ? slot_twist_deg : -slot_twist_deg,
                    0,
                    phase
                );
            }

            // Grub screw holes near each end
            z1 = -overall_length_mm/2 + grub_screw_offset_from_end_mm;
            z2 =  overall_length_mm/2 - grub_screw_offset_from_end_mm;
            grub_screw_holes(z1);
            grub_screw_holes(z2);

            // Optional center gap (kept at 0 by default; if >0 it will split the part)
            if (center_gap_mm > 0)
                cube([outer_diameter_mm + 2*eps_mm, outer_diameter_mm + 2*eps_mm, center_gap_mm + 2*eps_mm], center=true);
        }

        // FIX: add/attach the two small side cylindrical features (now physically intersecting the body)
        side_pins();
    }
}

shaft_coupling();