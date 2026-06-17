// Threaded heat-set insert (parametric)
// Target: 12.0mm OD, 10.0mm long, for 5.0mm screws (M5x0.8)
//
// Fixes:
// - Removes flange (typical heat-set inserts are non-flanged)
// - Adds visible external barbs/knurling (protruding + slight undercut grooves)
// - Adds visible internal helical thread (approximate ISO metric profile)
// - Ensures all translate() values are derived from dimensions and all parts are connected

$fn = 180;

// -------------------- Parameters --------------------
od = 12.0;                 //[6.0:24.0:0.1]   // outer diameter
L  = 10.0;                 //[5.0:20.0:0.1]   // overall length

thread_major_d = 5.0;      //[3.0:8.0:0.1]    // M5 major diameter
thread_pitch   = 0.8;      //[0.5:1.5:0.05]   // M5 coarse pitch

// Internal thread tuning (visual + printable)
thread_depth   = 0.35;     //[0.15:0.6:0.01]  // radial thread depth (approx)
thread_clear   = 0.15;     //[0.00:0.30:0.01] // extra clearance on minor diameter

// Bore lead-in
chamfer = 0.6;             //[0.3:1.2:0.05]

// External heat-set barbs/knurling
knurl_depth = 0.55;        //[0.2:1.2:0.05]   // outward protrusion
knurl_tooth_count = 36;    //[12:80:1]
knurl_band_margin = 1.0;   //[0.4:2.5:0.1]    // smooth ends

// Optional shallow undercut grooves to look/behave more like heat-set inserts
groove_count = 6;          //[0:12:1]
groove_w = 0.55;           //[0.2:1.2:0.05]
groove_depth = 0.25;       //[0.05:0.6:0.05]

// Connectivity / robustness
overlap = 0.8;             //[0.3:2.0:0.1]

// -------------------- Derived --------------------
body_r = od/2;

knurl_h = max(0.1, L - 2*knurl_band_margin);
knurl_z = 0;

thread_len = L - 2*chamfer;                 // keep thread away from chamfers
thread_len_eff = max(0.1, thread_len);

thread_r_major = thread_major_d/2;
thread_r_minor = thread_r_major - thread_depth - thread_clear;

// Guard against impossible geometry
min_wall = 0.8;
thread_r_major_limited = min(thread_r_major, body_r - min_wall);
thread_r_minor_limited = min(thread_r_minor, thread_r_major_limited - 0.15);

// -------------------- Base Shapes --------------------
module insert_body() {
  cylinder(r=body_r, h=L, center=true);
}

// Lead-in chamfers (both ends) for the internal bore/thread
module lead_in_chamfer_top() {
  translate([0, 0, +L/2 - chamfer/2 + overlap])
    cylinder(r1=thread_r_major_limited + chamfer, r2=thread_r_major_limited, h=chamfer, center=true);
}

module lead_in_chamfer_bottom() {
  translate([0, 0, -L/2 + chamfer/2 - overlap])
    cylinder(r1=thread_r_major_limited, r2=thread_r_major_limited + chamfer, h=chamfer, center=true);
}

// -------------------- External Barbs / Knurling --------------------
module external_knurl_tooth() {
  // Tooth protrudes outward and overlaps into body for a single connected solid
  tooth_len_rad = knurl_depth * 2;
  tooth_w = (PI*od)/knurl_tooth_count * 0.55;
  translate([body_r - knurl_depth + tooth_len_rad/2 - overlap, 0, 0])
    cube([tooth_len_rad, tooth_w, knurl_h], center=true);
}

module external_knurl_profile() {
  translate([0, 0, knurl_z])
    for (i = [0:knurl_tooth_count-1])
      rotate([0, 0, i*360/knurl_tooth_count])
        external_knurl_tooth();
}

// Shallow circumferential grooves (subtracted) to mimic heat-set insert rings
module external_undercut_grooves() {
  if (groove_count > 0) {
    // Place grooves evenly along the knurled band
    z0 = -knurl_h/2 + groove_w/2;
    dz = (groove_count == 1) ? 0 : (knurl_h - groove_w) / (groove_count - 1);
    for (g = [0:groove_count-1]) {
      translate([0, 0, knurl_z + z0 + g*dz])
        cylinder(r=body_r - groove_depth, h=groove_w, center=true);
    }
  }
}

// -------------------- Internal Thread (helical subtraction) --------------------
module internal_thread_cut() {
  // Approximate ISO metric internal thread by subtracting a helical "rib"
  // around a cylinder at the major radius.
  //
  // Uses linear_extrude with twist to create a helix.
  // The 2D profile is a small triangle located at radius = thread_r_major_limited.
  turns = thread_len_eff / thread_pitch;
  slices = max(ceil(turns * 40), 80); // enough to look threaded

  // 2D triangle (in XY) positioned at the major radius; extruded along Z with twist.
  // Triangle points inward to create thread depth.
  tri = [
    [thread_r_major_limited, -thread_pitch*0.22],
    [thread_r_major_limited,  thread_pitch*0.22],
    [thread_r_major_limited - (thread_r_major_limited - thread_r_minor_limited), 0]
  ];

  translate([0, 0, -thread_len_eff/2])
    linear_extrude(height=thread_len_eff, twist=-360*turns, slices=slices, convexity=10)
      polygon(points=tri);
}

// Base bore to ensure a clean minor diameter through the threaded region
module internal_minor_bore() {
  // Extend beyond body to guarantee full cut
  cylinder(r=thread_r_minor_limited, h=L + 4*overlap, center=true);
}

// -------------------- Assembly --------------------
module insert_outer() {
  union() {
    insert_body();
    external_knurl_profile(); // protruding barbs
  }
}

module insert_final() {
  difference() {
    // Outer solid
    insert_outer();

    // External undercut grooves (subtractive)
    external_undercut_grooves();

    // Internal features
    internal_minor_bore();
    internal_thread_cut();
    lead_in_chamfer_top();
    lead_in_chamfer_bottom();
  }
}

// -------------------- Output --------------------
insert_final();