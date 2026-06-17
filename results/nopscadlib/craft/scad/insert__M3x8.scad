// Threaded heat-set insert (simplified solid model)
// Target: 8.0mm OD, 6.0mm long, for 3.0mm screws

$fn = 96;

// Parameters
screw_diameter = 3.0; //[1.5:6.0:0.1]
outer_diameter = 8.0; //[4.0:16.0:0.1]
length = 6.0; //[3.0:12.0:0.1]

internal_clearance_diameter_mm = 3.2; //[2.8:4.0:0.05]

top_chamfer_mm = 0.5; //[0.25:1.5:0.05]
bottom_chamfer_mm = 0.5; //[0.25:1.5:0.05]

external_feature_depth_mm = 0.3; //[0.1:0.8:0.05]
external_feature_pitch_mm = 0.8; //[0.4:1.6:0.05]
external_feature_count = 6; //[3:12:1]
external_feature_ring_height_mm = 0.35; //[0.2:0.8:0.05]
external_feature_overlap_mm = 0.6; //[0.3:1.5:0.05]

bore_extra_length_mm = 0.6; //[0.2:2.0:0.1]

// Small overlap to guarantee manifold unions/differences
eps = 0.02;

// Derived
outer_r = outer_diameter/2;
bore_r  = internal_clearance_diameter_mm/2;

// Clamp features to valid ranges (prevents empty/invalid geometry)
ring_h = min(external_feature_ring_height_mm, max(eps, length - 2*eps));
ring_count = max(1, external_feature_count);
ring_pitch = max(eps, external_feature_pitch_mm);

// Place rings evenly within the body height, always inside [-length/2, +length/2]
usable_span = max(0, length - ring_h - 2*eps);
ring_span = min((ring_count - 1) * ring_pitch, usable_span);
ring_step = (ring_count > 1) ? (ring_span / (ring_count - 1)) : 0;
ring_z_start = -ring_span/2;

// Ensure ring subtraction radius is valid
ring_inner_r = max(eps, outer_r - max(0, external_feature_overlap_mm));
ring_outer_r = max(outer_r + eps, outer_r + max(0, external_feature_depth_mm));

module threaded_insert() {
  color([0.8, 0.6, 0.2])
  difference() {
    union() {
      // Main body
      cylinder(h=length, r=outer_r, center=true);

      // External rings (connected; slight Z overlap to avoid coincident faces)
      for (i = [0:ring_count-1]) {
        z_i = ring_z_start + i * ring_step;
        translate([0, 0, z_i])
          difference() {
            cylinder(h=ring_h + 2*eps, r=ring_outer_r, center=true);
            cylinder(h=ring_h + 4*eps, r=ring_inner_r, center=true);
          }
      }
    }

    // Internal clearance bore (through, extended)
    cylinder(h=length + bore_extra_length_mm + 2*eps, r=bore_r, center=true);

    // Top chamfer (subtract)
    translate([0, 0, length/2 - top_chamfer_mm/2])
      cylinder(h=top_chamfer_mm + 2*eps,
               r1=outer_r + eps,
               r2=max(eps, outer_r - top_chamfer_mm),
               center=true);

    // Bottom chamfer (subtract)
    translate([0, 0, -length/2 + bottom_chamfer_mm/2])
      cylinder(h=bottom_chamfer_mm + 2*eps,
               r1=max(eps, outer_r - bottom_chamfer_mm),
               r2=outer_r + eps,
               center=true);
  }
}

threaded_insert();