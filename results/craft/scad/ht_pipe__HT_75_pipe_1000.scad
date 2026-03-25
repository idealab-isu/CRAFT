$fn = 128;

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 75; //[40:150:1]
length_mm = 1000; //[500:2000:10]
end_style = 1; //[1:1:1]
pipe_od = 75; //[40:150:1]
pipe_wall = 2.7; //[1.5:5.5:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 1.8; //[0.8:4:0.1]
socket_id_clearance = 0.6; //[0.2:1.5:0.1]
socket_stop_thickness = 3; //[1:8:0.5]
socket_stop_depth = 18; //[8:40:1]
connect_overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry (axis along X so front/back/left/right show length)
module ht_pipe() {
  // Derived radii
  od_r = pipe_od/2;
  id_r = od_r - pipe_wall;

  socket_od_r = od_r + socket_wall_extra;
  socket_id_r = od_r + socket_id_clearance;

  // Length split (ensure non-negative)
  body_len = max(0, length_mm - socket_length + connect_overlap);

  // Socket stop ring (internal shoulder)
  stop_z0 = socket_stop_depth;
  stop_z1 = stop_z0 + socket_stop_thickness;

  color([0.85, 0.85, 0.8])
  rotate([0, 90, 0])  // make pipe run along X for consistent orthographic views
  union() {
    // Outer solid (body + socket) as one connected piece
    difference() {
      union() {
        // Main outer body
        cylinder(r=od_r, h=body_len, center=false);

        // Socket outer (overlaps body by connect_overlap)
        translate([0, 0, body_len - connect_overlap])
          cylinder(r=socket_od_r, h=socket_length, center=false);
      }

      // Inner void (continuous through entire length)
      translate([0, 0, 0])
        cylinder(r=id_r, h=length_mm + 2, center=false);

      // Socket bore (wider than body ID) from socket mouth to stop depth
      translate([0, 0, body_len - connect_overlap])
        cylinder(r=socket_id_r, h=stop_z0, center=false);

      // After the stop, revert to body ID (already removed by id_r cylinder),
      // so we don't remove anything extra here.
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();