// Parameters
overall_width_mm = 48; //[24:96:1]
overall_height_mm = 29; //[15:58:1]
overall_depth_mm = 70; //[35:140:1]
bezel_width_mm = 52; //[26:104:1]
bezel_height_mm = 33; //[17:66:1]
bezel_thickness_mm = 3; //[1.5:6:0.5]
corner_radius_mm = 2.5; //[1:5:0.5]
panel_cutout_width_mm = 45; //[22.5:90:1]
panel_cutout_height_mm = 26; //[13:52:1]
panel_thickness_mm = 3; //[1:6:0.5]
mounting_tab_width_mm = 10; //[5:20:1]
mounting_tab_height_mm = 18; //[9:36:1]
mounting_tab_depth_mm = 6; //[3:12:1]
display_window_width_mm = 34; //[17:68:1]
display_window_height_mm = 16; //[8:32:1]
display_window_offset_x_mm = 0; //[-10:10:0.5]
display_window_offset_y_mm = 2; //[-10:10:0.5]
rear_body_wall_thickness_mm = 2; //[1:4:0.5]
rear_clearance_depth_mm = 80; //[40:160:1]
tolerance_mm = 0.2; //[0.05:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
front_detail_depth_mm = 0.8; //[0.3:2:0.1]
button_diameter_mm = 6; //[3:12:0.5]
button_height_mm = 1.5; //[0.8:4:0.1]
button_offset_x_mm = 0; //[-15:15:0.5]
button_offset_y_mm = -10; //[-20:20:0.5]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_mm = 2; //[1:6:0.5]
connector_width_mm = 20; //[10:40:1]
connector_height_mm = 10; //[5:20:1]
connector_depth_mm = 12; //[6:24:1]

// ---------- Derived Z references (centered coordinate system) ----------
front_face_z = bezel_thickness_mm;                 // front-most face of bezel (bezel centered at z=bezel_thickness/2)
rear_body_center_z = -overall_depth_mm / 2 + overlap_mm;

// Panel Meter - complete geometry (single connected solid)
module panel_meter_solid() {
  union() {
    // Front Bezel (solid)
    translate([0, 0, bezel_thickness_mm / 2])
      cube([bezel_width_mm, bezel_height_mm, bezel_thickness_mm], center=true);

    // Rear Body (hollow shell) - overlaps into bezel by overlap_mm to guarantee connection
    translate([0, 0, rear_body_center_z])
      difference() {
        cube([overall_width_mm, overall_height_mm, overall_depth_mm], center=true);
        translate([0, 0, rear_body_wall_thickness_mm])
          cube([overall_width_mm - 2 * rear_body_wall_thickness_mm,
                overall_height_mm - 2 * rear_body_wall_thickness_mm,
                overall_depth_mm - 2 * rear_body_wall_thickness_mm], center=true);
      }

    // Front Face Detailing (raised) - attached to bezel
    translate([display_window_offset_x_mm, display_window_offset_y_mm,
               front_face_z - front_detail_depth_mm / 2])
      cube([display_window_width_mm + 6 * tolerance_mm,
            display_window_height_mm + 6 * tolerance_mm,
            front_detail_depth_mm], center=true);

    // Button (silver disc) - FIXED: physically intersects bezel by overlap_mm (no floating)
    // Place button so its back face is inside the bezel by overlap_mm:
    // button_center_z = front_face_z + button_height/2 - overlap
    translate([button_offset_x_mm, button_offset_y_mm,
               front_face_z + button_height_mm / 2 - overlap_mm])
      cylinder(r=button_diameter_mm / 2, h=button_height_mm, center=true, $fn=32);
  }
}

// Panel Meter Cutout - kept as separate reference geometry (not part of the meter solid)
module panel_meter_cutout() {
  color("DimGray") {
    // Panel Cutout Profile
    translate([0, 0, -panel_thickness_mm / 2 + overlap_mm])
      cube([panel_cutout_width_mm + 2 * tolerance_mm,
            panel_cutout_height_mm + 2 * tolerance_mm,
            panel_thickness_mm], center=true);

    // Mounting Tabs
    translate([-overall_width_mm / 2 - mounting_tab_width_mm / 2 + overlap_mm, 0,
               -overall_depth_mm + mounting_tab_depth_mm / 2 + overlap_mm])
      cube([mounting_tab_width_mm, mounting_tab_height_mm, mounting_tab_depth_mm], center=true);

    translate([overall_width_mm / 2 + mounting_tab_width_mm / 2 - overlap_mm, 0,
               -overall_depth_mm + mounting_tab_depth_mm / 2 + overlap_mm])
      cube([mounting_tab_width_mm, mounting_tab_height_mm, mounting_tab_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  // Single connected solid for the meter (all parts unioned)
  color("Black") panel_meter_solid();

  // Optional reference cutout (not unioned with meter)
  panel_meter_cutout();
}

assembly();