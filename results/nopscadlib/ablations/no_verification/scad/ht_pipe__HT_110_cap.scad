$fn = 128;

// Parameters
nominal_size = 110; //[55:220:1]
tolerance_clearance = 0.6; //[0.2:1.2:0.1]
cap_wall_thickness = 4.5; //[2.5:9:0.1]
socket_depth = 55; //[30:110:1]
end_face_thickness = 6; //[3:12:0.1]
socket_stop_thickness = 3; //[1.5:6:0.1]
socket_stop_radial_width = 3; //[1.5:6:0.1]
outer_grip_rim_radial = 2.5; //[1:6:0.1]
outer_grip_rim_height = 12; //[6:30:0.5]
chamfer_lead_in = 2; //[0.5:5:0.1]
pipe_od = 110; //[55:220:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
pipe_length = 80; //[40:160:1]
overlap = 1; //[0.5:2:0.1]
cap_inner_socket_diameter = 110.6; //[55.2:221.2:0.1]
cap_outer_diameter = 119.6; //[60:240:0.1]

// Derived
cap_h = socket_depth + end_face_thickness;
cap_r = cap_outer_diameter/2;
socket_r = cap_inner_socket_diameter/2;

// Safety clamps to avoid invalid/blank geometry
eps = 0.01;
pipe_ir = max(eps, pipe_od/2 - pipe_wall);
stop_r = max(eps, socket_r - socket_stop_radial_width);

// HT Pipe - complete geometry
module ht_pipe() {
  difference() {
    cylinder(r=pipe_od/2, h=pipe_length, center=true);
    translate([0, 0, -overlap/2])
      cylinder(r=pipe_ir, h=pipe_length + overlap, center=true);
  }
}

// Cap (single connected solid)
module ht_cap() {
  difference() {
    union() {
      // Outer cap body
      cylinder(r=cap_r, h=cap_h, center=true);

      // Outer grip rim near open end (bottom), overlapped into body
      translate([0, 0, -cap_h/2 + outer_grip_rim_height/2])
        cylinder(r=cap_r + outer_grip_rim_radial, h=outer_grip_rim_height + overlap, center=true);
    }

    // Internal socket void (open at bottom, stops before end face)
    translate([0, 0, -cap_h/2 + socket_depth/2])
      cylinder(r=socket_r, h=socket_depth + overlap, center=true);

    // Socket stop shoulder: reduce diameter near the closed end
    // Positioned at the top of the socket region (near closed end)
    translate([0, 0, -cap_h/2 + socket_depth - socket_stop_thickness/2])
      cylinder(r=stop_r, h=socket_stop_thickness + overlap, center=true);

    // Lead-in chamfer at open end (bottom)
    translate([0, 0, -cap_h/2 + chamfer_lead_in/2])
      cylinder(r1=socket_r + chamfer_lead_in, r2=socket_r, h=chamfer_lead_in + overlap, center=true);
  }
}

// Assembly as ONE connected solid (cap + inserted pipe with overlap)
module assembly() {
  union() {
    ht_cap();

    // Cap bottom plane is at z = -cap_h/2
    // Pipe top plane is at z = pipe_z + pipe_length/2
    // Set pipe top plane to cap bottom plane + overlap (pipe penetrates into socket)
    pipe_z = (-cap_h/2 + overlap) - pipe_length/2;

    translate([0, 0, pipe_z])
      ht_pipe();
  }
}

assembly();