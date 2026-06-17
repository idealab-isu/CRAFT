// Socket Head Cap Screw (M3 x 10) - single connected solid
// Requested: 3.0mm shank diameter, 5.5mm head diameter, head height 3.0mm, 10mm long (under head)

$fn = 96;

// Parameters (mm)
shank_diameter_mm      = 3.0;
length_under_head_mm   = 10.0;
head_diameter_mm       = 5.5;
head_height_mm         = 3.0;

// Hex socket (approx for M3)
socket_af_mm           = 2.5;   // across flats
socket_depth_mm        = 2.0;

// Simple thread representation (cosmetic)
threaded               = 1;     // 0/1
thread_length_mm       = 8.0;   // portion of under-head length
thread_major_diameter_mm = 3.0; // keep at shank diameter for M3 look
thread_minor_diameter_mm = 2.6; // cosmetic
thread_pitch_mm        = 0.5;   // M3 coarse pitch (cosmetic)
thread_tooth_depth_mm  = 0.25;  // cosmetic

eps = 0.02;

// Helpers
function hex_circumradius_from_af(af) = (af/2)/cos(30);

// Main model
module socket_head_cap_screw() {
  head_r = head_diameter_mm/2;
  shank_r = shank_diameter_mm/2;

  // Z layout: head from z=0..head_height, shank from z=-length..0
  difference() {
    union() {
      // Head
      translate([0,0,head_height_mm/2])
        cylinder(r=head_r, h=head_height_mm, center=true);

      // Shank (full under-head length)
      translate([0,0,-length_under_head_mm/2])
        cylinder(r=shank_r, h=length_under_head_mm, center=true);

      // Cosmetic thread ridges on last thread_length_mm of shank (kept connected)
      if (threaded) {
        tlen = min(thread_length_mm, length_under_head_mm);
        turns = max(1, ceil(tlen/thread_pitch_mm));
        z0 = -length_under_head_mm; // tip end
        // Place thread section at tip end: z in [z0, z0+tlen]
        translate([0,0,z0])
          for (i = [0:turns-1]) {
            zc = (i + 0.5) * (tlen/turns);
            // thin ring "crest"
            translate([0,0,zc])
              cylinder(r=thread_major_diameter_mm/2, h=thread_pitch_mm*0.35, center=true);
            // slight undercut ring to hint at valleys (still additive overall)
            translate([0,0,zc])
              cylinder(r=thread_minor_diameter_mm/2, h=thread_pitch_mm*0.65, center=true);
          }
      }
    }

    // Hex socket recess in head (subtractive)
    // Socket opens at top of head (z=head_height) and goes down socket_depth
    translate([0,0,head_height_mm - socket_depth_mm/2 + eps])
      cylinder(r=hex_circumradius_from_af(socket_af_mm), h=socket_depth_mm + 2*eps, center=true, $fn=6);
  }
}

socket_head_cap_screw();