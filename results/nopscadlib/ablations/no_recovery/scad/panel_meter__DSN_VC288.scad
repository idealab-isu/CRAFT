// Parameters
voltage_range_v = 100; //[50:200:10]
current_range_a = 10; //[5:20:1]
bezel_width = 48; //[24:96:1]
bezel_height = 29; //[15:58:1]
bezel_thickness = 3; //[1.5:6:0.5]
body_width = 45; //[22.5:90:1]
body_height = 26; //[13:52:1]
body_depth = 22; //[11:44:1]
aperture_width = 36; //[18:72:1]
aperture_height = 14; //[7:28:1]
corner_radius = 2; //[0:6:0.5]
panel_thickness_supported_min = 1; //[0.5:2:0.1]
panel_thickness_supported_max = 4; //[2:8:0.5]
tab_width = 6; //[3:12:0.5]
tab_height = 18; //[9:36:1]
tab_depth = 2.5; //[1:6:0.5]
cutout_clearance = 0.2; //[0:1:0.05]
rear_clearance_depth = 30; //[15:60:1]
connector_clearance = 10; //[5:25:1]
button_diameter = 4; //[2:8:0.5]
button_height = 1.5; //[0.5:4:0.5]
button_offset_x = 0; //[-10:10:0.5]
button_offset_y = -9; //[-14:14:0.5]
eps_overlap = 1; //[0.5:2:0.1]
panel_thickness = 3; //[1:6:0.5]
panel_margin = 12; //[6:30:1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_clearance = 1; //[0.5:3:0.5]

// Panel Meter - complete geometry
module panel_meter() {
  color("Black") {
    // Front Bezel
    difference() {
      translate([0, 0, bezel_thickness / 2])
        cube([bezel_width, bezel_height, bezel_thickness], center=true);
      translate([0, 0, bezel_thickness / 2])
        cube([aperture_width, aperture_height, bezel_thickness + 2 * eps_overlap], center=true);
    }
    // Rear Body
    translate([0, 0, -(body_depth / 2)])
      cube([body_width, body_height, body_depth], center=true);
    // Side Tabs
    translate([-(body_width / 2 + tab_width / 2 - eps_overlap), 0, -(body_depth - tab_depth / 2)])
      cube([tab_width, tab_height, tab_depth], center=true);
    translate([(body_width / 2 + tab_width / 2 - eps_overlap), 0, -(body_depth - tab_depth / 2)])
      cube([tab_width, tab_height, tab_depth], center=true);
  }
}

// Panel Meter Cutout - complete geometry
module panel_meter_cutout() {
  color("Silver") {
    difference() {
      translate([0, 0, panel_thickness / 2])
        cube([body_width + 2 * cutout_clearance, body_height + 2 * cutout_clearance, panel_thickness], center=true);
      translate([0, 0, panel_thickness / 2])
        cube([body_width, body_height, panel_thickness + eps_overlap], center=true);
    }
  }
}

// Panel Meter Button - complete geometry
module panel_meter_button() {
  color("White") {
    translate([button_offset_x, button_offset_y, bezel_thickness / 2 + button_height / 2 - eps_overlap])
      cylinder(r=button_diameter / 2, h=button_height, center=true);
  }
}

// Assembly
module assembly() {
  panel_meter();
  translate([0, 0, -(panel_thickness / 2 + rear_clearance_depth / 2 + connector_clearance / 2)])
    panel_meter_cutout();
  panel_meter_button();
}

assembly();