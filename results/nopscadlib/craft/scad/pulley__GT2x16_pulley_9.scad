// Timing pulley: 16 teeth, 9.65mm pitch diameter
// One connected solid. Teeth are GT2-like (rounded) approximations placed by pitch geometry.

$fn = 220;

// Required specs
tooth_count        = 16;
pitch_diameter_mm  = 9.65;

// Pulley size
pulley_width_mm = 10;

// Tooth geometry (GT2-like approximation, not exact spec)
tooth_radial_height_mm   = 1.25;  // height above pitch circle
tooth_root_overlap_mm    = 0.70;  // overlaps into body for guaranteed connectivity
tooth_tip_round_r_mm     = 0.35;  // rounding at tooth tip
tooth_root_round_r_mm    = 0.25;  // rounding at tooth root
tooth_tangential_width_mm = 1.05; // tooth thickness around circumference at pitch

// Optional bore (0 = solid)
bore_diameter_mm = 0;

// Derived radii
pitch_r = pitch_diameter_mm/2;
root_r  = pitch_r - tooth_root_overlap_mm;
outer_r = pitch_r + tooth_radial_height_mm;

// Safety
root_r_safe = max(0.2, root_r);

// 2D rounded-rectangle helper (centered)
module rounded_rect_2d(w, h, r) {
  r2 = min(r, w/2 - 1e-6, h/2 - 1e-6);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
  }
}

// Single tooth as a 2D profile in XY, then extruded in Z.
// X = radial direction, Y = tangential direction.
module tooth_2d() {
  tooth_len = tooth_radial_height_mm + tooth_root_overlap_mm;

  // Main body with rounded corners
  union() {
    rounded_rect_2d(tooth_len, tooth_tangential_width_mm, tooth_root_round_r_mm);

    // Extra rounding at the tip (outer side) to look more timing-tooth-like
    translate([tooth_len/2 - tooth_tip_round_r_mm, 0])
      circle(r=tooth_tip_round_r_mm);
  }
}

module timing_pulley() {
  difference() {
    union() {
      // Body up to tooth root (keeps pitch diameter meaningful)
      cylinder(r=root_r_safe, h=pulley_width_mm, center=true);

      // Teeth: exactly tooth_count, centered on pitch circle, overlapped into body
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i * 360 / tooth_count])
          translate([pitch_r + tooth_radial_height_mm/2 - tooth_root_overlap_mm/2, 0, 0])
            linear_extrude(height=pulley_width_mm, center=true, convexity=10)
              tooth_2d();
      }
    }

    // Bore (optional)
    if (bore_diameter_mm > 0)
      cylinder(r=bore_diameter_mm/2, h=pulley_width_mm + 0.6, center=true);
  }
}

timing_pulley();