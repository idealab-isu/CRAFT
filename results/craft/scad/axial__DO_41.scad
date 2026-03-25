// Parameters
A_x = 5.21; //[2.605:10.42:0.01]
A_y = 2.72; //[1.36:5.44:0.01]
A_z = 0; //[min:-5:max:5:step:0.01]
axis_line_length = 20; //[10:40:1]
axis_line_diameter = 1; //[0.5:2:0.1]
axis_line_overlap = 1; //[0.5:2:0.1]
ref_point_diameter = 2; //[1:4:0.1]
ref_point_height = 1; //[0.5:3:0.1]
arrowhead_length = 4; //[2:8:0.5]
arrowhead_diameter = 2; //[1:4:0.1]

// Axial Reference Point
module axial_reference_point() {
  color("Red")
  translate([A_x, A_y, A_z])
    cylinder(r=ref_point_diameter/2, h=ref_point_height, center=true);
}

// Axis Line Indicator
module axis_line_indicator() {
  color("Blue")
  translate([A_x + axis_line_length/2 - axis_line_overlap, A_y, A_z])
    rotate([0, 90, 0])
      cylinder(r=axis_line_diameter/2, h=axis_line_length, center=true);
}

// Arrowhead Marker
module arrowhead_marker() {
  color("Green")
  translate([A_x + axis_line_length - axis_line_overlap + arrowhead_length/2, A_y, A_z])
    rotate([0, 90, 0])
      cylinder(r1=arrowhead_diameter/2, r2=0, h=arrowhead_length, center=true);
}

// Complete Model
module complete_model() {
  union() {
    axial_reference_point();
    axis_line_indicator();
    arrowhead_marker();
    // Text label is ignored as per rules
  }
}

// Render the complete model
complete_model();