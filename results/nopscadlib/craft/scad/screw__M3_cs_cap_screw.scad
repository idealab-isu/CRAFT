// Socket Head Cap Screw (plain) - M3 x 10 with 6mm head OD
// One connected solid, no washer/flange, with hex socket recess.

thread_diameter_mm = 3.0;
length_mm          = 10.0;   // shank length under head
head_diameter_mm   = 6.0;
head_height_mm     = 3.0;

socket_af_mm       = 2.5;    // across flats
socket_depth_mm    = 1.6;

head_to_shank_chamfer_mm = 0.6;
shaft_tip_chamfer_mm     = 0.6;

overlap_mm = 0.2;

$fn = 96;

module socket_head_cap_screw() {
  shank_r = thread_diameter_mm/2;
  head_r  = head_diameter_mm/2;

  // Place underside of head at z=0, shank extends to -length_mm, head to +head_height_mm
  difference() {
    union() {
      // Shank
      translate([0, 0, -length_mm/2])
        cylinder(r=shank_r, h=length_mm, center=true);

      // Head
      translate([0, 0, head_height_mm/2])
        cylinder(r=head_r, h=head_height_mm, center=true);

      // Head-to-shank chamfer (connects head underside to shank)
      translate([0, 0, head_to_shank_chamfer_mm/2 - overlap_mm/2])
        cylinder(r1=head_r, r2=shank_r, h=head_to_shank_chamfer_mm, center=true);

      // Tip chamfer
      translate([0, 0, -length_mm + shaft_tip_chamfer_mm/2])
        cylinder(r1=shank_r, r2=max(0.01, shank_r - 0.35), h=shaft_tip_chamfer_mm, center=true);
    }

    // Hex socket recess (cut into top of head)
    translate([0, 0, head_height_mm - socket_depth_mm/2])
      cylinder(r=(socket_af_mm/2)/cos(30), h=socket_depth_mm + overlap_mm*2, center=true, $fn=6);
  }
}

socket_head_cap_screw();