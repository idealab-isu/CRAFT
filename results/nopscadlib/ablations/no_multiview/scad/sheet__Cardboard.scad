// Parameters
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 4; //[2:8:0.1]
flute_pitch = 8; //[4:16:0.1]
flute_amp = 1.5; //[0.75:3:0.05]
liner_T = 0.4; //[0.2:0.8:0.05]
core_web_T = 0.3; //[0.15:0.6:0.05]
corner_R = 8; //[2:20:0.5]
edge_exposure_T = 1.2; //[0.6:2.4:0.1]
edge_overlap = 1; //[0.5:2:0.1]
flute_dir_L = 1; //[0:1:1]

// Base Shapes
module sheet_panel_raw() {
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module corner_cut_cyl() {
  cylinder(r=corner_R, h=sheet_T + 2*edge_overlap, center=true);
}

module corner_cut_box() {
  cube([corner_R, corner_R, sheet_T + 2*edge_overlap], center=true);
}

module liner_top() {
  translate([0, 0, sheet_T/2 - liner_T/2])
    cube([sheet_L, sheet_W, liner_T], center=true);
}

module liner_bottom() {
  translate([0, 0, -sheet_T/2 + liner_T/2])
    cube([sheet_L, sheet_W, liner_T], center=true);
}

module corrugation_profile() {
  linear_extrude(height=sheet_L + 2*edge_overlap, center=true) {
    polygon(points=[
      [-sheet_W/2 - edge_overlap, 0],
      [-sheet_W/2 - edge_overlap, core_web_T],
      [-sheet_W/2 + flute_pitch/4, core_web_T],
      [-sheet_W/2 + flute_pitch/4, flute_amp + core_web_T],
      [-sheet_W/2 + 3*flute_pitch/4, flute_amp + core_web_T],
      [-sheet_W/2 + 3*flute_pitch/4, core_web_T],
      [-sheet_W/2 + 5*flute_pitch/4, core_web_T],
      [-sheet_W/2 + 5*flute_pitch/4, flute_amp + core_web_T],
      [-sheet_W/2 + 7*flute_pitch/4, flute_amp + core_web_T],
      [-sheet_W/2 + 7*flute_pitch/4, core_web_T],
      [sheet_W/2 + edge_overlap, core_web_T],
      [sheet_W/2 + edge_overlap, 0]
    ]);
  }
}

module edge_flute_exposure_x() {
  translate([sheet_L/2 - edge_exposure_T/2, 0, 0])
    cube([edge_exposure_T, sheet_W, sheet_T], center=true);
}

module edge_flute_exposure_x_mirror() {
  translate([-sheet_L/2 + edge_exposure_T/2, 0, 0])
    cube([edge_exposure_T, sheet_W, sheet_T], center=true);
}

module edge_flute_exposure_y() {
  translate([0, sheet_W/2 - edge_exposure_T/2, 0])
    cube([sheet_L, edge_exposure_T, sheet_T], center=true);
}

module edge_flute_exposure_y_mirror() {
  translate([0, -sheet_W/2 + edge_exposure_T/2, 0])
    cube([sheet_L, edge_exposure_T, sheet_T], center=true);
}

module material_texture() {
  translate([0, 0, sheet_T/2 - edge_overlap/2])
    cube([sheet_L, sheet_W, edge_overlap], center=true);
}

// Operations
module corner_quarter_ne() {
  intersection() {
    translate([sheet_L/2 - corner_R, sheet_W/2 - corner_R, 0]) corner_cut_cyl();
    translate([sheet_L/2 - corner_R/2, sheet_W/2 - corner_R/2, 0]) corner_cut_box();
  }
}

module corner_quarter_nw() {
  intersection() {
    translate([-sheet_L/2 + corner_R, sheet_W/2 - corner_R, 0]) corner_cut_cyl();
    translate([-sheet_L/2 + corner_R/2, sheet_W/2 - corner_R/2, 0]) corner_cut_box();
  }
}

module corner_quarter_se() {
  intersection() {
    translate([sheet_L/2 - corner_R, -sheet_W/2 + corner_R, 0]) corner_cut_cyl();
    translate([sheet_L/2 - corner_R/2, -sheet_W/2 + corner_R/2, 0]) corner_cut_box();
  }
}

module corner_quarter_sw() {
  intersection() {
    translate([-sheet_L/2 + corner_R, -sheet_W/2 + corner_R, 0]) corner_cut_cyl();
    translate([-sheet_L/2 + corner_R/2, -sheet_W/2 + corner_R/2, 0]) corner_cut_box();
  }
}

module sheet_panel() {
  difference() {
    sheet_panel_raw();
    corner_quarter_ne();
    corner_quarter_nw();
    corner_quarter_se();
    corner_quarter_sw();
  }
}

module kraft_liner_layers() {
  union() {
    liner_top();
    liner_bottom();
  }
}

module edge_flute_exposure() {
  union() {
    edge_flute_exposure_x();
    edge_flute_exposure_x_mirror();
    edge_flute_exposure_y();
    edge_flute_exposure_y_mirror();
  }
}

module rounded_corners() {
  union() {
    sheet_panel();
    kraft_liner_layers();
    translate([0, 0, -sheet_T/2 + liner_T + (sheet_T - 2*liner_T)/2 - flute_amp/2]) corrugation_profile();
    edge_flute_exposure();
    material_texture();
  }
}

// Final Output
rounded_corners();