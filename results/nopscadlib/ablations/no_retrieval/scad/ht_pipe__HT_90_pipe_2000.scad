$fn = 128;

// Parameters
pipe_length = 2000; //[1000:4000:10]          // straight pipe length (mm)
outer_diameter = 90; //[45:180:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
chamfer_length = 1; //[0.5:3:0.1]
chamfer_angle = 45; //[30:60:1]               // kept for compatibility (not used directly)
socket_enabled = 1; //[0:1:1]
socket_length = 70; //[0:140:1]
socket_outer_diameter = 110; //[95:140:1]
socket_wall_thickness = 4; //[2:8:0.1]
gasket_groove_width = 6; //[3:12:0.5]
gasket_groove_depth = 1.5; //[0.5:3:0.1]
gasket_groove_offset_from_end = 18; //[8:40:1]
overlap = 1; //[0.5:2:0.1]

// Derived
pipe_r_outer = outer_diameter/2;
pipe_r_inner = pipe_r_outer - wall_thickness;

socket_r_outer = socket_outer_diameter/2;
socket_r_inner = socket_r_outer - socket_wall_thickness;

// Helpers
module pipe_shell(h, r_out, r_in) {
  difference() {
    cylinder(h=h, r=r_out, center=true);
    cylinder(h=h + 2*overlap, r=r_in, center=true);
  }
}

module end_chamfer_cutter_z(end_z, r_out, chamfer_len) {
  // Conical cutter aligned with Z, positioned at an end face (z=end_z)
  translate([0,0,end_z])
    translate([0,0,-chamfer_len/2 + overlap/2])  // overlaps into the pipe
      cylinder(h=chamfer_len + overlap, r1=r_out, r2=0, center=true);
}

module socket_shell_at_end_z(end_z, dir) {
  // dir = +1 for +Z end, -1 for -Z end
  // Socket starts at pipe end face and extends outward
  translate([0,0, end_z + dir*(socket_length/2 - overlap/2)])
    difference() {
      cylinder(h=socket_length + overlap, r=socket_r_outer, center=true);
      cylinder(h=socket_length + overlap + 2*overlap, r=socket_r_inner, center=true);
    }
}

module gasket_groove_cutter_at_end_z(end_z, dir) {
  // Groove measured from socket mouth inward by gasket_groove_offset_from_end
  // Socket local z spans [0..socket_length] from pipe end outward
  groove_center_from_pipe_end = socket_length - gasket_groove_offset_from_end;
  translate([0,0, end_z + dir*groove_center_from_pipe_end])
    cylinder(
      h=gasket_groove_width + 2*overlap,
      r=socket_r_inner + gasket_groove_depth,
      center=true
    );
}

// Final model: straight HT pipe 2000 mm, with optional socket(s), one connected solid, hollow throughout
module ht_pipe_straight() {
  end_z_pos =  pipe_length/2;
  end_z_neg = -pipe_length/2;

  difference() {
    union() {
      // Main straight pipe shell
      pipe_shell(pipe_length, pipe_r_outer, pipe_r_inner);

      // Optional sockets at both ends
      if (socket_enabled) {
        socket_shell_at_end_z(end_z_pos, +1);
        socket_shell_at_end_z(end_z_neg, -1);
      }
    }

    // Outer chamfers at both pipe ends
    end_chamfer_cutter_z(end_z_pos, pipe_r_outer, chamfer_length);
    rotate([180,0,0]) end_chamfer_cutter_z(-end_z_neg, pipe_r_outer, chamfer_length);

    // Gasket grooves inside sockets
    if (socket_enabled) {
      gasket_groove_cutter_at_end_z(end_z_pos, +1);
      gasket_groove_cutter_at_end_z(end_z_neg, -1);
    }
  }
}

ht_pipe_straight();