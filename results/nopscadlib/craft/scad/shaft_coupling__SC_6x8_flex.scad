// Flexible shaft coupling (beam/helical cut style) with clamp split + pinch screws
// Target: 6.0mm to 8.0mm stepped bore, 19.0mm OD, 25.0mm long
// ONE connected solid (split does NOT fully separate due to a small bridge)

outer_diameter_mm = 19; //[9.5:38:0.1]
overall_length_mm = 25; //[12.5:50:0.1]

bore1_diameter_mm = 6; //[3:12:0.1]
bore2_diameter_mm = 8; //[4:16:0.1]
bore1_depth_mm = 12.5; //[6.25:25:0.1]
bore2_depth_mm = 12.5; //[6.25:25:0.1]

center_relief_width_mm = 0.8; //[0.0:3:0.1]   // small relief at the bore step

helical_cut_count = 6; //[3:12:1]
helical_cut_width_mm = 1.2; //[0.6:2.4:0.1]
helical_cut_radial_depth_mm = 7.0; //[4:9:0.1]
flexure_twist_deg = 720; //[360:3600:90]

// Keep a web so the part stays connected (avoid full split)
center_web_thickness_mm = 2.0; //[0.8:4:0.1]

// Clamp split + pinch screws (typical clamp-style coupling)
clamp_split_width_mm = 1.2; //[0.6:2.5:0.1]     // kerf width of the split
clamp_bridge_thickness_mm = 1.2; //[0.6:3:0.1]   // leave this much material so model remains ONE solid
pinch_screw_diameter_mm = 3.2; //[2.6:5:0.1]     // clearance hole
pinch_screw_head_diameter_mm = 6.2; //[4.5:10:0.1]
pinch_screw_head_depth_mm = 2.2; //[1:5:0.1]
pinch_screw_offset_from_ends_mm = 5; //[2.5:10:0.1]
pinch_screw_count_per_end = 1; //[1:2:1]         // 1 per end (common)

grub_screw_hole_diameter_mm = 0; //[0:4:0.1]     // set to 0 to disable radial set-screws
grub_screw_hole_depth_mm = 6; //[3:12:0.1]
grub_screw_offset_from_ends_mm = 5; //[2.5:10:0.1]
grub_screw_count_per_end = 2; //[1:4:1]

overlap_mm = 0.6; //[0.2:2:0.1]

$fn = 128;

module helical_slot(total_h, twist_deg, slot_w, r_in, r_out) {
    linear_extrude(height=total_h, twist=twist_deg, center=true, convexity=10)
        translate([r_in, -slot_w/2])
            square([max(0.01, r_out - r_in), slot_w], center=false);
}

module clamp_split_cut(r_outer, h, split_w, bridge_t) {
    // Split along +X direction, but leave a small bridge at -X so the part stays ONE connected solid.
    // Cut is a rectangular prism that spans almost the full diameter, stopping short by bridge_t.
    // X extent: from (-r_outer + bridge_t) to (+r_outer)
    x_len = (2*r_outer - bridge_t);
    x_center = (-r_outer + bridge_t) + x_len/2;

    translate([x_center, 0, 0])
        cube([x_len + overlap_mm, split_w, h + overlap_mm], center=true);
}

module pinch_screw_hole(z_pos, r_outer, hole_d, head_d, head_depth) {
    // Through-hole across Y (pinch direction), with counterbore on +Y side.
    // Place at x = 0 so it crosses the split plane (y=0) and clamps it.
    // Through hole:
    translate([0, 0, z_pos])
        rotate([90, 0, 0])
            cylinder(d=hole_d, h=2*r_outer + overlap_mm, center=true, $fn=48);

    // Counterbore (head) on +Y side:
    translate([0, (r_outer - head_depth/2), z_pos])
        rotate([90, 0, 0])
            cylinder(d=head_d, h=head_depth + overlap_mm, center=true, $fn=64);
}

module coupling() {
    r_outer = outer_diameter_mm/2;

    // Bore depths clamped to length
    b1 = min(bore1_depth_mm, overall_length_mm);
    b2 = min(bore2_depth_mm, overall_length_mm);

    // Center web region (no helical cuts here) to keep part connected
    web_h = min(center_web_thickness_mm, overall_length_mm - 0.2);
    cut_h_each_side = max(0, (overall_length_mm - web_h)/2);

    difference() {
        // Main body
        cylinder(r=r_outer, h=overall_length_mm, center=true);

        // Stepped bores (6mm one side, 8mm other side)
        // Bore 1 (negative Z side)
        translate([0, 0, -overall_length_mm/2 + b1/2])
            cylinder(d=bore1_diameter_mm, h=b1 + overlap_mm, center=true, $fn=96);

        // Bore 2 (positive Z side)
        translate([0, 0, overall_length_mm/2 - b2/2])
            cylinder(d=bore2_diameter_mm, h=b2 + overlap_mm, center=true, $fn=96);

        // Small relief at the step (keeps step visible but avoids razor edge)
        if (center_relief_width_mm > 0)
            cylinder(d=max(bore1_diameter_mm, bore2_diameter_mm),
                     h=center_relief_width_mm + overlap_mm, center=true, $fn=96);

        // Helical/beam cuts: do NOT cut through the center web
        if (cut_h_each_side > 0) {
            // Negative side
            for (i = [0:helical_cut_count-1]) {
                rotate([0, 0, i*360/helical_cut_count])
                    translate([0, 0, -(web_h/2 + cut_h_each_side/2)])
                        helical_slot(
                            total_h = cut_h_each_side + overlap_mm,
                            twist_deg = -flexure_twist_deg/2,
                            slot_w = helical_cut_width_mm,
                            r_in = max(0.01, r_outer - helical_cut_radial_depth_mm),
                            r_out = r_outer + overlap_mm
                        );
            }
            // Positive side (phase shifted)
            for (i = [0:helical_cut_count-1]) {
                rotate([0, 0, i*360/helical_cut_count + 180/helical_cut_count])
                    translate([0, 0, +(web_h/2 + cut_h_each_side/2)])
                        helical_slot(
                            total_h = cut_h_each_side + overlap_mm,
                            twist_deg = flexure_twist_deg/2,
                            slot_w = helical_cut_width_mm,
                            r_in = max(0.01, r_outer - helical_cut_radial_depth_mm),
                            r_out = r_outer + overlap_mm
                        );
            }
        }

        // Clamp split (does not fully separate due to bridge)
        clamp_split_cut(r_outer=r_outer, h=overall_length_mm,
                        split_w=clamp_split_width_mm,
                        bridge_t=clamp_bridge_thickness_mm);

        // Pinch screws (across Y) near each end
        for (endSign = [-1, 1]) {
            z_end = endSign*(overall_length_mm/2 - pinch_screw_offset_from_ends_mm);
            for (k = [0:pinch_screw_count_per_end-1]) {
                // If 2 per end, spread slightly along Z around the nominal position
                z_k = z_end + ( (pinch_screw_count_per_end==1) ? 0
                         : (k==0 ? -outer_diameter_mm*0.12 : outer_diameter_mm*0.12) );
                pinch_screw_hole(z_pos=z_k, r_outer=r_outer,
                                 hole_d=pinch_screw_diameter_mm,
                                 head_d=pinch_screw_head_diameter_mm,
                                 head_depth=pinch_screw_head_depth_mm);
            }
        }

        // Optional radial set-screw holes (disabled by default)
        if (grub_screw_hole_diameter_mm > 0) {
            for (endSign = [-1, 1]) {
                z_end = endSign*(overall_length_mm/2 - grub_screw_offset_from_ends_mm);
                for (k = [0:grub_screw_count_per_end-1]) {
                    ang = k*360/grub_screw_count_per_end + 90; // avoid aligning with split
                    rotate([0, 0, ang])
                        translate([r_outer - (grub_screw_hole_depth_mm + overlap_mm)/2, 0, z_end])
                            rotate([0, 90, 0])
                                cylinder(d=grub_screw_hole_diameter_mm,
                                         h=grub_screw_hole_depth_mm + overlap_mm,
                                         center=true, $fn=48);
                }
            }
        }
    }
}

coupling();