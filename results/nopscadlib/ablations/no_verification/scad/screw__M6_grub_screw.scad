// Parameters
length_mm = 12; //[6:24:1]
thread_major_d_mm = 6; //[3:12:0.5]
thread_pitch_mm = 1; //[0.5:1.5:0.1]
socket_af_mm = 3; //[2:5:0.5]
socket_depth_mm = 3; //[1.5:6:0.5]
thread_relief_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
tip_style_flat = 1; //[0:1:1]
hob_point_mm = 0; //[0:6:0.5]
nylon = 0; //[0:1:1]
thread_standard_metric = 1; //[1:1:1]
thread_size_M6 = 6; //[6:6:1]
screw_type_grub = 1; //[1:1:1]
socket_type_hex = 1; //[1:1:1]
thread_radius_mm = 3; //[1.5:6:0.25]

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module hex_prism(af, h, center=false) {
  // across flats -> circumradius
  r = af/(2*cos(30));
  cylinder(r=r, h=h, $fn=6, center=center);
}

// Simple external helical thread (triangular-ish ridge) using linear_extrude twist
module external_thread(major_d, pitch, len, depth, overlap=0.2, fn=96) {
  r_maj = major_d/2;
  d = clamp(depth, 0.15, major_d*0.18);
  turns = len/pitch;

  // 2D profile placed at radius; extruded with twist to form helix
  // Profile is a small wedge that protrudes outward from a slightly smaller base radius.
  r_base = r_maj - d;

  linear_extrude(height=len + 2*overlap, twist=turns*360, slices=ceil(turns*24), convexity=10)
    translate([r_base, 0, 0])
      polygon(points=[
        [0, -pitch*0.22],
        [d, 0],
        [0,  pitch*0.22]
      ]);
}

// ---------- Screw ----------
module screw() {
  $fn = 96;

  major_r = thread_major_d_mm/2;
  pitch   = thread_pitch_mm;
  len     = length_mm;

  // Thread depth (approx for metric; tuned for visibility/printability)
  thread_depth = clamp(0.65 * pitch, 0.25, 0.9);

  // Core radius so thread ridge reaches major diameter
  core_r = major_r - thread_depth;

  // Socket placement (top end)
  socket_h = clamp(socket_depth_mm, 0.5, len - 0.5);
  socket_z = len/2 - socket_h/2 + overlap_mm*0.25; // slight bias inward

  // Tip style: flat or cone (if tip_style_flat==0)
  cone_h = clamp(0.9*pitch, 0.4, len/3);

  difference() {
    union() {
      // Core body (minor diameter cylinder)
      cylinder(r=core_r, h=len, center=true);

      // External helical thread ridge (adds to core to reach major diameter)
      translate([0, 0, -len/2 - overlap_mm])
        external_thread(thread_major_d_mm, pitch, len, thread_depth, overlap=overlap_mm, fn=$fn);

      // Tip/end detail
      if (tip_style_flat == 1) {
        // Flat point with slight chamfer
        translate([0, 0, -len/2])
          cylinder(r1=major_r, r2=major_r - thread_depth*0.6, h=clamp(0.6*pitch, 0.3, 1.2), center=false);
      } else {
        // Cone point
        translate([0, 0, -len/2])
          cylinder(r1=major_r, r2=0.2, h=cone_h, center=false);
      }

      // Optional small "hob/cup" dimple at tip (subtracted later if >0)
      // (kept as solid here; handled in difference below)
    }

    // Internal hex socket (drive feature)
    translate([0, 0, socket_z])
      hex_prism(socket_af_mm, socket_h + overlap_mm, center=true);

    // Thread relief at top edge (small chamfer/undercut)
    translate([0, 0, len/2 - clamp(0.6*pitch, 0.3, 1.2)/2])
      cylinder(r1=major_r + 0.01, r2=major_r - thread_relief_mm, h=clamp(0.6*pitch, 0.3, 1.2), center=true);

    // Optional cup/hob point dimple
    if (hob_point_mm > 0) {
      dimple_r = clamp(hob_point_mm/2, 0.2, major_r*0.9);
      dimple_depth = clamp(hob_point_mm*0.35, 0.2, len/4);
      translate([0, 0, -len/2 + dimple_depth - overlap_mm*0.2])
        sphere(r=dimple_r, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  color("DimGray") screw();
}

assembly();