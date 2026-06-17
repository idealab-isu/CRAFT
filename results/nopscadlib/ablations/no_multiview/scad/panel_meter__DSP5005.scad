// Parameters
overall_x_mm = 48; //[24:96:1]
overall_y_mm = 29; //[15:58:1]
overall_z_mm = 24; //[12:48:1]
bezel_x_mm = 50; //[25:100:1]
bezel_y_mm = 31; //[16:62:1]
bezel_z_mm = 3; //[1.5:8:0.5]
bezel_corner_radius_mm = 2.5; //[0:8:0.5]
bezel_bevel_mm = 0.8; //[0:3:0.1]
body_depth_behind_bezel_mm = 21; //[10:45:1]
body_wall_thickness_mm = 1.5; //[0:4:0.1]
display_aperture_x_mm = 36; //[18:72:1]
display_aperture_y_mm = 18; //[9:36:1]
display_aperture_corner_radius_mm = 1.2; //[0:6:0.2]
panel_cutout_x_mm = 45; //[22:90:1]
panel_cutout_y_mm = 26; //[13:52:1]
panel_reference_thickness_mm = 2; //[1:6:0.5]
tab_enabled = 1; //[0:1:1]
tab_x_mm = 6; //[3:15:0.5]
tab_y_mm = 12; //[6:25:1]
tab_z_mm = 2.5; //[1:6:0.5]
tab_offset_z_mm = 6; //[0:20:1]
pcb_enabled = 1; //[0:1:1]
pcb_x_mm = 42; //[21:84:1]
pcb_y_mm = 24; //[12:48:1]
pcb_z_mm = 1.6; //[0.8:3.2:0.1]
pcb_offset_z_mm = 6; //[0:20:1]
inner_insert_enabled = 1; //[0:1:1]
inner_insert_thickness_mm = 1.2; //[0.6:3:0.1]
inner_insert_border_mm = 2; //[1:6:0.5]
buttons_enabled = 0; //[0:1:1]
button_diameter_mm = 4; //[2:10:0.5]
button_height_mm = 1.5; //[0.8:4:0.1]
button_spacing_x_mm = 7; //[4:20:0.5]
button_row_offset_y_mm = 10; //[5:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Module for Mod
module mod() {
  color([0.0, 0.4, 0.2]) {
    cube([pcb_x_mm, pcb_y_mm, pcb_z_mm], center=true);
  }
}

// Panel meter solid (bezel + body + side tabs) as ONE connected union
module panel_meter() {

  // Key Z references (bezel centered at z=0)
  body_center_z = -(bezel_z_mm/2 + body_depth_behind_bezel_mm/2 - overlap_mm);

  // Body extents in Z
  body_top_z    = body_center_z + body_depth_behind_bezel_mm/2;
  body_bottom_z = body_center_z - body_depth_behind_bezel_mm/2;

  // Tab placement: attach to LEFT and RIGHT sides of the main body,
  // and place one near the top and one near the bottom (as seen in views).
  // Ensure intersection with body by overlapping in X by overlap_mm.
  tab_center_x_right =  overall_x_mm/2 + tab_x_mm/2 - overlap_mm;
  tab_center_x_left  = -overall_x_mm/2 - tab_x_mm/2 + overlap_mm;

  // Put tabs within the body's Z span (not floating), with a small inset from ends.
  tab_center_z_top    = body_top_z    - tab_z_mm/2 - overlap_mm/2;
  tab_center_z_bottom = body_bottom_z + tab_z_mm/2 + overlap_mm/2;

  color("Black") {
    union() {

      // Front Bezel
      difference() {
        hull() {
          for (i = [0:3]) {
            rotate([0, 0, i * 90])
              translate([bezel_x_mm/2 - bezel_corner_radius_mm,
                         bezel_y_mm/2 - bezel_corner_radius_mm, 0])
                cylinder(r=bezel_corner_radius_mm, h=bezel_z_mm, center=true);
          }
        }
        hull() {
          for (i = [0:3]) {
            rotate([0, 0, i * 90])
              translate([bezel_x_mm/2 - bezel_corner_radius_mm,
                         bezel_y_mm/2 - bezel_corner_radius_mm, bezel_bevel_mm/2])
                cylinder(r=max(0, bezel_corner_radius_mm - bezel_bevel_mm),
                         h=bezel_z_mm, center=true);
          }
        }
      }

      // Main Body (behind bezel) - overlaps bezel by overlap_mm
      translate([0, 0, body_center_z])
      difference() {
        cube([overall_x_mm, overall_y_mm, body_depth_behind_bezel_mm], center=true);
        translate([0, 0, body_wall_thickness_mm])
          cube([max(0, overall_x_mm - 2*body_wall_thickness_mm),
                max(0, overall_y_mm - 2*body_wall_thickness_mm),
                max(0, body_depth_behind_bezel_mm - 2*body_wall_thickness_mm)], center=true);
      }

      // Side tabs/connectors (FIX: ensure they intersect the body; no floating parts)
      if (tab_enabled) {

        // Right side, near TOP (matches "right edge in TOP view")
        translate([tab_center_x_right, 0, tab_center_z_top])
          cube([tab_x_mm, tab_y_mm, tab_z_mm], center=true);

        // Left side, near BOTTOM (matches "left edge in BOTTOM view")
        translate([tab_center_x_left, 0, tab_center_z_bottom])
          cube([tab_x_mm, tab_y_mm, tab_z_mm], center=true);
      }
    }
  }
}

// Module for Panel Meter Button
module panel_meter_button() {
  if (buttons_enabled) {
    color("White") {
      translate([-button_spacing_x_mm/2, -button_row_offset_y_mm, bezel_z_mm/2 + button_height_mm/2 - overlap_mm])
        cylinder(r=button_diameter_mm/2, h=button_height_mm, center=true);
      translate([button_spacing_x_mm/2, -button_row_offset_y_mm, bezel_z_mm/2 + button_height_mm/2 - overlap_mm])
        cylinder(r=button_diameter_mm/2, h=button_height_mm, center=true);
    }
  }
}

// Module for Panel Meter Cutout
module panel_meter_cutout() {
  color("Silver") {
    translate([0, 0, bezel_z_mm/2 - panel_reference_thickness_mm/2 + overlap_mm/2])
      cube([panel_cutout_x_mm, panel_cutout_y_mm, panel_reference_thickness_mm], center=true);
  }
}

// Assembly (keep as separate visual parts; panel_meter itself is a single connected union)
module assembly() {
  mod();
  panel_meter();
  panel_meter_button();
  panel_meter_cutout();
}

assembly();