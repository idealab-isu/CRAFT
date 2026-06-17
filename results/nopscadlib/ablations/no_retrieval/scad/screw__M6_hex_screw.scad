// Hex head screw (simplified) — 6.0mm major diameter, 11.5mm head AF, head height 4.15mm, 10mm under-head length
// Structural fixes: ensure correct proportions, connected solids, and clearly visible helical threads.

$fn = 96;

// ---------- Parameters ----------
shank_d = 6.0;                 // major diameter
shank_L = 10.0;                // length from under-head to tip (z=0 to z=-shank_L)
head_af = 11.5;                // across flats
head_h = 4.15;                 // head height (z=0 to z=+head_h)

tip_chamfer_h = 0.8;
tip_chamfer_d_reduction = 1.0;

thread_pitch = 1.0;
thread_depth = 0.45;           // slightly deeper so it reads as a screw in silhouette
thread_length = 9.2;           // keep most of the 10mm shank threaded (simple screw look)

underhead_fillet_r = 0.6;

head_top_chamfer_h = 0.6;
head_top_chamfer_inset = 0.8;

drive_mark_r = 0.6;
drive_mark_depth = 0.25;
drive_mark_offset = 2.2;

overlap = 1.2;                 // robust unions (1–2mm)

// ---------- Derived ----------
head_R = (head_af/2) / cos(30);                 // circumradius for hex (AF -> R)
thread_len_eff = max(0, min(thread_length, shank_L - tip_chamfer_h));  // do not run into chamfer
thread_turns = max(1, thread_len_eff / thread_pitch);

// Coordinate convention:
// z=0 at under-head plane; shank goes to negative z; head goes to positive z.

// ---------- Helpers ----------
module hex_prism(af, h, center=false) {
  R = (af/2) / cos(30);
  linear_extrude(height=h, center=center)
    polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// ---------- Parts ----------
module shank_core() {
  // Exact under-head length: z from 0 down to -shank_L
  translate([0,0,-shank_L/2])
    cylinder(h=shank_L, r=shank_d/2, center=true);
}

module tip_chamfer() {
  // Chamfer occupies the last tip_chamfer_h of the shank: z in [-shank_L, -shank_L+tip_chamfer_h]
  translate([0,0,-shank_L + tip_chamfer_h/2])
    cylinder(h=tip_chamfer_h,
             r1=(shank_d - tip_chamfer_d_reduction)/2,
             r2=shank_d/2,
             center=true);
}

module underhead_fillet() {
  // Torus-like fillet centered at z=0 so it intersects both head (z>=0) and shank (z<=0)
  // (rotate_extrude creates a ring in the XY plane around Z)
  translate([0,0,0])
    rotate_extrude()
      translate([shank_d/2 + underhead_fillet_r, 0])
        circle(r=underhead_fillet_r);
}

module hex_head() {
  // Head sits on z=0 plane and extends to +head_h
  translate([0,0,head_h/2])
    hex_prism(head_af, head_h, center=true);
}

module head_top_chamfer_cut() {
  // Subtractive chamfer on top of head; positioned to only affect the top region
  translate([0,0,head_h - head_top_chamfer_h/2 + overlap/2])
    cylinder(h=head_top_chamfer_h + overlap,
             r1=head_R + overlap,
             r2=max(0.01, head_R - head_top_chamfer_inset),
             center=true);
}

module drive_marks_cut() {
  // Shallow circular marks on top face (subtractive)
  zc = head_h - drive_mark_depth/2 + overlap/2;
  for (p = [[ drive_mark_offset, 0],
            [-drive_mark_offset, 0],
            [0,  drive_mark_offset]]) {
    translate([p[0], p[1], zc])
      cylinder(h=drive_mark_depth + overlap, r=drive_mark_r, center=true);
  }
}

module helical_thread_ridge() {
  // Clear, simple helical ridge around the shank to read as "threaded"
  // Built as a twisted extrusion of a small rectangle placed near the shank surface.
  rib_rad = thread_depth;                 // radial thickness of ridge
  rib_ax  = thread_pitch * 0.55;          // axial thickness of ridge section
  r0 = shank_d/2 - rib_rad/2;             // center of rib near shank surface

  // Start at the tip (z=-shank_L) and run upward, stopping before the chamfer region.
  // Add overlap so it fuses into the shank and doesn't leave a gap at either end.
  translate([0,0,-shank_L - overlap/2])
    linear_extrude(height=thread_len_eff + overlap,
                   twist=360*thread_turns,
                   slices=max(ceil(28*thread_turns), 24))
      translate([r0, 0, 0])
        square([rib_rad, rib_ax], center=true);
}

// ---------- Assembly ----------
module screw() {
  difference() {
    union() {
      // Main solids (all connected)
      shank_core();
      tip_chamfer();
      hex_head();
      underhead_fillet();

      // Visible thread feature (intersects shank for a single solid)
      if (thread_len_eff > 0)
        helical_thread_ridge();
    }

    // Subtractive details on head
    head_top_chamfer_cut();
    drive_marks_cut();
  }
}

// ---------- Output ----------
screw();