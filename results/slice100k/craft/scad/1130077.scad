// Dimension-calibrated (target: 52.33 x 50.00 x 38.77 mm)
scale([0.999904, 0.712555, 1.404601])
{
// Parameters
bbox_L = 52.33; //[26.165:104.66:0.01]
bbox_W = 50; //[25:100:0.01]
bbox_H = 38.77; //[19.385:77.54:0.01]
sheet_t = 1.6; //[0.8:3.2:0.1]
base_L = 40; //[20:80:0.01]
base_W = 50; //[25:100:0.01]
base_t = 1.6; //[0.8:3.2:0.1]
tab_L = 12.33; //[6.165:24.66:0.01]
tab_W = 22; //[11:44:0.01]
tab_t = 1.6; //[0.8:3.2:0.1]
hole_d = 6.5; //[3.25:13:0.01]
hole_center_from_tab_end = 6; //[3:12:0.01]
hole_center_from_tab_side = 11; //[5.5:22:0.01]
wall_H = 37.17; //[18.585:74.34:0.01]
wall_t = 1.6; //[0.8:3.2:0.1]
channel_inner_bottom_W = 18; //[9:36:0.01]
channel_outer_top_W = 50; //[25:100:0.01]
wall_flare_per_side = 16; //[0:32:0.01]
overlap = 1; //[0.5:2:0.1]
bend_r = 1.6; //[0.8:4:0.1]
relief_w = 3; //[1.5:6:0.1]
relief_d = 3; //[1.5:6:0.1]
rib_t = 1.6; //[0.8:3.2:0.1]
rib_h = 10; //[5:20:0.1]
rib_len = 18; //[9:36:0.1]
tab_end_round_r = 11; //[5.5:22:0.01]

// Base Plate
module base_plate() {
  color("Silver")
  translate([0, 0, 0])
  cube([base_L, base_W, base_t], center=true);
}

// Mounting Tab
module mounting_tab() {
  color("Silver")
  union() {
    translate([base_L/2 + tab_L/2 - overlap, 0, 0])
    cube([tab_L, tab_W, tab_t], center=true);
    translate([base_L/2 + tab_L - tab_end_round_r, 0, 0])
    cylinder(r=tab_end_round_r, h=tab_t, center=true);
  }
}

// Mounting Hole
module mounting_hole() {
  translate([base_L/2 + tab_L - hole_center_from_tab_end, (-tab_W/2) + hole_center_from_tab_side, 0])
  cylinder(r=hole_d/2, h=base_t + tab_t + 2*overlap, center=true);
}

// V Side Wall
module v_side_wall() {
  polygon(points=[[0, 0], [wall_t, 0], [wall_t + wall_flare_per_side, wall_H], [wall_flare_per_side, wall_H]]);
}

module v_side_wall_left() {
  color("Silver")
  translate([-base_L/2, -channel_inner_bottom_W/2 - wall_t + overlap, base_t/2 - overlap])
  rotate([0, 90, 0])
  linear_extrude(height=base_L)
  v_side_wall();
}

module v_side_wall_right() {
  color("Silver")
  translate([-base_L/2, channel_inner_bottom_W/2 - overlap, base_t/2 - overlap])
  rotate([0, 90, 0])
  linear_extrude(height=base_L)
  v_side_wall();
}

// Bend Radius Proxy
module bend_radius_proxy_left() {
  translate([0, -channel_inner_bottom_W/2 - wall_t + bend_r, 0])
  rotate([0, 90, 0])
  cylinder(r=bend_r, h=base_L, center=true);
}

module bend_radius_proxy_right() {
  translate([0, channel_inner_bottom_W/2 + wall_t - bend_r, 0])
  rotate([0, 90, 0])
  cylinder(r=bend_r, h=base_L, center=true);
}

// Stiffening Ribs
module stiffening_rib_left() {
  color("Silver")
  translate([-base_L/2 + rib_len/2, -channel_inner_bottom_W/2 - wall_t/2 + overlap, base_t/2 + rib_h/2 - overlap])
  cube([rib_t, wall_t, rib_h], center=true);
}

module stiffening_rib_right() {
  color("Silver")
  translate([-base_L/2 + rib_len/2, channel_inner_bottom_W/2 + wall_t/2 - overlap, base_t/2 + rib_h/2 - overlap])
  cube([rib_t, wall_t, rib_h], center=true);
}

// Manufacturing Relief Notches
module manufacturing_relief_notch_left() {
  translate([-base_L/2 + relief_w/2, -channel_inner_bottom_W/2 - wall_t + relief_d/2, wall_H/2])
  cube([relief_w, relief_d, base_t + wall_H + 2*overlap], center=true);
}

module manufacturing_relief_notch_right() {
  translate([-base_L/2 + relief_w/2, channel_inner_bottom_W/2 + wall_t - relief_d/2, wall_H/2])
  cube([relief_w, relief_d, base_t + wall_H + 2*overlap], center=true);
}

// Channel Opening Profile Control
module channel_opening_profile_control() {
  translate([0, 0, 0])
  cube([base_L, channel_inner_bottom_W, base_t], center=true);
}

// Sheet Thickness Control
module sheet_thickness_control() {
  translate([-base_L/2 + sheet_t/2, -base_W/2 + sheet_t/2, base_t/2 + sheet_t/2 - overlap])
  cube([sheet_t, sheet_t, sheet_t], center=true);
}

// Edge Fillet or Chamfer
module edge_fillet_or_chamfer() {
  translate([-base_L/2 + sheet_t/2, base_W/2 - sheet_t/2, base_t/2 + sheet_t/2 - overlap])
  sphere(r=sheet_t/2, center=true);
}

// Final Bracket Assembly
module bracket() {
  difference() {
    union() {
      base_plate();
      mounting_tab();
      v_side_wall_left();
      v_side_wall_right();
      bend_radius_proxy_left();
      bend_radius_proxy_right();
      stiffening_rib_left();
      stiffening_rib_right();
      channel_opening_profile_control();
      sheet_thickness_control();
      edge_fillet_or_chamfer();
    }
    mounting_hole();
    manufacturing_relief_notch_left();
    manufacturing_relief_notch_right();
  }
}

// Render the final bracket
bracket();
}
