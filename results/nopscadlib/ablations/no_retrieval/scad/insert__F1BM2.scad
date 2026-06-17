// Threaded heat-set insert (simplified geometry)
// Target: 4.0mm OD, 3.6mm length, for 2.0mm screws

$fn = 96;

// Parameters
od = 4.0;                     // outer diameter of main body
L  = 3.6;                     // overall length (including any flange if enabled)

screw_size = 2.0;             // nominal screw size (M2)
id_thread_major = 2.0;        // major diameter of internal thread (visual/clearance)
id_thread_minor = 1.6;        // minor diameter (tap drill-ish)
thread_pitch = 0.4;           // not modeled as helical thread here
thread_length = 3.6;          // make bore go through full length for visibility/fit

chamfer = 0.3;                // lead-in chamfer length (each end)

knurl_depth = 0.25;           // radial protrusion beyond OD
knurl_ridge_width = 0.3;      // tangential width of each ridge
knurl_ridge_height = 2.8;     // axial height of ridges
knurl_count = 20;

overlap = 0.2;                // small overlap to ensure watertight unions/differences

// Optional flange (kept OFF by default to preserve 4.0mm OD and 3.6mm length spec)
flange_thickness = 0.4;
flange_od = 4.6;
use_flange = false;

// Derived
body_r = od/2;
knurl_r = body_r + knurl_depth;

// Base shapes
module insert_body_cylinder() {
  cylinder(h=L, r=body_r, center=true);
}

module top_flange() {
  // If enabled, flange is included within overall length L (no extra length added)
  translate([0,0, L/2 - flange_thickness/2])
    cylinder(h=flange_thickness, r=flange_od/2, center=true);
}

module knurl_ridge_0() {
  // Ridge protrudes outward from OD and overlaps into body for connectivity
  translate([body_r + knurl_depth/2 - overlap/2, 0, 0])
    cube([knurl_depth + overlap, knurl_ridge_width, knurl_ridge_height], center=true);
}

module external_knurl_ridges() {
  union() {
    for (i = [0:knurl_count-1]) {
      rotate([0,0, i*360/knurl_count])
        knurl_ridge_0();
    }
  }
}

module internal_bore_through() {
  // Through-hole so it is visible in all orthographic views
  cylinder(h=L + 2*overlap, r=id_thread_minor/2, center=true);
}

module lead_in_chamfer_top() {
  // Conical lead-in at top end (subtract)
  translate([0,0, L/2 - chamfer/2])
    cylinder(h=chamfer + overlap, r1=id_thread_major/2, r2=id_thread_minor/2, center=true);
}

module lead_in_chamfer_bottom() {
  // Conical lead-in at bottom end (subtract)
  translate([0,0, -L/2 + chamfer/2])
    cylinder(h=chamfer + overlap, r1=id_thread_minor/2, r2=id_thread_major/2, center=true);
}

// Final assembly
module insert_model() {
  difference() {
    union() {
      insert_body_cylinder();
      external_knurl_ridges();
      if (use_flange) top_flange();
    }
    internal_bore_through();
    lead_in_chamfer_top();
    lead_in_chamfer_bottom();
  }
}

// Render
color([0.8, 0.6, 0.2])
insert_model();