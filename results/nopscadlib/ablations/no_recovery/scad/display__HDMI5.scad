// Parameters
display_width_mm = 121; //[60.5:242:1]
display_height_mm = 76; //[38:152:1]
display_thickness_mm = 2.85; //[1.4:5.7:0.05]
pcb_offset_x_mm = 0; //[-10:10:0.5]
pcb_offset_y_mm = 0; //[-10:10:0.5]
pcb_offset_z_mm = 1.9; //[0:6:0.1]
aperture_min_x_mm = -54; //[-108:-27:0.5]
aperture_min_y_mm = -30.225; //[-60.45:-15.1125:0.5]
aperture_max_x_mm = 54; //[27:108:0.5]
aperture_max_y_mm = 34.575; //[17.2875:69.15:0.5]
aperture_depth_mm = 0.5; //[0.25:2:0.05]
touch_min_x_mm = -58.7; //[-117.4:-29.35:0.5]
touch_min_y_mm = -34; //[-68:-17:0.5]
touch_max_x_mm = 58.7; //[29.35:117.4:0.5]
touch_max_y_mm = 36.25; //[18.125:72.5:0.5]
touch_thickness_mm = 1; //[0.5:3:0.05]
thread_length_mm = 2; //[1:6:0.25]
ts_ribbon_min_x_mm = -2.5; //[-10:0:0.5]
ts_ribbon_min_y_mm = -39; //[-78:-19.5:0.5]
ts_ribbon_max_x_mm = 10.5; //[5.25:21:0.5]
ts_ribbon_max_y_mm = -33; //[-66:-16.5:0.5]
bezel_wall_mm = 3; //[1.5:8:0.5]
bezel_thickness_mm = 6; //[3:15:0.5]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_mm = 4; //[2:12:0.5]
hdmi_width_mm = 14; //[7:28:0.5]
hdmi_height_mm = 6; //[3:12:0.5]
hdmi_depth_mm = 12; //[6:24:0.5]
screw_knob_radius_mm = 6; //[3:12:0.5]
screw_knob_height_mm = 4; //[2:10:0.5]
screw_shaft_radius_mm = 1.5; //[0.8:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Display - complete geometry
module display() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Main display body
      cube([display_width_mm + 2*bezel_wall_mm, display_height_mm + 2*bezel_wall_mm, bezel_thickness_mm], center=true);
      // Front aperture cutout
      translate([(aperture_min_x_mm + aperture_max_x_mm)/2, (aperture_min_y_mm + aperture_max_y_mm)/2, bezel_thickness_mm/2 - (aperture_depth_mm + overlap_mm)/2])
        cube([aperture_max_x_mm - aperture_min_x_mm, aperture_max_y_mm - aperture_min_y_mm, aperture_depth_mm + overlap_mm], center=true);
    }
  }
}

// HDMI - complete geometry
module hdmi() {
  color([0.1, 0.1, 0.6]) {
    translate([(display_width_mm - 2*pcb_margin_mm)/2 - hdmi_depth_mm/2 + pcb_offset_x_mm, pcb_offset_y_mm, bezel_thickness_mm/2 + display_thickness_mm + pcb_offset_z_mm + hdmi_height_mm/2 - overlap_mm])
      cube([hdmi_depth_mm, hdmi_width_mm, hdmi_height_mm], center=true);
  }
}

// PCB - complete geometry
module pcb() {
  color([0.0, 0.4, 0.2]) {
    translate([pcb_offset_x_mm, pcb_offset_y_mm, bezel_thickness_mm/2 + display_thickness_mm + pcb_offset_z_mm + pcb_thickness_mm/2 - overlap_mm])
      cube([display_width_mm - 2*pcb_margin_mm, display_height_mm - 2*pcb_margin_mm, pcb_thickness_mm], center=true);
  }
}

// Display Aperture - complete geometry
module display_aperture() {
  color([0.85, 0.85, 0.8]) {
    translate([(aperture_min_x_mm + aperture_max_x_mm)/2, (aperture_min_y_mm + aperture_max_y_mm)/2, 0])
      cube([aperture_max_x_mm - aperture_min_x_mm, aperture_max_y_mm - aperture_min_y_mm, bezel_thickness_mm + 2*overlap_mm], center=true);
  }
}

// Screw Knob Assembly - complete geometry
module screw_knob_assembly() {
  color([0.2, 0.2, 0.2]) {
    union() {
      // Knob
      translate([0, 0, -bezel_thickness_mm/2 - screw_knob_height_mm/2 + overlap_mm])
        cylinder(r=screw_knob_radius_mm, h=screw_knob_height_mm, center=true);
      // Shaft
      translate([0, 0, -bezel_thickness_mm/2 + (thread_length_mm - screw_knob_height_mm)/2])
        cylinder(r=screw_shaft_radius_mm, h=thread_length_mm + screw_knob_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  display();
  hdmi();
  pcb();
  display_aperture();
  screw_knob_assembly();
}

assembly();