// HT pipe: HT 75, length 1500 mm
// Fix: orient pipe along X so Front/Back/Left/Right orthographic views show the length.

$fn = 128;

// Parameters
pipe_length = 1500; //[750:3000:1]
outer_diameter = 75; //[40:150:1]
wall_thickness = 2.5; //[1.2:5:0.1]
socket_length = 70; //[35:140:1]
socket_outer_diameter = 82; //[75:120:1]
gasket_groove_width = 8; //[4:16:0.5]
gasket_groove_depth = 1.5; //[0.5:3:0.1]
gasket_groove_offset_from_end = 18; //[8:40:1]
chamfer_length = 3; //[1:8:0.5]
chamfer_radial = 2; //[0.5:6:0.5]
overlap = 1; //[0.5:2:0.1]

// Derived
outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;

socket_outer_r = socket_outer_diameter/2;
socket_inner_r = socket_outer_r - wall_thickness;

// Place socket on +X end
socket_center_x = pipe_length/2 - socket_length/2 + overlap;

// Groove is inside socket, measured from socket end (at +pipe_length/2)
groove_center_x = pipe_length/2 - socket_length + gasket_groove_offset_from_end + gasket_groove_width/2;

// Base Shapes (built along Z, then rotated to X)
module pipe_body_z() {
  cylinder(h=pipe_length, r=outer_r, center=true);
}

module hollow_bore_z() {
  cylinder(h=pipe_length + 2*overlap, r=inner_r, center=true);
}

module socket_end_z() {
  translate([0, 0, socket_center_x])
    cylinder(h=socket_length, r=socket_outer_r, center=true);
}

module socket_bore_z() {
  translate([0, 0, socket_center_x])
    cylinder(h=socket_length + 2*overlap, r=socket_inner_r, center=true);
}

// Groove: subtract a slightly larger-radius ring from the socket bore region
module gasket_groove_z() {
  translate([0, 0, groove_center_x])
    cylinder(h=gasket_groove_width, r=socket_inner_r + gasket_groove_depth, center=true);
}

// Chamfer cuts (subtractive)
module chamfer_cut_socket_end_z() {
  // At +end
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(
      h=chamfer_length,
      r1=socket_outer_r + overlap,
      r2=max(0.01, socket_outer_r - chamfer_radial),
      center=true
    );
}

module chamfer_cut_plain_end_z() {
  // At -end
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(
      h=chamfer_length,
      r1=outer_r + overlap,
      r2=max(0.01, outer_r - chamfer_radial),
      center=true
    );
}

// Operations
module outer_with_socket_z() {
  union() {
    pipe_body_z();
    socket_end_z(); // overlaps into pipe by 'overlap' via socket_center_x formula
  }
}

module bore_with_socket_bore_z() {
  union() {
    hollow_bore_z();
    socket_bore_z();
  }
}

module bore_with_groove_z() {
  union() {
    bore_with_socket_bore_z();
    gasket_groove_z();
  }
}

module chamfered_ends_z() {
  union() {
    chamfer_cut_socket_end_z();
    chamfer_cut_plain_end_z();
  }
}

module pipe_with_chamfers_z() {
  difference() {
    difference() {
      outer_with_socket_z();
      bore_with_groove_z();
    }
    chamfered_ends_z();
  }
}

// Final Output: rotate so length is along X (visible in Front/Back/Left/Right views)
rotate([0, 90, 0])
  pipe_with_chamfers_z();