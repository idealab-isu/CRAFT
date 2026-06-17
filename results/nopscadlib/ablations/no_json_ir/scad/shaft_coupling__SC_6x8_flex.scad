$fn = 120;

// ===== Target dimensions =====
outer_diameter = 19.0;
length         = 25.0;
bore_d1        = 6.0;   // one end
bore_d2        = 8.0;   // other end

// ===== Feature parameters (typical for small flexible couplers) =====
center_gap          = 0.6;   // small web between bores
bore_extra_depth    = 0.2;   // ensures clean cut-through
set_screw_d         = 3.0;
set_screw_head_d    = 5.6;   // simple counterbore for socket head / grub access
set_screw_head_h    = 2.0;
set_screw_inset     = 1.2;   // how far in from OD the screw hole starts (keeps wall)
set_screw_z_offset  = 6.0;   // distance from center to each screw along Z

// Helical slot (flex section)
slot_section_len = 12.0;     // length of flexible region centered at Z=0
slot_w           = 1.2;      // slot width (tangential)
slot_depth       = 2.2;      // radial depth into body
slot_turns       = 3;        // number of turns across slot_section_len
slot_steps       = 90;       // resolution of helix
slot_overlap     = 0.4;      // overlap between segments to avoid gaps

eps = 0.01;

outer_r = outer_diameter/2;

// Derived Z positions
z_min = -length/2;
z_max =  length/2;

z_bore1_end = -center_gap/2;
z_bore2_start =  center_gap/2;

z_screw1 = -set_screw_z_offset;
z_screw2 =  set_screw_z_offset;

// ===== Helpers =====
module set_screw_hole(zpos) {
    // Through-hole from outside toward center (radial), plus a shallow counterbore
    // Place so it definitely intersects the body and reaches the bore.
    translate([0, 0, zpos]) {
        rotate([0, 90, 0]) {
            // main hole (long enough to pass through to center)
            translate([outer_r - set_screw_inset, 0, 0])
                cylinder(d=set_screw_d, h=outer_r + 2, center=false);

            // counterbore at the outside surface
            translate([outer_r - set_screw_inset - set_screw_head_h, 0, 0])
                cylinder(d=set_screw_head_d, h=set_screw_head_h + eps, center=false);
        }
    }
}

module helical_slot() {
    // Build a helical cut by hulling successive small rectangular "radial cutters"
    // so the subtraction is continuous and printable.
    z0 = -slot_section_len/2;
    z1 =  slot_section_len/2;

    for (i = [0 : slot_steps-1]) {
        t0 = i/(slot_steps);
        t1 = (i+1)/(slot_steps);

        zz0 = z0 + (z1 - z0)*t0;
        zz1 = z0 + (z1 - z0)*t1;

        a0 = 360*slot_turns*t0;
        a1 = 360*slot_turns*t1;

        hull() {
            rotate([0, 0, a0])
                translate([outer_r - slot_depth/2, 0, zz0])
                    cube([slot_depth + slot_overlap, slot_w, (z1-z0)/slot_steps + slot_overlap], center=true);

            rotate([0, 0, a1])
                translate([outer_r - slot_depth/2, 0, zz1])
                    cube([slot_depth + slot_overlap, slot_w, (z1-z0)/slot_steps + slot_overlap], center=true);
        }
    }
}

// ===== Model =====
difference() {
    // Outer body (single connected solid)
    cylinder(d=outer_diameter, h=length, center=true);

    // Two different bores from each end, meeting near center with a small web gap
    // Bore 6mm from negative Z end up to -center_gap/2
    translate([0, 0, z_min - bore_extra_depth/2])
        cylinder(d=bore_d1, h=(z_bore1_end - z_min) + bore_extra_depth, center=false);

    // Bore 8mm from positive Z end down to +center_gap/2
    translate([0, 0, z_bore2_start])
        cylinder(d=bore_d2, h=(z_max - z_bore2_start) + bore_extra_depth, center=false);

    // Set screw holes (one per side)
    set_screw_hole(z_screw1);
    set_screw_hole(z_screw2);

    // Flexible helical slot through the middle section
    helical_slot();
}