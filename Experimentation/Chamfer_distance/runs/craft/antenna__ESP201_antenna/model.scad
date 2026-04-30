// Parameters (mm)
total_length_mm = 108.5; //[54.25:217:0.1]
base_diameter_mm = 9.5; //[4.75:19:0.1]
tip_diameter_mm = 7.9; //[3.95:15.8:0.1]
fixed_straight_section_length_mm = 20.6; //[10.3:41.2:0.1]
pivot_distance_from_base_mm = 20.6; //[10.3:41.2:0.1]
panel_gap_for_washers_and_nuts_mm = 6.45; //[3.225:12.9:0.05]
default_fold_angle_deg = 0; //[0:180:1]
overlap_mm = 1; //[0.5:2:0.1]
hinge_block_length_mm = 10.85; //[5.425:21.7:0.05]
hinge_block_width_mm = 13.02; //[6.51:26.04:0.05]
hinge_block_height_mm = 11.935; //[5.9675:23.87:0.05]
pivot_pin_diameter_mm = 3.255; //[1.6275:6.51:0.05]
panel_shank_diameter_mm = 6.65; //[3.325:13.3:0.05]
panel_shank_length_mm = 16.275; //[8.1375:32.55:0.05]
base_interface_diameter_mm = 14.25; //[7.125:28.5:0.05]
base_interface_thickness_mm = 4.34; //[2.17:8.68:0.05]
knob_diameter_mm = 10.85; //[5.425:21.7:0.05]
knob_thickness_mm = 4.34; //[2.17:8.68:0.05]

// Quality
$fn=32;

// Derived Z positions from plan (kept as expressions for parametric fidelity)
z_base_interface = 0;

z_panel_mount_shank =
  base_interface_thickness_mm/2 + panel_shank_length_mm/2 - overlap_mm;

z_panel_gap_spacer_region =
  base_interface_thickness_mm/2 + panel_shank_length_mm - overlap_mm
  + panel_gap_for_washers_and_nuts_mm/2 - overlap_mm;

z_box_section =
  base_interface_thickness_mm/2 + panel_shank_length_mm - overlap_mm
  + panel_gap_for_washers_and_nuts_mm - overlap_mm
  + hinge_block_height_mm/2 - overlap_mm;

z_fixed_straight_section =
  base_interface_thickness_mm/2 + panel_shank_length_mm - overlap_mm
  + panel_gap_for_washers_and_nuts_mm - overlap_mm
  + hinge_block_height_mm - overlap_mm
  + fixed_straight_section_length_mm/2 - overlap_mm;

z_whip_body =
  base_interface_thickness_mm/2 + panel_shank_length_mm - overlap_mm
  + panel_gap_for_washers_and_nuts_mm - overlap_mm
  + hinge_block_height_mm - overlap_mm
  + fixed_straight_section_length_mm - overlap_mm
  + (total_length_mm - fixed_straight_section_length_mm)/2 - overlap_mm;

z_pivot_center =
  base_interface_thickness_mm/2 + panel_shank_length_mm - overlap_mm
  + panel_gap_for_washers_and_nuts_mm - overlap_mm
  + hinge_block_height_mm - overlap_mm
  + pivot_distance_from_base_mm;

x_knob_center =
  hinge_block_width_mm/2 + knob_thickness_mm/2 - overlap_mm;

// ---------- Helpers ----------
module rounded_box_2d(w, l, r) {
  // 2D rounded rectangle centered at origin
  rr = min(r, min(w, l)/2);
  offset(r=rr) square([w-2*rr, l-2*rr], center=true);
}

module box_section() {
  // Detailed hinge block: rounded edges + shallow side recesses + small top chamfer-like flats
  color([0.15, 0.15, 0.17]) {
    r_corner = min(1.2, min(hinge_block_width_mm, hinge_block_length_mm)/6);
    recess_d = min(0.9, hinge_block_width_mm/10);
    recess_h = min(hinge_block_height_mm*0.55, hinge_block_height_mm-1.2);

    translate([0, 0, z_box_section])
    difference() {
      // Main rounded block
      linear_extrude(height=hinge_block_height_mm, center=true)
        rounded_box_2d(hinge_block_width_mm, hinge_block_length_mm, r_corner);

      // Side recesses (visual detail), keep shallow so it remains strong
      for (sx = [-1, 1]) {
        translate([sx*(hinge_block_width_mm/2 - recess_d/2 + 0.01), 0, 0])
          cube([recess_d, hinge_block_length_mm*0.72, recess_h], center=true);
      }

      // Small top flats (pseudo-chamfer)
      translate([0, 0, hinge_block_height_mm/2 - 0.6])
        cube([hinge_block_width_mm*0.92, hinge_block_length_mm*0.92, 1.2], center=true);
    }
  }
}

module screw_knob_assembly() {
  // Detailed knob + through screw shank (visual), aligned along X (as per plan rotation)
  // Note: This is UNIONED into the printed part per plan (single connected solid).
  color([0.2, 0.2, 0.22]) {
    knob_r = knob_diameter_mm/2;
    knob_h = knob_thickness_mm;

    // Knurling bumps
    n_knurls = 18;
    bump_r = min(0.55, knob_r*0.12);
    bump_out = min(0.7, knob_r*0.14);

    translate([x_knob_center, 0, z_pivot_center])
    rotate([0, 90, 0])  // cylinder axis along X
    union() {
      // Knob disk
      cylinder(r=knob_r, h=knob_h, center=true);

      // Slight front cap
      translate([0, 0, knob_h/2 - 0.6])
        cylinder(r=knob_r*0.92, h=1.2, center=true);

      // Knurl bumps around perimeter
      for (i = [0:n_knurls-1]) {
        ang = i*360/n_knurls;
        rotate([0, 0, ang])
          translate([knob_r - bump_out, 0, 0])
            cylinder(r=bump_r, h=knob_h*0.85, center=true, $fn=16);
      }

      // Integrated "screw shank" stub (visual cue), not subtracted (single solid)
      // Runs toward hinge block to suggest a screw passing through.
      shank_d = max(2.2, pivot_pin_diameter_mm*0.85);
      shank_len = max(hinge_block_width_mm*0.55, knob_h*1.2);
      translate([0, 0, -knob_h/2 - shank_len/2 + 0.2])
        cylinder(d=shank_d, h=shank_len, center=true, $fn=24);
    }
  }
}

module mod() {
  // Full module solid before pivot hole subtraction (as per plan "mod" union)
  color([0.75, 0.75, 0.77]) {
    union() {
      // base_mount_interface
      translate([0, 0, z_base_interface])
        cylinder(r=base_interface_diameter_mm/2, h=base_interface_thickness_mm, center=true);

      // panel_mount_shank
      translate([0, 0, z_panel_mount_shank])
        cylinder(r=panel_shank_diameter_mm/2, h=panel_shank_length_mm, center=true);

      // panel_gap_spacer_region
      translate([0, 0, z_panel_gap_spacer_region])
        cylinder(r=panel_shank_diameter_mm/2, h=panel_gap_for_washers_and_nuts_mm, center=true);

      // pivot_hinge_feature = union(box_section, screw_knob_assembly)
      union() {
        box_section();
        screw_knob_assembly();
      }

      // fixed_straight_section
      translate([0, 0, z_fixed_straight_section])
        cylinder(r=base_diameter_mm/2, h=fixed_straight_section_length_mm, center=true);

      // whip_body (tapered)
      // Visual fold angle parameter exists; plan geometry is straight. Keep straight to match plan.
      translate([0, 0, z_whip_body])
        cylinder(h=total_length_mm - fixed_straight_section_length_mm,
                 r1=base_diameter_mm/2, r2=tip_diameter_mm/2, center=true);
    }
  }
}

module antenna_with_pivot_hole() {
  difference() {
    mod();

    // pivot_pin_hole (subtract)
    translate([0, 0, z_pivot_center])
      rotate([0, 90, 0])
        cylinder(r=pivot_pin_diameter_mm/2,
                 h=hinge_block_width_mm + 2*overlap_mm,
                 center=true, $fn=32);
  }
}

module assembly() {
  // Primary at origin: base_mount_interface is centered at [0,0,0] within mod()
  antenna_with_pivot_hole();
}

assembly();