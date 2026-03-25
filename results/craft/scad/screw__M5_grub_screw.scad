// M5 Grub (Set) Screw with hex socket + integrated helical threads
// FIX: ensure the top "cap/insert" is not floating by extending/overlapping the
// top chamfer into the body and ensuring all solids are in one union().

$fn = 96;

// Parameters
length_mm = 10; //[5:20:1]
thread_major_d = 5; //[4:6:0.1]
thread_pitch = 0.8; //[0.5:1:0.05]
show_threads = 1; //[0:1:1]
hex_socket_af = 2.5; //[2:3:0.1]
hex_socket_depth = 2.5; //[1.5:4:0.1]
hob_point_mm = 0; //[0:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
thread_depth_factor = 0.35; //[0.2:0.5:0.05]
thread_turns_per_length = 1; //[1:3:1]

// Derived
major_r = thread_major_d/2;
thread_depth = thread_pitch * thread_depth_factor;          // radial depth
minor_r = max(0.1, major_r - thread_depth);
starts = max(1, thread_turns_per_length);
lead = thread_pitch * starts;                               // mm per revolution
thread_len = max(0.1, length_mm - hob_point_mm);
turns = thread_len / lead;

// Helpers
module hex_prism(af, h, center=true) {
  r = af/(2*cos(30)); // across flats -> circumradius
  cylinder(r=r, h=h, center=center, $fn=6);
}

// Proper helical thread: rotate_extrude a radial profile while translating along Z.
module helical_thread(major_r, minor_r, pitch, length, starts=1) {
  lead = pitch * starts;
  turns = length / lead;

  module thread_profile() {
    polygon(points=[
      [minor_r, -pitch*0.25],
      [major_r,  0],
      [minor_r,  pitch*0.25]
    ]);
  }

  union() {
    for (s = [0:starts-1]) {
      rotate([0,0, s*360/starts])
        linear_extrude(height=length, twist=360*turns,
                       slices=max(ceil(turns*120), 80), convexity=10)
          rotate_extrude(angle=360, convexity=10)
            thread_profile();
    }
  }
}

module screw() {
  // End chamfers: extend height by overlap_mm and position so they intersect the core
  chamfer_h = 0.6;
  chamfer_h_u = chamfer_h + overlap_mm;

  // Center positions so each chamfer overlaps the main body by overlap_mm/2
  z_top_chamfer =  length_mm/2 - chamfer_h/2 - overlap_mm/2;
  z_bot_chamfer = -length_mm/2 + chamfer_h/2 + overlap_mm/2;

  difference() {
    union() {
      // Core at minor diameter (thread root), centered
      cylinder(r=minor_r, h=length_mm, center=true);

      // Integrated thread: centered and overlapped slightly into the core
      if (show_threads) {
        translate([0, 0, -length_mm/2 + thread_len/2])
          helical_thread(
            major_r=major_r,
            minor_r=minor_r - 0.01,
            pitch=thread_pitch,
            length=thread_len + overlap_mm,
            starts=starts
          );
      }

      // Optional point (simple cone), overlapped into body
      if (hob_point_mm > 0) {
        translate([0, 0, -length_mm/2 + hob_point_mm/2 - overlap_mm/2])
          cylinder(r1=major_r, r2=0, h=hob_point_mm + overlap_mm, center=true);
      }

      // End chamfers (now guaranteed to intersect the main body; no floating ring/cap)
      translate([0, 0, z_top_chamfer])
        cylinder(r1=major_r*0.92, r2=major_r, h=chamfer_h_u, center=true);

      translate([0, 0, z_bot_chamfer])
        cylinder(r1=major_r, r2=major_r*0.92, h=chamfer_h_u, center=true);
    }

    // Hex socket cut from the top end, overlapped to ensure clean subtraction
    translate([0, 0, length_mm/2 - hex_socket_depth/2 + overlap_mm/2])
      hex_prism(hex_socket_af, hex_socket_depth + overlap_mm, center=true);

    // Slight mouth relief at socket entrance (subtractive), formula-based
    mouth_h = 0.6;
    translate([0, 0, length_mm/2 - mouth_h/2 + overlap_mm/2])
      cylinder(r1=major_r*0.98, r2=major_r*0.85, h=mouth_h + overlap_mm, center=true);
  }
}

screw();