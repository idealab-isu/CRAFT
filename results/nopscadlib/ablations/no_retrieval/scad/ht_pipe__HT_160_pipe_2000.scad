// Parameters
pipe_length = 2000; //[1000:4000:10]
outer_diameter = 160; //[80:320:1]
wall_thickness = 4.7; //[2.35:9.4:0.1]
socket_length = 90; //[45:180:1]
socket_wall_extra = 2.5; //[1.0:6.0:0.1]
spigot_chamfer_length = 12; //[6:30:1]
spigot_chamfer_radial = 2.0; //[0.8:5.0:0.1]
socket_chamfer_length = 10; //[5:25:1]
socket_chamfer_radial = 2.0; //[0.8:5.0:0.1]
mark_band_width = 6; //[3:15:1]
mark_band_height = 0.6; //[0.2:1.5:0.1]
mark_band_offset_from_socket = 25; //[10:80:1]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module pipe_body() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module pipe_bore() {
  cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap/2])
    cylinder(h=socket_length, r=outer_diameter/2 + socket_wall_extra, center=true);
}

module spigot_end() {
  translate([0, 0, -pipe_length/2 + socket_length/2 - overlap/2])
    cylinder(h=socket_length, r=outer_diameter/2, center=true);
}

module spigot_chamfer_cutter() {
  translate([0, 0, -pipe_length/2 + spigot_chamfer_length/2])
    cylinder(h=spigot_chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - spigot_chamfer_radial, center=true);
}

module socket_mouth_chamfer_cutter() {
  translate([0, 0, pipe_length/2 - socket_chamfer_length/2])
    cylinder(h=socket_chamfer_length, r1=outer_diameter/2 + socket_wall_extra + socket_chamfer_radial, r2=outer_diameter/2 + socket_wall_extra, center=true);
}

module marking_band(position_z) {
  translate([0, 0, position_z])
    scale([1, 1, mark_band_width/(mark_band_height + overlap)])
      rotate_extrude() translate([outer_diameter/2 + mark_band_height/2, 0, 0]) circle(r=mark_band_height/2);
}

// Operations
module pipe_outer_with_ends() {
  union() {
    pipe_body();
    socket_end();
    spigot_end();
  }
}

module pipe_hollow() {
  difference() {
    pipe_outer_with_ends();
    pipe_bore();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_hollow();
    spigot_chamfer_cutter();
    socket_mouth_chamfer_cutter();
  }
}

module pipe_complete() {
  union() {
    pipe_with_chamfers();
    marking_band(pipe_length/2 - mark_band_offset_from_socket);
    marking_band(pipe_length/2 - mark_band_offset_from_socket - (mark_band_width + 2*overlap));
    marking_band(pipe_length/2 - mark_band_offset_from_socket - 2*(mark_band_width + 2*overlap));
  }
}

// Final Output
pipe_complete();