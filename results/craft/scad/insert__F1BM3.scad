// Threaded heat-set insert (approximation)
// Target: 5.8mm OD, 4.6mm long, for 3.0mm screws

$fn = 96;

// Parameters
screw_diameter_mm = 3.0; //[1.5:6.0:0.1]
internal_thread_pitch_mm = 0.5; //[0.25:1.0:0.05]
outer_diameter_mm = 5.8; //[2.9:11.6:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]

// Typical M3 internal thread minor diameter is ~2.4-2.6mm; keep user param but default to 2.6
bore_diameter_mm = 2.6; //[1.3:5.2:0.05]

// Knurl
knurl_ridge_count = 18; //[8:40:1]
knurl_ridge_depth_mm = 0.35; //[0.15:0.8:0.05]
knurl_ridge_width_mm = 0.6; //[0.3:1.2:0.05]
ridge_height_mm = 3.6; //[1.8:7.2:0.1]
ridge_band_offset_mm = 0.5; //[0.2:1.2:0.05]

// Chamfers
chamfer_height_mm = 0.6; //[0.3:1.2:0.05]
chamfer_radial_reduction_mm = 0.6; //[0.2:1.2:0.05]

// Thread representation (simple helical ridge inside bore)
thread_depth_mm = 0.18; //[0.05:0.35:0.01]
thread_width_mm = 0.35; //[0.15:0.7:0.01]

eps_mm = 0.05; //[0.01:0.2:0.01]

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module internal_thread_visual(minor_d, pitch, len, depth, width) {
  // Creates a helical "ridge" that protrudes into the bore.
  // This is a visual/approximate thread, not a standards-accurate profile.
  minor_r = minor_d/2;
  // Keep thread within bore
  depth2 = clamp(depth, 0, minor_r - 0.2);
  turns = len / pitch;

  // Place the ridge near the bore wall, protruding inward by depth2
  translate([0,0,-len/2])
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
      translate([minor_r - depth2/2, 0, 0])
        square([depth2, width], center=true);
}

module insert() {
  color([0.8, 0.6, 0.2])  // Brass-like
  difference() {
    union() {
      // Main body
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);

      // End chamfers (connected by overlap)
      translate([0, 0,  length_mm/2 - chamfer_height_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_radial_reduction_mm,
                 h=chamfer_height_mm, center=true);

      translate([0, 0, -length_mm/2 + chamfer_height_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_radial_reduction_mm,
                 h=chamfer_height_mm, center=true);

      // Knurl ridges: protrude outward from the OD and overlap into body slightly
      // Ensure ridges stay within the insert length (ridge_height_mm <= length_mm recommended)
      for (i = [0:knurl_ridge_count-1]) {
        rotate([0, 0, i*360/knurl_ridge_count])
          translate([outer_diameter_mm/2 + knurl_ridge_depth_mm/2 - eps_mm, 0, 0])
            cube([knurl_ridge_depth_mm, knurl_ridge_width_mm, ridge_height_mm], center=true);
      }
    }

    // Circular internal bore (fixes polygonal hole)
    cylinder(r=bore_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);

    // Optional: slight lead-in at both ends of bore
    translate([0,0, length_mm/2 - chamfer_height_mm/2])
      cylinder(r1=bore_diameter_mm/2 + chamfer_radial_reduction_mm*0.35,
               r2=bore_diameter_mm/2,
               h=chamfer_height_mm + eps_mm, center=true);

    translate([0,0,-length_mm/2 + chamfer_height_mm/2])
      cylinder(r1=bore_diameter_mm/2 + chamfer_radial_reduction_mm*0.35,
               r2=bore_diameter_mm/2,
               h=chamfer_height_mm + eps_mm, center=true);

    // Visual internal threading representation (subtracted from body to create thread grooves)
    // Subtracting the ridge creates a helical groove; looks like internal threads.
    internal_thread_visual(
      minor_d = bore_diameter_mm,
      pitch   = internal_thread_pitch_mm,
      len     = length_mm + 2*eps_mm,
      depth   = thread_depth_mm,
      width   = thread_width_mm
    );
  }
}

module threaded_insert() { insert(); }
module assembly() { threaded_insert(); }

assembly();