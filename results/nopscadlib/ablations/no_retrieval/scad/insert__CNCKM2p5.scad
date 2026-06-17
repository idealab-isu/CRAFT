// Threaded heat-set insert (simple cylinder)
// Spec: 4.0mm outer diameter, 4.6mm long, for M2.5 screws
// One connected solid, no flange/countersink head.

$fn = 128;

// --- Parameters (spec) ---
od = 4.0;                 // outer diameter (mm)
L  = 4.6;                 // length (mm)

// M2.5 internal thread (visual approximation)
thread_pitch = 0.45;      // M2.5 coarse pitch (mm)
minor_d = 2.05;           // approximate minor diameter / tap drill (mm)

// Small lead-in chamfers (not a head/flange)
end_chamfer = 0.15;       // mm (kept small to avoid "countersunk head" look)

// Visual thread controls
show_internal_thread = true;
thread_depth = 0.18;      // radial depth of visual thread (mm)
thread_profile_w = 0.22;  // thickness of visual thread ridge (mm)

// Robust boolean overlap
eps = 0.02;

// --- Helpers ---
function clamp(x,a,b) = min(max(x,a),b);

// Outer body: simple cylinder with tiny end chamfers
module outer_body() {
  ch = clamp(end_chamfer, 0, L/2 - eps);

  union() {
    // Main cylinder
    cylinder(h=L, r=od/2, center=true);

    // Tiny chamfer at top (subtract later via intersection-like add? easier: add small frustum)
    // Here we "shape" by adding frustums that do not exceed OD (no flange).
    if (ch > 0) {
      translate([0,0, L/2 - ch/2])
        cylinder(h=ch, r1=od/2 - ch, r2=od/2, center=true);
      translate([0,0,-L/2 + ch/2])
        cylinder(h=ch, r1=od/2, r2=od/2 - ch, center=true);
    }
  }
}

// Internal bore (minor diameter) through
module internal_bore() {
  cylinder(h=L + 2*eps, r=minor_d/2, center=true);
}

// Visual internal thread: subtract a helical ridge from the bore
module internal_thread_visual() {
  r_bore = minor_d/2;
  r_thread = max(0.01, r_bore - thread_depth);

  // Keep thread away from ends a bit
  z0 = -L/2 + end_chamfer + 0.10;
  z1 =  L/2 - end_chamfer - 0.10;
  th = max(0, z1 - z0);

  if (th > 0) {
    translate([0,0,z0])
      linear_extrude(
        height = th,
        twist  = -360 * (th / thread_pitch),
        slices = max(60, ceil(th / (thread_pitch/16)))
      )
        translate([r_thread, 0, 0])
          square([thread_profile_w, thread_profile_w], center=true);
  }
}

// Final model
difference() {
  outer_body();
  internal_bore();
  if (show_internal_thread) internal_thread_visual();
}