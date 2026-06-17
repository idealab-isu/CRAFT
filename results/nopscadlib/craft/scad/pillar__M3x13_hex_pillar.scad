// Standoff pillar (hex body) with M3 internal thread (visual) through-hole
// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 13.0; //[6.5:26.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]  // across flats for hex body
thread_pitch_mm = 0.5; //[0.35:1.0:0.05]
top_thread = 1; //[0:1:1]
bottom_thread = 1; //[0:1:1]
thread_length_mm = 13.0; //[3.0:26.0:0.5]
end_face_chamfer_height_mm = 0.8; //[0.2:2.0:0.1]
end_face_chamfer_delta_d_mm = 0.8; //[0.2:2.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Thread visual parameters (simple helical groove; not standards-accurate ISO profile)
thread_depth_mm = 0.25;   // radial depth of groove
thread_width_mm = 0.45;   // tangential width of groove
thread_fn = 96;

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

// Hex prism sized by across-flats (AF)
module hex_prism_af(af, h, center=true, fn=6) {
  // For a regular hex: AF = 2 * apothem = 2 * r * cos(30) => r = AF / sqrt(3)
  r = af / sqrt(3);
  cylinder(h=h, r=r, center=center, $fn=fn);
}

// Chamfered hex body (one connected solid)
module standoff_body_hex() {
  af = outer_diameter_mm;
  af2 = max(0.01, af - end_face_chamfer_delta_d_mm);
  ch = clamp(end_face_chamfer_height_mm, 0, length_mm/2);

  union() {
    // Main hex body
    hex_prism_af(af, length_mm, center=true, fn=6);

    // Top chamfer (overlapped)
    translate([0, 0, length_mm/2 - ch/2 - overlap_mm/2])
      cylinder(
        h=ch + overlap_mm,
        r1=(af / sqrt(3)),
        r2=(af2 / sqrt(3)),
        center=true,
        $fn=6
      );

    // Bottom chamfer (overlapped)
    translate([0, 0, -length_mm/2 + ch/2 + overlap_mm/2])
      cylinder(
        h=ch + overlap_mm,
        r1=(af2 / sqrt(3)),
        r2=(af / sqrt(3)),
        center=true,
        $fn=6
      );
  }
}

// Helical groove cutter for internal thread (visual)
module internal_thread_cutter(d_minor, pitch, len, depth=0.25, width=0.45, fn=96) {
  r = d_minor/2;
  turns = len / pitch;

  // A twisted rectangular "ridge" that will be SUBTRACTED to form a groove
  linear_extrude(
    height=len,
    center=true,
    twist=turns*360,
    slices=max(ceil(turns*28), 28),
    convexity=10
  )
    translate([r - depth/2, 0, 0])
      square([depth, width], center=true);
}

// Assembly: hex standoff with internal threaded hole (one connected solid)
module assembly() {
  // Threaded region selection (from ends inward)
  tlen = clamp(thread_length_mm, 0, length_mm);

  difference() {
    // Outer body
    standoff_body_hex();

    // Base through-hole (minor diameter) for internal thread
    // Keep it through the full length so it's a true standoff pillar
    cylinder(h=length_mm + 2*overlap_mm, r=thread_diameter_mm/2, center=true, $fn=thread_fn);

    // Helical grooves (visual internal thread) where enabled
    if (top_thread && bottom_thread) {
      internal_thread_cutter(thread_diameter_mm, thread_pitch_mm, length_mm + overlap_mm, thread_depth_mm, thread_width_mm, thread_fn);
    } else if (top_thread) {
      translate([0, 0, length_mm/2 - tlen/2 + overlap_mm/2])
        internal_thread_cutter(thread_diameter_mm, thread_pitch_mm, tlen + overlap_mm, thread_depth_mm, thread_width_mm, thread_fn);
    } else if (bottom_thread) {
      translate([0, 0, -length_mm/2 + tlen/2 - overlap_mm/2])
        internal_thread_cutter(thread_diameter_mm, thread_pitch_mm, tlen + overlap_mm, thread_depth_mm, thread_width_mm, thread_fn);
    }
  }
}

assembly();