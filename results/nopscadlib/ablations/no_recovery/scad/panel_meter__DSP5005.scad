// Parameters
module_variant = 1; //[1:1:1]
overall_size_x_mm = 48; //[24:96:1]
overall_size_y_mm = 29; //[15:58:1]
overall_size_z_mm = 25; //[12:50:1]
bezel_size_x_mm = 50; //[25:100:1]
bezel_size_y_mm = 31; //[16:62:1]
bezel_size_z_mm = 3; //[1.5:8:0.5]
bezel_corner_radius_mm = 2.5; //[0:6:0.5]
bezel_bevel_mm = 1; //[0:3:0.5]
body_depth_mm = 22; //[10:44:1]
wall_thickness_mm = 1.5; //[0:4:0.5]
display_aperture_x_mm = 36; //[18:72:1]
display_aperture_y_mm = 18; //[9:36:1]
aperture_corner_radius_mm = 1; //[0:4:0.5]
inner_aperture_x_mm = 30; //[15:60:1]
inner_aperture_y_mm = 14; //[7:28:1]
inner_aperture_z_mm = 1.2; //[0:4:0.2]
inner_aperture_offset_x_mm = 0; //[-5:5:0.5]
inner_aperture_offset_y_mm = 0; //[-5:5:0.5]
tab_size_x_mm = 6; //[3:12:0.5]
tab_size_y_mm = 12; //[6:24:1]
tab_size_z_mm = 2; //[1:5:0.5]
tab_offset_z_mm = 6; //[0:20:1]
pcb_size_x_mm = 44; //[22:88:1]
pcb_size_y_mm = 25; //[12:50:1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_offset_z_mm = 6; //[0:20:1]
button_diameter_mm = 4; //[2:8:0.5]
button_height_mm = 1.5; //[0.5:5:0.5]
button_spacing_x_mm = 6; //[3:15:0.5]
button_row_offset_y_mm = 10; //[0:20:0.5]
panel_cutout_clearance_mm = 0.2; //[0:1:0.05]
cutout_extrusion_height_mm = 3; //[0:20:1]
rear_clearance_extra_mm = 2; //[0:10:0.5]
overlap_mm = 1; //[0.5:2:0.5]

// Bezel with display aperture
module bezel_with_aperture() {
  color("Black") {
    difference() {
      hull() {
        translate([bezel_size_x_mm/2 - bezel_corner_radius_mm, bezel_size_y_mm/2 - bezel_corner_radius_mm, 0])
          cylinder(r=bezel_corner_radius_mm, h=bezel_size_z_mm, center=true);
        translate([-(bezel_size_x_mm/2 - bezel_corner_radius_mm), bezel_size_y_mm/2 - bezel_corner_radius_mm, 0])
          cylinder(r=bezel_corner_radius_mm, h=bezel_size_z_mm, center=true);
        translate([bezel_size_x_mm/2 - bezel_corner_radius_mm, -(bezel_size_y_mm/2 - bezel_corner_radius_mm), 0])
          cylinder(r=bezel_corner_radius_mm, h=bezel_size_z_mm, center=true);
        translate([-(bezel_size_x_mm/2 - bezel_corner_radius_mm), -(bezel_size_y_mm/2 - bezel_corner_radius_mm), 0])
          cylinder(r=bezel_corner_radius_mm, h=bezel_size_z_mm, center=true);
      }
      hull() {
        translate([display_aperture_x_mm/2 - aperture_corner_radius_mm, display_aperture_y_mm/2 - aperture_corner_radius_mm, 0])
          cylinder(r=aperture_corner_radius_mm, h=bezel_size_z_mm + 2*overlap_mm, center=true);
        translate([-(display_aperture_x_mm/2 - aperture_corner_radius_mm), display_aperture_y_mm/2 - aperture_corner_radius_mm, 0])
          cylinder(r=aperture_corner_radius_mm, h=bezel_size_z_mm + 2*overlap_mm, center=true);
        translate([display_aperture_x_mm/2 - aperture_corner_radius_mm, -(display_aperture_y_mm/2 - aperture_corner_radius_mm), 0])
          cylinder(r=aperture_corner_radius_mm, h=bezel_size_z_mm + 2*overlap_mm, center=true);
        translate([-(display_aperture_x_mm/2 - aperture_corner_radius_mm), -(display_aperture_y_mm/2 - aperture_corner_radius_mm), 0])
          cylinder(r=aperture_corner_radius_mm, h=bezel_size_z_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Main body housing
module main_body_housing() {
  color("DimGray") {
    difference() {
      translate([0, 0, -(bezel_size_z_mm/2 + body_depth_mm/2 - overlap_mm)])
        cube([overall_size_x_mm, overall_size_y_mm, body_depth_mm], center=true);
      translate([0, 0, -(bezel_size_z_mm/2 + body_depth_mm/2 - overlap_mm) + wall_thickness_mm/2])
        cube([overall_size_x_mm - 2*wall_thickness_mm, overall_size_y_mm - 2*wall_thickness_mm, body_depth_mm - wall_thickness_mm], center=true);
    }
  }
}

// Panel mount tabs or clips
module panel_mount_tabs_or_clips() {
  color("Silver") {
    union() {
      translate([-(overall_size_x_mm/2 + tab_size_x_mm/2 - overlap_mm), 0, -(bezel_size_z_mm/2 + body_depth_mm - tab_offset_z_mm - tab_size_z_mm/2)])
        cube([tab_size_x_mm, tab_size_y_mm, tab_size_z_mm], center=true);
      translate([overall_size_x_mm/2 + tab_size_x_mm/2 - overlap_mm, 0, -(bezel_size_z_mm/2 + body_depth_mm - tab_offset_z_mm - tab_size_z_mm/2)])
        cube([tab_size_x_mm, tab_size_y_mm, tab_size_z_mm], center=true);
    }
  }
}

// PCB representation
module pcb_representation() {
  color([0.0, 0.4, 0.2]) {
    translate([0, 0, -(bezel_size_z_mm/2 + body_depth_mm - pcb_offset_z_mm - pcb_thickness_mm/2)])
      cube([pcb_size_x_mm, pcb_size_y_mm, pcb_thickness_mm], center=true);
  }
}

// Panel meter buttons
module panel_meter_button() {
  color("White") {
    union() {
      translate([-button_spacing_x_mm/2, button_row_offset_y_mm, bezel_size_z_mm/2 + button_height_mm/2 - overlap_mm])
        cylinder(r=button_diameter_mm/2, h=button_height_mm, center=true);
      translate([button_spacing_x_mm/2, button_row_offset_y_mm, bezel_size_z_mm/2 + button_height_mm/2 - overlap_mm])
        cylinder(r=button_diameter_mm/2, h=button_height_mm, center=true);
    }
  }
}

// Inner aperture frame
module inner_aperture_frame() {
  color("Black") {
    difference() {
      translate([inner_aperture_offset_x_mm, inner_aperture_offset_y_mm, bezel_size_z_mm/2 - inner_aperture_z_mm/2])
        cube([display_aperture_x_mm, display_aperture_y_mm, inner_aperture_z_mm], center=true);
      translate([inner_aperture_offset_x_mm, inner_aperture_offset_y_mm, bezel_size_z_mm/2 - inner_aperture_z_mm/2])
        cube([inner_aperture_x_mm, inner_aperture_y_mm, inner_aperture_z_mm + 2*overlap_mm], center=true);
    }
  }
}

// Panel meter
module panel_meter() {
  union() {
    bezel_with_aperture();
    main_body_housing();
    panel_mount_tabs_or_clips();
    pcb_representation();
    panel_meter_button();
    inner_aperture_frame();
  }
}

// Rear clearance volume
module rear_clearance_volume() {
  color([0.85, 0.85, 0.8, 0.5]) {
    translate([0, 0, -(bezel_size_z_mm/2 + (body_depth_mm + rear_clearance_extra_mm)/2 - overlap_mm)])
      cube([overall_size_x_mm + 2*rear_clearance_extra_mm, overall_size_y_mm + 2*rear_clearance_extra_mm, body_depth_mm + rear_clearance_extra_mm], center=true);
  }
}

// Mod
module mod() {
  union() {
    panel_meter();
    rear_clearance_volume();
  }
}

// Panel meter cutout
module panel_meter_cutout() {
  color("Black") {
    translate([0, 0, -(bezel_size_z_mm/2 + body_depth_mm + cutout_extrusion_height_mm/2 + overlap_mm)])
      cube([overall_size_x_mm + 2*panel_cutout_clearance_mm + 2*tab_size_x_mm, overall_size_y_mm + 2*panel_cutout_clearance_mm, cutout_extrusion_height_mm], center=true);
  }
}

// Assembly
module assembly() {
  mod();
  panel_meter_cutout();
}

assembly();