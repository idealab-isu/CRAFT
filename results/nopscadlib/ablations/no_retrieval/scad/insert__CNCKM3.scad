// Threaded heat-set insert (M3), OD=3.0mm, L=4.6mm
// One connected solid: cylindrical body with external knurl + internal helical thread (cut)

$fn = 128;

// ---------------- Parameters ----------------
od = 3.0;                       //[1.5:6.0:0.1]
L  = 4.6;                       //[2.3:9.2:0.1]

thread_nominal_d   = 3.0;       //[2.0:6.0:0.1]   // M3
thread_pitch       = 0.5;       //[0.25:1.0:0.05] // M3 coarse = 0.5
thread_minor_d     = 2.5;       //[1.5:5.0:0.05]  // approx internal minor diameter for M3
bore_depth         = 4.6;       //[2.3:9.2:0.1]

knurl_depth        = 0.20;      //[0.1:0.6:0.05]
knurl_pitch        = 0.60;      //[0.3:1.2:0.05]
knurl_tooth_width  = 0.25;      //[0.15:0.6:0.05]
knurl_band_margin  = 0.40;      //[0.2:1.0:0.05]

chamfer            = 0.25;      //[0.1:0.8:0.05]
lead_in_len        = 0.60;      //[0.3:1.5:0.05]
lead_in_rad_reduction = 0.12;  //[0.05:0.4:0.05]

thread_relief_len  = 0.50;      //[0.3:1.5:0.05]
thread_relief_extra_d = 0.25;  //[0.1:0.8:0.05]

end_mark_d         = 0.80;      //[0.4:1.6:0.05]
end_mark_depth     = 0.15;      //[0.05:0.4:0.05]

overlap            = 0.20;      //[0.05:1.0:0.05]

// ---------------- Derived ----------------
od_r      = od/2;
minor_r   = thread_minor_d/2;
major_r   = thread_nominal_d/2;

// ---------------- Helpers ----------------
module body_base() {
  // Solid outer body (connected), with slight lead-in tapers
  union() {
    cylinder(h=L, r=od_r, center=true);

    // lead-in tapers (OD reduction near ends), connected by overlap
    translate([0,0,  L/2 - lead_in_len/2])
      cylinder(h=lead_in_len + overlap, r1=od_r, r2=od_r - lead_in_rad_reduction, center=true);

    translate([0,0, -L/2 + lead_in_len/2])
      cylinder(h=lead_in_len + overlap, r1=od_r - lead_in_rad_reduction, r2=od_r, center=true);
  }
}

module end_chamfers_cut() {
  // Subtractive chamfers at both ends
  union() {
    translate([0,0,  L/2 - chamfer/2])
      cylinder(h=chamfer + 2*overlap, r1=od_r + overlap, r2=max(0.01, od_r - chamfer), center=true);

    translate([0,0, -L/2 + chamfer/2])
      cylinder(h=chamfer + 2*overlap, r1=max(0.01, od_r - chamfer), r2=od_r + overlap, center=true);
  }
}

module knurl_cutters() {
  // Subtractive vertical grooves around OD (serrations), within margins
  knurl_h = max(0.01, L - 2*knurl_band_margin);
  n = max(12, floor((PI*od)/knurl_pitch));

  for (i = [0:n-1]) {
    rotate([0,0, i*360/n])
      // place cutter so it bites into OD by knurl_depth
      translate([od_r - knurl_depth/2, 0, 0])
        cube([knurl_depth + 2*overlap, knurl_tooth_width, knurl_h + 2*overlap], center=true);
  }
}

module internal_bore_cut() {
  // Base bore at minor diameter (for M3 screw clearance of thread form)
  th_len = min(bore_depth, L);
  cylinder(h=th_len + 2*overlap, r=minor_r, center=true);
}

module thread_reliefs_cut() {
  // Slightly larger bore at both ends to relieve thread start/stop
  th_len = min(bore_depth, L);
  relief_r = (thread_minor_d + thread_relief_extra_d)/2;

  union() {
    translate([0,0,  th_len/2 - thread_relief_len/2])
      cylinder(h=thread_relief_len + 2*overlap, r=relief_r, center=true);

    translate([0,0, -th_len/2 + thread_relief_len/2])
      cylinder(h=thread_relief_len + 2*overlap, r=relief_r, center=true);
  }
}

module end_mark_dimple_cut() {
  translate([0,0, L/2 - end_mark_depth/2])
    cylinder(h=end_mark_depth + 2*overlap, r=end_mark_d/2, center=true);
}

// Internal helical thread cutter (triangular-ish profile) to make visible internal thread
module internal_thread_cut() {
  th_len = min(bore_depth, L);
  turns  = th_len / thread_pitch;

  // radial thread depth from major to minor
  thread_depth = max(0.10, major_r - minor_r);

  // Make a small triangular "tooth" that sweeps helically; subtract from bore
  // Positioned so its outermost point reaches major_r (thread crest), inner stays near minor_r.
  linear_extrude(
      height = th_len + 2*overlap,
      center = true,
      twist  = turns*360,
      slices = max(60, ceil(turns*120))
    )
    translate([minor_r + thread_depth*0.55, 0, 0])
      polygon(points=[
        [ thread_depth*0.55, 0 ],
        [-thread_depth*0.45,  thread_pitch*0.22],
        [-thread_depth*0.45, -thread_pitch*0.22]
      ]);
}

// ---------------- Assembly ----------------
module heat_set_insert() {
  difference() {
    // Solid body (single connected solid before cuts)
    body_base();

    // External knurl grooves
    knurl_cutters();

    // End chamfers
    end_chamfers_cut();

    // Internal features (bore + thread + reliefs)
    union() {
      internal_bore_cut();
      internal_thread_cut();
      thread_reliefs_cut();
    }

    // End marking dimple
    end_mark_dimple_cut();
  }
}

// ---------------- Output ----------------
color("Gold") heat_set_insert();