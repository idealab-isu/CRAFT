// Hex head screw: shank Ø8.0, head AF 15.0, head height 5.65, shank length 10.0
// Fast-render version: no helical thread; optional simple rings disabled by default.

$fn = 32;

// Parameters
shank_d = 8.0;                 // mm
shank_L = 10.0;                // mm
head_AF = 15.0;                // mm (across flats)
head_H = 5.65;                 // mm
overlap = 0.15;                // mm

head_top_chamfer_h = 0.8;      // mm
head_top_chamfer_inset = 1.0;  // mm
underhead_taper_h = 1.0;       // mm

tip_chamfer_h = 1.2;           // mm

// Simplified "thread" rings (disabled by default for speed)
enable_thread_rings = false;
thread_L = 10.0;               // mm
thread_pitch = 1.25;           // mm
thread_depth = 0.35;           // mm (radial)
thread_ring_h = 0.35;          // mm (axial thickness of each ring)

drive_hex_AF = 6.0;            // mm
drive_depth = 3.0;             // mm

marking_notch_w = 1.2;         // mm
marking_notch_L = 4.0;         // mm
marking_notch_depth = 0.3;     // mm

// Derived
head_R = head_AF / sqrt(3);
head_top_R2 = (head_AF - 2*head_top_chamfer_inset) / sqrt(3);

z_head_center = 0;
z_head_top = z_head_center + head_H/2;
z_head_bottom = z_head_center - head_H/2;

z_shank_top = z_head_bottom + overlap;
z_shank_bottom = z_shank_top - shank_L;

thread_L_eff = min(thread_L, shank_L);
z_thread_top = z_shank_top;
z_thread_bottom = z_thread_top - thread_L_eff;

// Helpers
module hex_prism(h, af, center=true) {
  cylinder(h=h, r=af/sqrt(3), center=center, $fn=6);
}

module head() {
  union() {
    // Main hex head
    translate([0,0,z_head_center])
      hex_prism(head_H, head_AF, center=true);

    // Top chamfer (frustum)
    translate([0,0,z_head_top - head_top_chamfer_h/2 + overlap/2])
      cylinder(h=head_top_chamfer_h + overlap,
               r1=head_R,
               r2=head_top_R2,
               center=true, $fn=6);

    // Underhead transition (simple taper to shank)
    translate([0,0,z_head_bottom - underhead_taper_h/2 + overlap/2])
      cylinder(h=underhead_taper_h + overlap,
               r1=head_R,
               r2=shank_d/2,
               center=true, $fn=24);
  }
}

module shank() {
  // Simple cylinder at major diameter (fast)
  translate([0,0,(z_shank_top+z_shank_bottom)/2])
    cylinder(h=shank_L, r=shank_d/2, center=true, $fn=32);
}

module tip_chamfer() {
  translate([0,0,z_shank_bottom + tip_chamfer_h/2 - overlap/2])
    cylinder(h=tip_chamfer_h + overlap, r1=shank_d/2, r2=0.25, center=true, $fn=32);
}

// Optional fast "thread" impression: a few thin rings along the shank
module thread_rings() {
  if (!enable_thread_rings) return;
  if (thread_L_eff <= 0) return;

  core_r = shank_d/2 - thread_depth;
  outer_r = shank_d/2;

  n = max(1, floor(thread_L_eff / thread_pitch));
  for (k = [0:n-1]) {
    zc = z_thread_top - (k + 0.5) * thread_pitch;
    if (zc >= z_thread_bottom - thread_pitch/2) {
      translate([0,0,zc])
        difference() {
          cylinder(h=thread_ring_h, r=outer_r, center=true, $fn=24);
          cylinder(h=thread_ring_h + overlap, r=core_r, center=true, $fn=24);
        }
    }
  }
}

module drive_recess_hex() {
  translate([0,0,z_head_top - drive_depth/2 - overlap/2])
    cylinder(h=drive_depth + overlap,
             r=drive_hex_AF/sqrt(3),
             center=true, $fn=6);
}

module marking_notches() {
  translate([0,0,z_head_top - marking_notch_depth/2 - overlap/2]) {
    cube([marking_notch_L, marking_notch_w, marking_notch_depth + overlap], center=true);
    cube([marking_notch_w, marking_notch_L, marking_notch_depth + overlap], center=true);
  }
}

module screw_solid() {
  union() {
    head();
    shank();
    thread_rings();
    tip_chamfer();
  }
}

// Final
difference() {
  screw_solid();
  union() {
    drive_recess_hex();
    marking_notches();
  }
}