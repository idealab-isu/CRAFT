// Parameters
axis_end_x = 5.21; //[2.605:10.42:0.01]
axis_end_y = 2.72; //[1.36:5.44:0.01]
axis_end_z = 0; //[-5:5:0.01]
axis_radius = 0.5; //[0.25:1:0.01]
origin_marker_radius = 1; //[0.5:2:0.01]
origin_marker_height = 1; //[0.5:2:0.01]
end_marker_radius = 1; //[0.5:2:0.01]
end_marker_height = 1; //[0.5:2:0.01]
arrowhead_length = 2; //[1:4:0.01]
arrowhead_radius = 1.2; //[0.6:2.4:0.01]
connect_overlap = 0.8; //[0.2:2:0.01]
axis_length = 5.877; //[2.9385:11.754:0.001]
axis_yaw_deg = 27.56; //[-180:180:0.01]
axis_pitch_deg = 0; //[-90:90:0.01]

// Geometry
module axis_vector() {
  translate([axis_length/2, 0, 0])
  rotate([0, 90, 0])
  cylinder(h=axis_length, r=axis_radius, center=true);
}

module origin_marker() {
  translate([0, 0, 0])
  cylinder(h=origin_marker_height, r=origin_marker_radius, center=true);
}

module end_marker() {
  translate([axis_length - connect_overlap, 0, 0])
  rotate([0, 90, 0])
  cylinder(h=end_marker_height, r=end_marker_radius, center=true);
}

module arrowhead() {
  translate([axis_length + arrowhead_length/2 - connect_overlap, 0, 0])
  rotate([0, 90, 0])
  cylinder(h=arrowhead_length, r1=arrowhead_radius, r2=0, center=true);
}

module label_text() {
  translate([axis_length/2, 0, 0])
  cube([axis_radius*2, axis_radius*2, axis_radius*2], center=true);
}

// Assemble the axis
module axis_union_local() {
  union() {
    axis_vector();
    origin_marker();
    end_marker();
    arrowhead();
    label_text();
  }
}

// Final oriented axis
rotate([0, axis_pitch_deg, axis_yaw_deg])
axis_union_local();