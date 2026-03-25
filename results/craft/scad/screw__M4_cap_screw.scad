// Socket Head Cap Screw (M4-like) — single connected solid
// Dimensions: shank Ø4.0, head Ø7.0, head height 4.0, length under head 10.0

thread_diameter_mm = 4.0;      //[2.0:8.0:0.1]
length_mm          = 10.0;     //[5.0:20.0:0.5]   // under-head length
head_diameter_mm   = 7.0;      //[3.5:14.0:0.1]
head_height_mm     = 4.0;      //[2.0:8.0:0.1]
socket_af_mm       = 3.0;      //[1.5:6.0:0.1]    // hex across flats
socket_depth_mm    = 2.5;      //[1.0:4.0:0.1]
tip_chamfer_height_mm = 0.8;   //[0.3:2.0:0.1]
overlap_mm         = 0.2;      //[0.05:1.0:0.05]

$fn = 96;

module socket_head_cap_screw() {
  shank_r = thread_diameter_mm/2;
  head_r  = head_diameter_mm/2;

  // Place screw along +Z (head on top, tip at bottom) for clear ortho views
  z_head_center  = length_mm + head_height_mm/2;
  z_shank_center = length_mm/2;
  z_tip_center   = tip_chamfer_height_mm/2;

  difference() {
    // ONE connected solid (head + shank + tip) with slight overlaps
    union() {
      // Shank (under head)
      translate([0, 0, z_shank_center])
        cylinder(r=shank_r, h=length_mm + overlap_mm, center=true);

      // Tip chamfer (cone)
      translate([0, 0, z_tip_center])
        cylinder(r1=0, r2=shank_r, h=tip_chamfer_height_mm, center=true);

      // Head
      translate([0, 0, z_head_center])
        cylinder(r=head_r, h=head_height_mm + overlap_mm, center=true);
    }

    // Hex socket recess (subtracted from head)
    // Hex cylinder radius from across-flats: R = (AF/2)/cos(30)
    socket_R = (socket_af_mm/2)/cos(30);
    z_socket_center = length_mm + head_height_mm - socket_depth_mm/2;

    translate([0, 0, z_socket_center])
      cylinder(r=socket_R, h=socket_depth_mm + 0.2, center=true, $fn=6);
  }
}

socket_head_cap_screw();