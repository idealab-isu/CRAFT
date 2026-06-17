// Threaded heat-set insert (visual model)
// Target: 10.0mm OD, 8.0mm long, for 4.0mm screws

$fn = 128;

// Parameters
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 8; //[4:16:0.1]
screw_nominal_diameter_mm = 4; //[2:8:0.1]
inner_thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
chamfer_length_mm = 0.5; //[0.25:1:0.05]
knurl_depth_mm = 0.3; //[0.15:0.6:0.05]
knurl_pitch_mm = 0.8; //[0.4:1.6:0.05]
through_bore = 1; //[0:1:1]
inner_bore_diameter_mm = 4.2; //[3.6:5:0.05]
knurl_band_length_mm = 6; //[3:12:0.1]
knurl_ring_thickness_mm = 0.4; //[0.2:1:0.05]
knurl_ring_count = 7; //[3:20:1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module threaded_insert() {
  // Robustness guards to avoid empty/invalid geometry
  od = max(outer_diameter_mm, 0.01);
  L  = max(length_mm, 0.01);

  // Ensure a minimum wall thickness so the solid doesn't disappear
  min_wall = 0.6;
  bore_d = clamp(inner_bore_diameter_mm, 0.01, max(0.01, od - 2*min_wall));

  chamfer_L = clamp(chamfer_length_mm, 0.0, max(0.0, L/2 - 0.01));

  band_L = clamp(knurl_band_length_mm, 0.0, L);
  ring_t = clamp(knurl_ring_thickness_mm, 0.01, max(0.01, band_L));
  ring_n = max(1, floor(knurl_ring_count));

  // Distribute rings across band (or center if only one)
  band_z0 = -band_L/2;
  ring_step = (ring_n <= 1) ? 0 : (band_L / (ring_n - 1));

  // Keep knurl depth sane
  knurl_d = clamp(knurl_depth_mm, 0.0, od/2);

  color([0.8, 0.6, 0.2])  // brass-like
  difference() {
    union() {
      // Main body
      cylinder(d=od, h=L, center=true);

      // External knurl rings (connected by overlap into main body)
      if (band_L > 0 && ring_t > 0 && ring_n > 0 && knurl_d > 0) {
        for (i = [0:ring_n-1]) {
          z_i = (ring_n <= 1) ? 0 : (band_z0 + i * ring_step);
          // Clamp ring center so full ring thickness stays inside the body
          zc = clamp(z_i, -L/2 + ring_t/2, L/2 - ring_t/2);

          translate([0, 0, zc])
            cylinder(d=od + 2*knurl_d, h=ring_t + overlap_mm, center=true);
        }
      }
    }

    // Internal bore (through or blind)
    bore_h = through_bore ? (L + 2*overlap_mm) : max(0.01, L - 2*chamfer_L);
    bore_z = through_bore ? 0 : (-L/2 + chamfer_L + bore_h/2);

    translate([0, 0, bore_z])
      cylinder(d=bore_d, h=bore_h, center=true);

    // End chamfers (subtract) - ensure they actually cut into the ends
    if (chamfer_L > 0) {
      // Top chamfer
      translate([0, 0, L/2 - chamfer_L/2])
        cylinder(d1=bore_d + 2*chamfer_L, d2=bore_d, h=chamfer_L + overlap_mm, center=true);

      // Bottom chamfer
      translate([0, 0, -L/2 + chamfer_L/2])
        cylinder(d1=bore_d + 2*chamfer_L, d2=bore_d, h=chamfer_L + overlap_mm, center=true);
    }
  }
}

threaded_insert();