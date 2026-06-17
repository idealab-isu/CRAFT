// Dimension-calibrated (target: 9.98 x 7.00 x 10.00 mm)
scale([1.000501, 0.645995, 0.701403])
{
// Parameters
OD_x = 9.98; //[4.99:19.96:0.01]
OD_z = 10; //[5:20:0.01]
L_y = 7; //[3.5:14:0.01]
flange_thk = 1.5; //[0.75:3:0.01]
waist_min_d = 4; //[2:8:0.01]
bore_d = 2; //[1:4:0.01]
rim_chamfer = 0.4; //[0.2:0.8:0.01]
transition_chamfer = 0.3; //[0.15:0.6:0.01]
groove_relief_r = 0.25; //[0.1:0.6:0.01]
overlap = 0.8; //[0.5:2:0.01]

// Base Shapes
module outer_flange_left() {
  translate([0, -L_y/2 + flange_thk/2, 0])
    cylinder(r=OD_x/2, h=flange_thk, center=true);
}

module outer_flange_right() {
  translate([0, L_y/2 - flange_thk/2, 0])
    cylinder(r=OD_x/2, h=flange_thk, center=true);
}

module hourglass_waist() {
  rotate([90, 0, 0])
    rotate_extrude() 
      polygon(points=[
        [waist_min_d/2, 0],
        [OD_x/2, L_y/2 - flange_thk + overlap],
        [OD_x/2, L_y/2 - flange_thk + overlap + overlap],
        [waist_min_d/2, overlap]
      ]);
}

module v_groove_profile_control_waist_min_diameter_at_midplane() {
  cylinder(r=waist_min_d/2, h=overlap*2, center=true);
}

module axial_through_bore() {
  cylinder(r=bore_d/2, h=L_y + overlap*2, center=true);
}

module edge_chamfer_left_outer_rim() {
  translate([0, -L_y/2 + rim_chamfer/2, 0])
    rotate([90, 0, 0])
      cylinder(r1=OD_x/2, r2=OD_x/2 - rim_chamfer, h=rim_chamfer, center=true);
}

module edge_chamfer_right_outer_rim() {
  translate([0, L_y/2 - rim_chamfer/2, 0])
    rotate([-90, 0, 0])
      cylinder(r1=OD_x/2, r2=OD_x/2 - rim_chamfer, h=rim_chamfer, center=true);
}

module flange_to_waist_transition_edges_left() {
  translate([0, -(L_y/2 - flange_thk) - transition_chamfer/2 + overlap/2, 0])
    rotate([-90, 0, 0])
      cylinder(r1=OD_x/2, r2=OD_x/2 - transition_chamfer, h=transition_chamfer, center=true);
}

module flange_to_waist_transition_edges_right() {
  translate([0, L_y/2 - flange_thk + transition_chamfer/2 - overlap/2, 0])
    rotate([90, 0, 0])
      cylinder(r1=OD_x/2, r2=OD_x/2 - transition_chamfer, h=transition_chamfer, center=true);
}

module small_relief_at_groove_apex() {
  translate([0, 0, 0])
    rotate_extrude()
      translate([waist_min_d/2 + groove_relief_r, 0, 0])
        circle(r=groove_relief_r);
}

module surface_markings() {
  translate([0, L_y/2 - flange_thk/2, 0])
    cylinder(r=OD_x/2 - rim_chamfer, h=overlap, center=true);
}

// Operations
module union_main_solid() {
  union() {
    outer_flange_left();
    outer_flange_right();
    hourglass_waist();
    v_groove_profile_control_waist_min_diameter_at_midplane();
    surface_markings();
  }
}

module subtract_edge_chamfers_on_outer_rims() {
  difference() {
    union_main_solid();
    edge_chamfer_left_outer_rim();
    edge_chamfer_right_outer_rim();
  }
}

module subtract_flange_to_waist_transition_edges() {
  difference() {
    subtract_edge_chamfers_on_outer_rims();
    flange_to_waist_transition_edges_left();
    flange_to_waist_transition_edges_right();
  }
}

module subtract_small_relief_at_groove_apex() {
  difference() {
    subtract_flange_to_waist_transition_edges();
    small_relief_at_groove_apex();
  }
}

module subtract_axial_through_bore() {
  difference() {
    subtract_small_relief_at_groove_apex();
    axial_through_bore();
  }
}

// Final Output
subtract_axial_through_bore();
}
