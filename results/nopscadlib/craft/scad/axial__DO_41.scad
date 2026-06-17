// Parameters
axis_length = 60; //[30:120:1]
axis_diameter = 2; //[1:4:0.1]
origin_marker_diameter = 6; //[3:12:0.5]
origin_marker_height = 2; //[1:6:0.5]
arrowhead_length = 8; //[4:16:0.5]
arrowhead_diameter = 5; //[2.5:10:0.5]
end_cap_length = 3; //[1.5:8:0.5]
overlap = 1; //[0.5:2:0.1]
A_x = 5.21; //[2.605:10.42:0.01]
A_y = 2.72; //[1.36:5.44:0.01]
A_z = 0; //[-1:1:0.01]
axis_angle_deg = 27.57; //[0:360:0.01]

// Base Shapes
module axis_rod_base() {
  translate([axis_length/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=axis_length, r=axis_diameter/2, center=true);
}

module origin_marker_base() {
  translate([0, 0, 0])
    cylinder(h=origin_marker_height, r=origin_marker_diameter/2, center=true);
}

module arrowhead_tip_base() {
  translate([axis_length + arrowhead_length/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=arrowhead_length, r1=arrowhead_diameter/2, r2=0, center=true);
}

module end_cap_base() {
  translate([axis_length - end_cap_length/2 + overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=end_cap_length, r=axis_diameter/2, center=true);
}

// Operations
module axis_complete_unoriented() {
  union() {
    axis_rod_base();
    origin_marker_base();
    end_cap_base();
    arrowhead_tip_base();
  }
}

// Final Output
rotate([0, 0, axis_angle_deg])
  axis_complete_unoriented();