// Parameters
pipe_OD = 160; //[80:320:1]
pipe_L = 500; //[250:1000:1]
wall_t = 4; //[2:8:0.5]
socket_L = 70; //[35:140:1]
socket_extra_OD = 10; //[5:20:0.5]
chamfer_L = 8; //[3:16:0.5]
marking_band_w = 12; //[6:24:0.5]
marking_band_depth = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body_outer() {
  translate([0, 0, 0])
    cylinder(h=pipe_L, r=pipe_OD/2, center=true);
}

module socket_end_outer() {
  translate([0, 0, pipe_L/2 - socket_L/2 + overlap])
    cylinder(h=socket_L, r=(pipe_OD + socket_extra_OD)/2, center=true);
}

module inner_bore() {
  translate([0, 0, 0])
    cylinder(h=pipe_L + 2*overlap, r=pipe_OD/2 - wall_t, center=true);
}

module chamfer_cut_spigot() {
  translate([0, 0, -pipe_L/2 + chamfer_L/2])
    rotate([180, 0, 0])
      cylinder(h=chamfer_L, r1=pipe_OD/2, r2=0, center=true);
}

module chamfer_cut_socket() {
  translate([0, 0, pipe_L/2 - chamfer_L/2])
    cylinder(h=chamfer_L, r1=(pipe_OD + socket_extra_OD)/2, r2=0, center=true);
}

module marking_band_cut() {
  translate([0, 0, -pipe_L/2 + chamfer_L + marking_band_w/2])
    cylinder(h=marking_band_w, r=pipe_OD/2 - marking_band_depth, center=true);
}

// Operations
module outer_with_socket() {
  union() {
    pipe_body_outer();
    socket_end_outer();
  }
}

module pipe_hollow() {
  difference() {
    outer_with_socket();
    inner_bore();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_hollow();
    chamfer_cut_spigot();
    chamfer_cut_socket();
  }
}

module pipe_with_markings() {
  difference() {
    pipe_with_chamfers();
    marking_band_cut();
  }
}

// Final Output
pipe_with_markings();