// M3 Grub (set) screw with hex socket and simplified helical thread
// One connected solid; no floating parts; all placements derived from dimensions.

// Parameters
nominal_diameter_mm = 3; //[2:6:1]
length_mm = 6; //[3:20:1]
show_threads = 1; //[0:1:1]
thread_pitch_mm = 0.5; //[0.35:0.8:0.05]
thread_depth_mm = 0.18; //[0.1:0.35:0.01]
hex_socket_af_mm = 1.5; //[1.0:3.0:0.1]
hex_socket_depth_mm = 2; //[1:5:0.5]
tip_chamfer_height_mm = 0.6; //[0.2:2.0:0.1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

$fn = 96;

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

module hex_prism(af, h, center=true) {
  // across-flats to circumradius: R = AF / (2*cos(30))
  R = af / (2*cos(30));
  cylinder(r=R, h=h, center=center, $fn=6);
}

module thread_solid(major_r, pitch, depth, len, center=true) {
  // Simplified external thread: helical "ridge" made by linear_extrude with twist.
  // Cross-section is a small rectangle placed at the major radius.
  // This yields a visible helical thread without fragile boolean subtraction.
  turns = len / pitch;
  ridge_w = max(0.12, pitch * 0.35);          // tangential width of ridge
  ridge_h = max(0.05, depth);                 // radial height of ridge
  z0 = center ? -len/2 : 0;

  translate([0,0,z0])
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
      translate([major_r - ridge_h, -ridge_w/2])
        square([ridge_h, ridge_w], center=false);
}

module grub_screw() {
  major_r = nominal_diameter_mm/2;
  // Keep chamfer radius sane
  chamfer_r2 = clamp(major_r - tip_chamfer_height_mm, major_r*0.15, major_r);

  // Ensure socket depth doesn't exceed length
  socket_depth = clamp(hex_socket_depth_mm, 0.2, length_mm - 0.2);

  // Minor radius for thread base
  minor_r = max(major_r - thread_depth_mm, major_r*0.65);

  color("DimGray")
  difference() {
    // Main solid (connected): body + chamfer + (optional) thread ridge
    union() {
      // Base cylinder at minor diameter (thread root)
      cylinder(r=minor_r, h=length_mm, center=true);

      // Tip chamfer (cone frustum) at bottom end, overlapping into body
      translate([0, 0, -length_mm/2 + (tip_chamfer_height_mm + overlap_mm)/2])
        cylinder(r1=major_r, r2=chamfer_r2, h=tip_chamfer_height_mm + overlap_mm, center=true);

      // External thread ridge (adds to minor cylinder up to near major diameter)
      if (show_threads)
        thread_solid(major_r=major_r, pitch=thread_pitch_mm, depth=thread_depth_mm, len=length_mm, center=true);
    }

    // Hex socket recess at top end (subtracted), with overlap to guarantee cut-through
    translate([0, 0, length_mm/2 - (socket_depth + overlap_mm)/2])
      hex_prism(af=hex_socket_af_mm, h=socket_depth + overlap_mm, center=true);
  }
}

grub_screw();