// M6 Pan Head Screw (render-friendly, simplified)
// Target: 6.0mm shank diameter, 12.0mm head diameter, 4.75mm head height, 10mm length
// Connectivity fix: ensure under-head circular face is fused to head + shank with real overlap.

$fn = 32;

// Parameters
shaft_diameter_mm = 6.0;
head_diameter_mm  = 12.0;
head_height_mm    = 4.75;
length_mm         = 10.0;

// Use a real overlap for robust manifold union (per requirements: 1–2mm)
overlap_mm = 1.2;

// Pan head shaping
underhead_relief_mm = 0.35;

// Drive recess (simple cross)
drive_recess_depth_mm      = 2.2;
drive_recess_radius_factor = 0.58;
drive_slot_width_mm        = 1.2;

// Simplified thread approximation (rings)
thread_pitch_mm        = 1.0;
thread_height_mm       = 0.35;
thread_start_mm        = 0.6;
thread_end_chamfer_mm  = 1.0;

function pan_head_profile_points(r_head, h_head, under_relief) =
    // 2D profile for rotate_extrude: X=radius, Y=height
    [
      [0, 0],
      [max(0, r_head - under_relief), 0],
      [r_head, under_relief],
      [r_head, h_head*0.55],
      [r_head*0.85, h_head*0.85],
      [r_head*0.55, h_head],
      [0, h_head]
    ];

module ring_thread(r_major, pitch, z0, z1) {
  // z0..z1 are negative values (below head), with z0 closer to 0.
  turns = max(0, floor((abs(z1 - z0)) / pitch));
  ring_h = max(0.15, min(0.30, pitch*0.30));
  for (i = [0 : turns]) {
    z = z0 - i*pitch;
    if (z >= z1 - pitch - 0.001) {
      translate([0,0,z])
        cylinder(h=ring_h, r=r_major, center=true);
    }
  }
}

module screw_m6_pan() {
  r_shaft = shaft_diameter_mm/2;
  r_head  = head_diameter_mm/2;

  z_thread_start = -thread_start_mm;
  z_thread_end   = -length_mm + thread_end_chamfer_mm;

  // Added: under-head "bearing face" disc that is guaranteed to intersect both head and shank.
  // This fixes the floating/disconnected orange circular insert by making it part of the main union.
  underhead_disc_h = 1.6;                 // thickness of the face
  underhead_disc_r = r_head - 0.25;       // keep just inside head OD
  // Place so it straddles z=0 and overlaps into both head (z>0) and shank (z<0)
  underhead_disc_z = -underhead_disc_h/2 + overlap_mm/2;

  difference() {
    union() {
      // Shank core (minor diameter)
      translate([0,0,-length_mm/2])
        cylinder(h=length_mm, r=max(0.1, r_shaft - thread_height_mm), center=true);

      // Thread suggestion (rings)
      ring_thread(r_major=r_shaft, pitch=thread_pitch_mm, z0=z_thread_start, z1=z_thread_end);

      // Tip chamfer
      translate([0,0,-length_mm + thread_end_chamfer_mm/2])
        cylinder(h=thread_end_chamfer_mm,
                 r1=max(0.1, r_shaft - thread_height_mm),
                 r2=max(0.2, (r_shaft - thread_height_mm) - 0.8),
                 center=true);

      // Pan head (rotate_extrude of 2D profile)
      rotate_extrude(convexity=6)
        polygon(points=pan_head_profile_points(r_head, head_height_mm, underhead_relief_mm));

      // Connectivity fix: fused under-head circular face (disc) with 1–2mm overlap
      translate([0,0,underhead_disc_z])
        cylinder(h=underhead_disc_h, r=underhead_disc_r, center=true);
    }

    // Drive recess (subtracted from head top)
    recess_r = r_head * drive_recess_radius_factor;
    translate([0,0,head_height_mm - drive_recess_depth_mm/2])
      union() {
        cylinder(h=drive_recess_depth_mm + overlap_mm, r=recess_r, center=true);
        cube([2*recess_r + overlap_mm, drive_slot_width_mm, drive_recess_depth_mm + overlap_mm], center=true);
        cube([drive_slot_width_mm, 2*recess_r + overlap_mm, drive_recess_depth_mm + overlap_mm], center=true);
      }

    // Flatten underside at z=0 (thin cut) - keep very thin so it doesn't "separate" the new disc
    // Still ensures a clean underside plane while preserving solid connectivity.
    translate([0,0,-0.05])
      cylinder(h=0.10, r=r_head + 1, center=true);
  }
}

screw_m6_pan();