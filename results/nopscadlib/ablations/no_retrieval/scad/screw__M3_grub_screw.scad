// Parameters
thread_diameter = 3.0; //[1.5:6.0:0.1]
thread_pitch = 0.5; //[0.25:1.0:0.05]
screw_length = 6.0; //[3.0:12.0:0.5]
major_diameter = 3.0; //[1.5:6.0:0.1]
minor_diameter = 2.4; //[1.2:4.8:0.05]
thread_length = 6.0; //[3.0:12.0:0.5]
tip_chamfer = 0.3; //[0.1:0.8:0.05]
socket_af = 1.5; //[0.8:3.0:0.1]
socket_depth = 2.0; //[1.0:4.0:0.1]
overlap = 0.8; //[0.3:2.0:0.1]
thread_runout_length = 0.6; //[0.3:1.5:0.1]
drive_end_chamfer = 0.25; //[0.1:0.8:0.05]
thread_ridge_height = 0.15; //[0.05:0.35:0.01]
thread_ridge_width = 0.25; //[0.1:0.6:0.05]
thread_ridge_count = 10; //[4:24:1]
marking_depth = 0.08; //[0.03:0.2:0.01]
marking_width = 0.3; //[0.15:0.8:0.05]

// Base shapes
module threaded_cylindrical_body() {
  translate([0, 0, 0])
    cylinder(h=thread_length, r=minor_diameter/2, center=true);
}

module thread_ridge(position_index) {
  translate([0, 0, -thread_length/2 + position_index * (thread_length/(thread_ridge_count+1))])
    cylinder(h=thread_ridge_width, r=minor_diameter/2 + thread_ridge_height, center=true);
}

module thread_runout() {
  translate([0, 0, thread_length/2 - thread_runout_length/2 + overlap/2])
    rotate([180, 0, 0])
    cylinder(h=thread_runout_length, r1=minor_diameter/2 + thread_ridge_height, r2=0, center=true);
}

module tip_end() {
  translate([0, 0, -thread_length/2 - tip_chamfer/2 + overlap/2])
    cylinder(h=tip_chamfer, r1=minor_diameter/2, r2=0, center=true);
}

module tip_style_detail() {
  translate([0, 0, -thread_length/2 - tip_chamfer + (minor_diameter/2) - overlap])
    sphere(r=minor_diameter/2, center=true);
}

module drive_end_chamfer_solid() {
  translate([0, 0, thread_length/2 + drive_end_chamfer/2 - overlap/2])
    rotate([180, 0, 0])
    cylinder(h=drive_end_chamfer, r1=minor_diameter/2, r2=0, center=true);
}

module drive_socket() {
  translate([0, 0, thread_length/2 - socket_depth/2 + overlap/2])
    linear_extrude(height=socket_depth + overlap, center=true)
    polygon(points=[
      [socket_af/2, 0],
      [socket_af/4, socket_af*0.4330127019],
      [-socket_af/4, socket_af*0.4330127019],
      [-socket_af/2, 0],
      [-socket_af/4, -socket_af*0.4330127019],
      [socket_af/4, -socket_af*0.4330127019]
    ]);
}

module surface_marking_groove(rotation_angle) {
  translate([0, 0, thread_length/2 - socket_depth - thread_runout_length/2])
    rotate([0, 0, rotation_angle])
    cube([minor_diameter + 2*thread_ridge_height + overlap, marking_width, marking_depth*2], center=true);
}

// Operations
module threaded_body_with_ridges() {
  union() {
    threaded_cylindrical_body();
    for (i = [1:thread_ridge_count])
      thread_ridge(i);
  }
}

module body_with_tip_and_runout() {
  union() {
    threaded_body_with_ridges();
    tip_end();
    tip_style_detail();
    thread_runout();
    drive_end_chamfer_solid();
  }
}

module body_minus_drive_socket() {
  difference() {
    body_with_tip_and_runout();
    drive_socket();
  }
}

module surface_markings() {
  difference() {
    body_minus_drive_socket();
    surface_marking_groove(0);
    surface_marking_groove(90);
  }
}

// Final output
surface_markings();