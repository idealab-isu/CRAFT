// Socket Head Cap Screw (M2-like) — 2.0mm shank dia, 3.8mm head dia, 10mm overall length
// One connected solid, cylindrical head with internal hex socket, cylindrical shank with simple helical thread.

$fn = 96;

// -------- Parameters (mm) --------
shank_d        = 2.0;   // major diameter
overall_L      = 10.0;  // total length (top of head to tip)
head_d         = 3.8;   // head diameter
head_h         = 2.0;   // head height

// Socket (internal hex)
socket_af      = 1.5;   // across flats
socket_depth   = 1.2;   // depth from top face

// Thread (simple helical approximation)
thread_L       = 8.0;   // threaded length from tip upward
pitch          = 0.4;   // thread pitch
thread_h       = 0.18;  // radial thread height (visual)
thread_profile_w = 0.22; // profile width (visual)

// Small overlaps to ensure watertight unions/differences
eps            = 0.02;
overlap        = 0.15;

// Derived
shank_L = overall_L - head_h;
head_z0 = 0;                 // head bottom at z=0
head_z1 = head_h;            // head top at z=head_h
shank_z0 = -shank_L;         // shank bottom at z=-shank_L
shank_z1 = 0;                // shank top meets head bottom at z=0

thread_z0 = shank_z0;                         // start at tip
thread_z1 = max(shank_z0, shank_z0 + thread_L); // end upward
thread_len = thread_z1 - thread_z0;

// -------- Helpers --------
module hex_prism_af(af, h, center=false) {
  // Regular hex with given across-flats (af)
  // For a regular hex, across-flats = 2 * apothem; apothem = r*cos(30) => r = af / sqrt(3)
  r = af / sqrt(3);
  cylinder(r=r, h=h, $fn=6, center=center);
}

// -------- Geometry --------
module head_cyl() {
  // Cylindrical socket head
  translate([0,0,head_z0])
    cylinder(d=head_d, h=head_h, center=false);
}

module shank_cyl() {
  // Cylindrical shank (minor diameter base for thread)
  translate([0,0,shank_z0])
    cylinder(d=shank_d - 2*thread_h, h=shank_L, center=false);
}

module thread_helix() {
  // Simple helical ridge around the shank (visual thread)
  // Uses linear_extrude with twist; profile is a small rectangle at radius.
  if (thread_len > 0) {
    turns = thread_len / pitch;
    translate([0,0,thread_z0])
      linear_extrude(height=thread_len, twist=turns*360, slices=max(ceil(turns*40), 40), center=false)
        translate([ (shank_d/2 - thread_h) + thread_h/2, 0, 0 ])
          square([thread_h, thread_profile_w], center=true);
  }
}

module tip_chamfer() {
  // Small chamfer at tip for nicer end
  cham_h = 0.35;
  translate([0,0,shank_z0 - eps])
    cylinder(h=cham_h + eps, r1=(shank_d/2 - thread_h), r2=max((shank_d/2 - thread_h) - 0.25, 0.2), center=false);
}

module socket_recess() {
  // Internal hex socket cut from the top face downward
  translate([0,0,head_z1 - socket_depth - overlap])
    hex_prism_af(socket_af, socket_depth + overlap + eps, center=false);
}

module screw_solid() {
  union() {
    // Ensure head and shank are connected (share plane at z=0) with slight overlap
    union() {
      head_cyl();
      translate([0,0, -overlap]) shank_cyl();
    }

    // Add thread ridge (union) and a small tip chamfer
    thread_helix();
    tip_chamfer();
  }
}

// -------- Final --------
difference() {
  screw_solid();
  socket_recess();
}