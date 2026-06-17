// Threaded heat-set insert (M4), 4.0mm OD, 6.3mm long
// One connected solid; cylindrical body with knurls; internal helical thread

$fn = 96;

// Parameters
od = 4.0;                     // outer diameter of main body
L = 6.3;                      // overall length
thread_nom_d = 4.0;           // M4 nominal
thread_pitch = 0.7;           // M4 coarse
bore_minor_d = 3.3;           // internal minor diameter (approx for M4)
thread_depth = (thread_nom_d - bore_minor_d)/2;

chamfer_len = 0.4;

flange_od = 4.8;
flange_thk = 0.6;

knurl_count = 12;
knurl_depth = 0.25;
knurl_axial_len = 4.6;
knurl_width = 0.6;
knurl_overlap = 0.6;

runout_len = 0.8;
runout_extra_d = 0.4;

mark_groove_depth = 0.15;
mark_groove_width = 0.4;
mark_groove_offset_from_top = 1.2;

eps = 0.02;

// ---------- Helpers ----------
module zcyl(h, r, center=true) { cylinder(h=h, r=r, center=center); }

module insert_outer_body() {
  // Main cylindrical body (excluding flange thickness)
  translate([0,0,-flange_thk/2])
    zcyl(h=L - flange_thk, r=od/2, center=true);
}

module installation_flange() {
  // Flange at top end
  translate([0,0,(L - flange_thk)/2])
    zcyl(h=flange_thk, r=flange_od/2, center=true);
}

module external_knurl_seed() {
  // Knurl tooth overlaps into body to ensure connectivity
  // Place tooth so its inner face is at (od/2 - knurl_overlap)
  translate([ (od/2 - knurl_overlap) + (knurl_depth + knurl_overlap)/2, 0, -flange_thk/2 ])
    cube([knurl_depth + knurl_overlap, knurl_width, knurl_axial_len], center=true);
}

module external_knurls() {
  for (i = [0:knurl_count-1])
    rotate([0,0,i*360/knurl_count])
      external_knurl_seed();
}

module surface_markings_groove() {
  // Shallow circumferential groove near top
  translate([0,0, L/2 - mark_groove_offset_from_top])
    difference() {
      zcyl(h=mark_groove_width, r=od/2 + eps, center=true);
      zcyl(h=mark_groove_width + 2*eps, r=od/2 - mark_groove_depth, center=true);
    }
}

// ---------- Internal features ----------
module lead_in_chamfer(zpos) {
  // Simple conical lead-in at each end of bore
  translate([0,0,zpos])
    cylinder(h=chamfer_len, r1=thread_nom_d/2, r2=bore_minor_d/2, center=true);
}

module internal_runout() {
  // Slightly larger unthreaded runout at bottom
  translate([0,0,-L/2 + runout_len/2])
    zcyl(h=runout_len + 2*eps, r=(bore_minor_d + runout_extra_d)/2, center=true);
}

module internal_thread(length) {
  // Helical thread approximation: subtract a twisted triangular "tooth" swept along Z
  // This creates visible internal threading suitable for rendering/printing.
  turns = length / thread_pitch;

  // Keep thread inside the insert wall
  r_root = bore_minor_d/2;
  r_crest = r_root + thread_depth;

  // 2D profile (in X-Y) placed at radius r_root; extruded with twist
  // Triangle points: root -> crest -> root (slightly offset in Y to give flank)
  profile = [
    [r_root, -thread_pitch*0.18],
    [r_crest, 0],
    [r_root,  thread_pitch*0.18]
  ];

  translate([0,0,-length/2])
    linear_extrude(height=length, twist=-360*turns, slices=max(ceil(turns*40), 60), convexity=10)
      polygon(profile);
}

module internal_bore_and_thread() {
  // Base bore (minor diameter) + thread cut + runout + chamfers
  union() {
    // Minor bore through
    zcyl(h=L + 2*eps, r=bore_minor_d/2, center=true);

    // Threaded region (avoid flange thickness and chamfers)
    thread_len = (L - flange_thk) - 2*chamfer_len;
    translate([0,0,-flange_thk/2])  // align with main body center
      internal_thread(thread_len);

    internal_runout();

    // Chamfers at both ends
    lead_in_chamfer( L/2 - chamfer_len/2);
    lead_in_chamfer(-L/2 + chamfer_len/2);
  }
}

// ---------- Final model ----------
module final_insert() {
  difference() {
    // Outer solid (connected)
    difference() {
      union() {
        insert_outer_body();
        installation_flange();
        external_knurls();
      }
      surface_markings_groove();
    }

    // Subtract internal bore + thread
    internal_bore_and_thread();
  }
}

final_insert();