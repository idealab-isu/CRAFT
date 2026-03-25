// Dimension-calibrated (target: 0.06 x 0.04 x 0.05 mm)
scale([0.001067, 0.001325, 0.000800])
{
// Wedge-ended rectangular block with integrated U-shaped clevis/handle and through cutout
// Structural fix: make a clear clevis with TWO PARALLEL FORK ARMS (in Y), open U-channel at X+,
// plus a recognizable THROUGH cutout in the clevis loop region. All parts connected with overlaps.

// ---------- Parameters (mm) ----------
L = 60;                 // overall length (X)
W = 40;                 // overall width  (Y)
H = 50;                 // overall height (Z)

wedge_L = 18;           // length of wedge tip (X)
wedge_tip_W = 4;        // width at very tip (Y)

clevis_L = 16;          // length of clevis region (X)
channel_depth = 12;     // depth of U-channel cut from end (X)

channel_W = 16;         // inner slot width between fork arms (Y)

cutout_r = 9;           // half-width of arched/polygonal cutout (in XZ profile)
cutout_H = 22;          // height of cutout profile (Z)

blend_L = 6;            // overlap/blend length between body and clevis (X)

eps = 0.2;              // boolean robustness
overlap = 1.5;          // intentional overlap for solid connections (1-2mm)
fillet_r = 0;           // keep 0 to preserve clevis details

$fn = 48;

// ---------- Derived ----------
x_min = -L/2;
x_max =  L/2;

x_wedge_start = x_min;
x_wedge_end   = x_min + wedge_L;

x_body_start  = x_wedge_end;
x_body_end    = x_max - clevis_L;

x_clevis_start = x_body_end;
x_clevis_end   = x_max;

// Fork thickness derived, clamped for robustness
fork_wall = (W - channel_W)/2;
fork_wall = (fork_wall < 1) ? 1 : fork_wall;                 // ensure visible arms
channel_W_eff = W - 2*fork_wall;                              // actual slot width
channel_W_eff = (channel_W_eff < 1) ? 1 : channel_W_eff;

// Keep the through-cutout inside the "closed" part of the clevis (not inside the open slot)
cutout_x_center = x_clevis_start + (clevis_L - channel_depth) * 0.55;
cutout_x_center = (cutout_x_center < (x_clevis_start + 1)) ? (x_clevis_start + 1) : cutout_x_center;
cutout_x_center = (cutout_x_center > (x_max - channel_depth - 1)) ? (x_max - channel_depth - 1) : cutout_x_center;

module wedge_solid() {
  // Linear taper in Y from full W at x_wedge_end to wedge_tip_W at x_wedge_start; constant Z=H.
  polyhedron(
    points=[
      // x = x_wedge_start (tip)
      [x_wedge_start, -wedge_tip_W/2, -H/2],
      [x_wedge_start,  wedge_tip_W/2, -H/2],
      [x_wedge_start,  wedge_tip_W/2,  H/2],
      [x_wedge_start, -wedge_tip_W/2,  H/2],

      // x = x_wedge_end (full width)
      [x_wedge_end, -W/2, -H/2],
      [x_wedge_end,  W/2, -H/2],
      [x_wedge_end,  W/2,  H/2],
      [x_wedge_end, -W/2,  H/2]
    ],
    faces=[
      [0,1,2,3],
      [4,7,6,5],
      [0,4,5,1],
      [1,5,6,2],
      [2,6,7,3],
      [3,7,4,0]
    ]
  );
}

module main_body_block() {
  translate([(x_body_start + x_body_end)/2, 0, 0])
    cube([ (x_body_end - x_body_start), W, H ], center=true);
}

module clevis_outer_block() {
  // Outer volume for clevis; overlaps into body for connectivity.
  // Recalculated so the clevis overlaps the body by `overlap` at x_clevis_start.
  clevis_len = (x_clevis_end - x_clevis_start) + overlap;
  clevis_center_x = x_clevis_start + clevis_len/2 - overlap; // ensures overlap into body
  translate([clevis_center_x, 0, 0])
    cube([ clevis_len, W, H ], center=true);
}

module u_channel_cut_y() {
  // Cut a U-channel OPEN at X+ that creates TWO PARALLEL FORK ARMS in Y.
  // Remove the center slot in Y across full Z, only in the last `channel_depth` of the clevis.
  x0 = x_max - channel_depth;
  x1 = x_max + eps; // open end

  translate([(x0 + x1)/2, 0, 0])
    cube([ (x1 - x0), channel_W_eff + 2*eps, H + 2*eps ], center=true);
}

module loop_through_cutout() {
  // Through-opening across Y in the clevis loop region (in the "closed" section),
  // so it reads as a true through-hole in the clevis/handle.
  translate([cutout_x_center, 0, 0])
    rotate([90, 0, 0])
      linear_extrude(height=W + 2*eps, center=true)
        polygon(points=[
          [-cutout_r, -cutout_H/2],
          [ cutout_r, -cutout_H/2],
          [ cutout_r,  cutout_H/2 - cutout_r],
          [ 0,         cutout_H/2],
          [-cutout_r,  cutout_H/2 - cutout_r]
        ]);
}

module core() {
  union() {
    wedge_solid();
    main_body_block();

    // Ensure wedge-body connection (overlap slab at the interface)
    translate([x_wedge_end + overlap/2, 0, 0])
      cube([overlap, W, H], center=true);

    // Clevis outer volume (connected)
    clevis_outer_block();

    // Blend/overlap between body and clevis to keep silhouette continuous
    // Recalculated to straddle x_clevis_start with overlap.
    translate([x_clevis_start - blend_L/2 + overlap/2, 0, 0])
      cube([blend_L + overlap, W, H], center=true);
  }
}

module final_shape() {
  difference() {
    core();

    // Create the clevis U-channel (fork arms in Y)
    u_channel_cut_y();

    // Add through cutout in the loop region (through Y)
    loop_through_cutout();
  }
}

// Optional fillet (disabled by default)
if (fillet_r > 0)
  minkowski() { final_shape(); sphere(r=fillet_r, $fn=24); }
else
  final_shape();
}
