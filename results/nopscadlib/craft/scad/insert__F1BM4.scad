// Threaded heat-set insert (visual model)
// 8.2mm OD, 6.3mm long, for 4.0mm screws

$fn = 96;

// Parameters
outer_diameter_mm = 8.2; //[4.1:16.4:0.1]
length_mm = 6.3; //[3.15:12.6:0.1]
screw_diameter_mm = 4; //[2:8:0.1]
internal_pitch_mm = 0.7; //[0.35:1.4:0.05]
internal_minor_diameter_mm = 3.3; //[2.5:3.8:0.05]
knurl_depth_mm = 0.6; //[0.3:1.2:0.05]
knurl_pitch_mm = 1.2; //[0.6:2.4:0.1]
knurl_ring_count = 5; //[2:12:1]
chamfer_length_mm = 0.8; //[0.4:1.6:0.05]
chamfer_angle_deg = 30; //[15:60:1]
overlap_mm = 0.8; //[0.5:2:0.1]
bore_extra_length_mm = 1; //[0.5:3:0.1]

// Derived
outer_r = outer_diameter_mm/2;
minor_r = internal_minor_diameter_mm/2;

// Keep chamfers valid
chamfer_len = min(chamfer_length_mm, length_mm/2 - 0.01);
mid_len = max(0.01, length_mm - 2*chamfer_len);

// Knurl sizing
knurl_r = max(0.01, knurl_depth_mm/2);
knurl_center_r = outer_r - knurl_r; // ensures knurl protrudes outward to outer_r
ring_step = mid_len / knurl_ring_count;

module threaded_insert() {
  color([0.8, 0.6, 0.2])  // brass-ish
  difference() {
    union() {
      // Main body with end chamfers (single connected solid)
      union() {
        // Middle straight section
        cylinder(h=mid_len, r=outer_r, center=true);

        // Top chamfer (frustum)
        translate([0, 0, mid_len/2 + chamfer_len/2 - overlap_mm/2])
          cylinder(h=chamfer_len + overlap_mm, r1=outer_r, r2=max(0.01, outer_r - chamfer_len*tan(chamfer_angle_deg)), center=true);

        // Bottom chamfer (frustum)
        translate([0, 0, -mid_len/2 - chamfer_len/2 + overlap_mm/2])
          cylinder(h=chamfer_len + overlap_mm, r1=max(0.01, outer_r - chamfer_len*tan(chamfer_angle_deg)), r2=outer_r, center=true);
      }

      // External knurl rings (additive, connected via slight overlap)
      for (i = [0:knurl_ring_count-1]) {
        z_i = -mid_len/2 + (i + 0.5)*ring_step;
        translate([0, 0, z_i])
          rotate_extrude(convexity=10)
            translate([knurl_center_r, 0, 0])
              circle(r=knurl_r);
      }
    }

    // Internal bore (minor diameter for M4 thread)
    // Extra length ensures clean cut through chamfers
    cylinder(h=length_mm + bore_extra_length_mm, r=minor_r, center=true);
  }
}

threaded_insert();