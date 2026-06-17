// Parameters
pipe_od = 50; //[25:100:1]
pipe_wall = 1.8; //[0.9:3.6:0.1]
socket_depth = 40; //[20:80:1]
cap_wall = 3; //[1.5:6:0.1]
bend_radius_centerline = 35; //[18:70:1]
angle_deg = 90; //[45:120:1]
clearance = 0.2; //[0.0:0.6:0.05]
chamfer_lead_in = 1; //[0:3:0.1]
stop_ring_thickness = 2; //[1:4:0.1]
stop_ring_offset_from_mouth = 20; //[5:60:1]
overlap = 1; //[0.5:2:0.1]
pipe_stub_length = 60; //[20:120:1]

// Derived
outer_r = pipe_od/2 + cap_wall;
inner_r = pipe_od/2 + clearance;

// HT Pipe - complete geometry
module ht_pipe() {
  difference() {
    cylinder(r=pipe_od/2, h=pipe_stub_length + 2*overlap, center=true);
    translate([0, 0, -overlap])
      cylinder(r=pipe_od/2 - pipe_wall, h=pipe_stub_length + 2*overlap, center=true);
  }
}

// 90-degree cap fitting
module cap_fitting() {
  union() {
    // 90-degree cap body shell
    difference() {
      intersection() {
        // Outer torus
        rotate_extrude(angle=angle_deg)
          translate([bend_radius_centerline + outer_r, 0, 0])
            circle(r=outer_r);

        // Socket interface outer cylinder
        translate([bend_radius_centerline, 0, socket_depth/2 - overlap])
          cylinder(r=outer_r, h=socket_depth, center=true);

        // End cap closure outer cylinder
        translate([0, bend_radius_centerline, cap_wall/2 - overlap])
          cylinder(r=outer_r, h=cap_wall, center=true);
      }
      intersection() {
        // Inner torus
        rotate_extrude(angle=angle_deg)
          translate([bend_radius_centerline + inner_r, 0, 0])
            circle(r=inner_r);

        // Socket interface inner cylinder
        translate([bend_radius_centerline, 0, socket_depth/2 - overlap])
          cylinder(r=inner_r, h=socket_depth + 2*overlap, center=true);

        // End cap closure inner relief cylinder
        translate([0, bend_radius_centerline, cap_wall/2 - overlap])
          cylinder(r=inner_r, h=cap_wall + 2*overlap, center=true);
      }
    }

    // Socket interface shell
    difference() {
      translate([bend_radius_centerline, 0, socket_depth/2 - overlap])
        cylinder(r=outer_r, h=socket_depth, center=true);
      translate([bend_radius_centerline, 0, socket_depth/2 - overlap])
        cylinder(r=inner_r, h=socket_depth + 2*overlap, center=true);
    }

    // End cap closure solid
    difference() {
      translate([0, bend_radius_centerline, cap_wall/2 - overlap])
        cylinder(r=outer_r, h=cap_wall, center=true);
      translate([0, bend_radius_centerline, cap_wall/2 - overlap])
        cylinder(r=inner_r, h=cap_wall + 2*overlap, center=true);
    }

    // Internal stop ring
    difference() {
      translate([bend_radius_centerline, 0, stop_ring_offset_from_mouth + stop_ring_thickness/2 - overlap])
        cylinder(r=inner_r + cap_wall, h=stop_ring_thickness, center=true);
      translate([bend_radius_centerline, 0, stop_ring_offset_from_mouth + stop_ring_thickness/2 - overlap])
        cylinder(r=inner_r, h=stop_ring_thickness + 2*overlap, center=true);
    }

    // Socket lead-in cone
    translate([bend_radius_centerline, 0, chamfer_lead_in/2 - overlap])
      rotate([180, 0, 0])
        cylinder(r1=outer_r, r2=inner_r, h=chamfer_lead_in, center=true);
  }
}

// Assembly: attach the "circular ring/loop" (pipe stub) to the socket mouth with real intersection.
// Socket mouth plane is at z = -overlap (because socket cylinder is centered at socket_depth/2 - overlap).
// Place pipe so its top face goes INSIDE the socket by `overlap` (1-2mm) to guarantee connection.
module assembly() {
  // Mouth plane (global Z) of the socket opening:
  mouth_z = -overlap;

  // Pipe is centered; its top face is at (center_z + pipe_stub_length/2).
  // Enforce: top_face_z = mouth_z + overlap  => center_z = mouth_z + overlap - pipe_stub_length/2
  // This yields a guaranteed penetration of `overlap` into the socket.
  pipe_center_z = mouth_z + overlap - pipe_stub_length/2;

  color([0.85, 0.85, 0.8])
  union() {
    cap_fitting();

    // Connected pipe stub (no floating ring)
    translate([bend_radius_centerline, 0, pipe_center_z])
      ht_pipe();
  }
}

assembly();