// Socket head cap screw (simplified, no threads)
// Target: shank Ø2.5mm, length under head 10mm
//         head Ø4.5mm, head height 2.5mm, hex socket recess

$fn = 96;

// Parameters (mm)
nominal_diameter_mm   = 2.5;
length_under_head_mm  = 10;

head_diameter_mm      = 4.5;
head_height_mm        = 2.5;

socket_hex_af_mm      = 2.0;   // across flats
socket_depth_mm       = 1.5;

chamfer_tip_mm        = 0.2;
chamfer_head_top_mm   = 0.2;

overlap_mm            = 0.05;

// Helpers
function hex_circumradius_from_af(af) = af / (2 * cos(30)); // R = AF/(2cos30)

// Hex prism for socket cut
module hex_prism(af, h, center=false) {
  r = hex_circumradius_from_af(af);
  cylinder(h=h, r=r, center=center, $fn=6);
}

// Main screw (ONE connected solid)
module socket_head_cap_screw() {
  shank_r = nominal_diameter_mm / 2;
  head_r  = head_diameter_mm / 2;

  // Z layout: head spans [0, head_height], shank spans [-length, 0]
  difference() {
    union() {
      // Shank
      translate([0, 0, -length_under_head_mm/2])
        cylinder(h=length_under_head_mm, r=shank_r, center=true);

      // Tip chamfer (conical)
      translate([0, 0, -length_under_head_mm + chamfer_tip_mm/2])
        cylinder(h=chamfer_tip_mm, r1=shank_r, r2=0, center=true);

      // Head
      translate([0, 0, head_height_mm/2])
        cylinder(h=head_height_mm, r=head_r, center=true);
    }

    // Top edge chamfer (remove a thin conical ring at the top)
    translate([0, 0, head_height_mm - chamfer_head_top_mm/2])
      cylinder(h=chamfer_head_top_mm + overlap_mm, r1=head_r, r2=head_r - chamfer_head_top_mm, center=true);

    // Hex socket recess (cut from top down)
    translate([0, 0, head_height_mm - socket_depth_mm/2])
      hex_prism(socket_hex_af_mm, socket_depth_mm + overlap_mm, center=true);
  }
}

socket_head_cap_screw();