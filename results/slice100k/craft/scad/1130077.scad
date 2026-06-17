// Dimension-calibrated (target: 52.33 x 50.00 x 38.77 mm)
scale([0.983405, 1.046500, 0.755781])
{
// Parameters
bbox_X = 52.33; //[26.165:104.66:0.01]
bbox_Y = 50; //[25:100:0.01]
bbox_Z = 38.77; //[19.385:77.54:0.01]
t = 2; //[1:4:0.1]
base_L = 38; //[19:76:0.1]
base_W = 50; //[25:100:0.1]
tab_L = 14.33; //[7.165:28.66:0.01]
tab_W = 22; //[11:44:0.1]
wall_H = 36.77; //[18.385:73.54:0.01]
wall_angle_deg = 60; //[30:80:1]
trough_inner_W_at_base = 18; //[9:36:0.1]
hole_d = 6.5; //[3.25:13:0.1]
hole_center_from_tab_end = 7; //[3.5:14:0.1]
hole_center_from_tab_side = 11; //[5.5:22:0.1]
overlap = 1; //[0.5:2:0.1]
step_L = 6; //[3:12:0.1]
bend_r = 2; //[1:4:0.1]
relief_w = 4; //[2:8:0.1]
relief_l = 6; //[3:12:0.1]
corner_round_r = 2; //[1:5:0.1]

// Base Plate
module base_plate() {
  translate([-(tab_L/2), 0, 0])
    cube([base_L, base_W, t], center=true);
}

// Mounting Tab
module mounting_tab() {
  translate([base_L/2 - tab_L/2 - overlap, 0, 0])
    cube([tab_L, tab_W, t], center=true);
}

// Base to Tab Transition Step
module base_to_tab_transition_step() {
  translate([base_L/2 - step_L/2 - overlap, 0, 0])
    cube([step_L, base_W, t], center=true);
}

// V Side Wall Left
module v_side_wall_left() {
  translate([-(tab_L/2), -(trough_inner_W_at_base/2 + t/2 - overlap), t/2 + wall_H/2 - overlap])
    rotate([0, -(90 - wall_angle_deg/2), 0])
      cube([base_L, t, wall_H], center=true);
}

// V Side Wall Right
module v_side_wall_right() {
  translate([-(tab_L/2), (trough_inner_W_at_base/2 + t/2 - overlap), t/2 + wall_H/2 - overlap])
    rotate([0, (90 - wall_angle_deg/2), 0])
      cube([base_L, t, wall_H], center=true);
}

// Bend Radius Left
module bend_radius_left() {
  translate([-(tab_L/2), -(trough_inner_W_at_base/2 - overlap), t/2 + bend_r - overlap])
    rotate([0, 90, 0])
      cylinder(r=bend_r, h=base_L, center=true);
}

// Bend Radius Right
module bend_radius_right() {
  translate([-(tab_L/2), (trough_inner_W_at_base/2 - overlap), t/2 + bend_r - overlap])
    rotate([0, 90, 0])
      cylinder(r=bend_r, h=base_L, center=true);
}

// Mounting Hole
module mounting_hole() {
  translate([base_L/2 - tab_L + hole_center_from_tab_end, -(tab_W/2) + hole_center_from_tab_side, 0])
    cylinder(r=hole_d/2, h=t + 2*overlap, center=true);
}

// Relief Notch Left
module relief_notch_left() {
  translate([-(tab_L/2) + base_L/2 - relief_l/2, -(trough_inner_W_at_base/2 + t/2 - overlap), t/2 + (wall_H)/2 - overlap])
    cube([relief_l, relief_w, wall_H + t + 2*overlap], center=true);
}

// Relief Notch Right
module relief_notch_right() {
  translate([-(tab_L/2) + base_L/2 - relief_l/2, (trough_inner_W_at_base/2 + t/2 - overlap), t/2 + (wall_H)/2 - overlap])
    cube([relief_l, relief_w, wall_H + t + 2*overlap], center=true);
}

// Tab Corner Round Cut Front Left
module tab_corner_round_cut_fl() {
  translate([base_L/2 - overlap - corner_round_r, -(tab_W/2) + corner_round_r, 0])
    cylinder(r=corner_round_r, h=t + 2*overlap, center=true);
}

// Tab Corner Round Cut Front Right
module tab_corner_round_cut_fr() {
  translate([base_L/2 - overlap - corner_round_r, (tab_W/2) - corner_round_r, 0])
    cylinder(r=corner_round_r, h=t + 2*overlap, center=true);
}

// Final Geometry
difference() {
  union() {
    base_plate();
    mounting_tab();
    base_to_tab_transition_step();
    v_side_wall_left();
    v_side_wall_right();
    bend_radius_left();
    bend_radius_right();
  }
  mounting_hole();
  relief_notch_left();
  relief_notch_right();
  tab_corner_round_cut_fl();
  tab_corner_round_cut_fr();
}
}
