// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 1500; //[750:3000:10]
pipe_od = 160; //[80:320:1]
pipe_wall = 4.9; //[2.5:10:0.1]
socket_length = 90; //[45:180:1]
socket_wall_extra = 2.5; //[1:6:0.1]
socket_od_extra = 10; //[4:25:0.5]
socket_insert_overlap = 1; //[0.5:2:0.1]
inner_clearance = 0.5; //[0.2:1.5:0.1]

$fn = 128;

module ht_pipe() {
  pipe_ro = pipe_od/2;
  pipe_ri = max(0.01, pipe_ro - pipe_wall);

  // Socket outer diameter: allow either explicit OD extra or wall extra (whichever is larger)
  socket_ro_from_od   = pipe_ro + socket_od_extra/2;
  socket_ro_from_wall = pipe_ro + socket_wall_extra;
  socket_ro = max(socket_ro_from_od, socket_ro_from_wall);

  // Socket inner radius: slightly larger than pipe OD to accept insertion
  socket_ri = pipe_ro + inner_clearance;

  // Keep socket wall valid
  socket_ri_eff = min(socket_ri, socket_ro - 0.2);

  // Overlap to guarantee connectivity and avoid coplanar faces
  z_overlap = max(0.5, socket_insert_overlap);

  // Total outer length includes socket
  total_len = length_mm + socket_length;

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER solid (one connected piece)
    union() {
      // Main pipe outer
      cylinder(h=length_mm, r=pipe_ro, center=false);

      // Socket outer, starts inside main pipe by z_overlap to ensure union connectivity
      translate([0, 0, length_mm - z_overlap])
        cylinder(h=socket_length + z_overlap, r=socket_ro, center=false);
    }

    // INNER void (continuous bore)
    union() {
      // Pipe bore through entire part (ensures open ends)
      translate([0, 0, -0.1])
        cylinder(h=total_len + 0.2, r=pipe_ri, center=false);

      // Socket enlarged bore only in socket region
      translate([0, 0, length_mm - z_overlap - 0.1])
        cylinder(h=socket_length + z_overlap + 0.2, r=socket_ri_eff, center=false);
    }
  }
}

ht_pipe();