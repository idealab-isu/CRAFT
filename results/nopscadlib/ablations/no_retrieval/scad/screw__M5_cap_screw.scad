// Socket Head Cap Screw (M5-ish, simplified visual thread)
// Target: shank Ø5.0, head Ø8.5, head height 5.0, length under-head 10.0

$fn = 128;

// -------------------- Parameters (mm) --------------------
shank_d = 5.0;
length  = 10.0;          // UNDER-HEAD length (requested)

head_d  = 8.5;
head_h  = 5.0;

socket_hex_af = 4.0;     // across flats (visual)
socket_depth  = 3.0;     // depth from top face

// Visual thread approximation (kept within shank length)
thread_pitch   = 0.8;
thread_depth   = 0.30;   // radial height of ridge
thread_runout  = 1.0;    // smooth near head

// Details
tip_chamfer_h       = 0.8;
head_top_chamfer_h  = 0.4;

// Overlap to guarantee watertight unions/differences (also satisfies 1–2mm overlap intent)
overlap = 1.0;
eps = 0.03;

// -------------------- Derived --------------------
shank_r = shank_d/2;
head_r  = head_d/2;

// Coordinate system: tip at z=0, under-head plane at z=length, head above that
z_tip       = 0;
z_head_bot  = length;            // under-head plane
z_head_top  = length + head_h;   // top of head

// Thread extents: from tip up to just below head (leave runout)
z_thread_start = z_tip;
z_thread_end   = max(z_thread_start, length - thread_runout);

// -------------------- Helpers --------------------
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for hex with across-flats = af

module hex_prism_af(af, h) {
  R = hex_R_from_AF(af);
  linear_extrude(height=h, center=false)
    polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// Helical ridge wrapped around the shank surface (visual only)
module helical_thread_ridge(r_base, depth, pitch, len) {
  turns = len / pitch;
  linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*80), 40), convexity=10)
    translate([r_base - depth, 0, 0])
      polygon(points=[
        [0, -pitch*0.18],
        [depth, 0],
        [0,  pitch*0.18]
      ]);
}

module screw_solid() {
  union() {
    // Shank (smooth core) - under-head length is exactly "length"
    cylinder(r=shank_r, h=length);

    // Tip chamfer (at z=0), overlaps into shank for solid connection
    cylinder(r1=max(shank_r - 0.6, 0.01), r2=shank_r, h=tip_chamfer_h + eps);

    // Head (cylindrical) - starts at under-head plane
    translate([0,0,z_head_bot - eps])
      cylinder(r=head_r, h=head_h + eps);

    // Head top chamfer
    translate([0,0,z_head_top - head_top_chamfer_h])
      cylinder(r1=head_r, r2=max(head_r - head_top_chamfer_h, 0.01), h=head_top_chamfer_h + eps);

    // Under-head transition (ensures clean connection with overlap)
    hull() {
      translate([0,0,z_head_bot - overlap])
        cylinder(r=shank_r, h=overlap);
      translate([0,0,z_head_bot - eps])
        cylinder(r=head_r, h=eps);
    }

    // Thread ridges (additive, for visibility) - extend up to runout below head
    if (z_thread_end > z_thread_start + eps)
      translate([0,0,z_thread_start])
        helical_thread_ridge(shank_r, thread_depth, thread_pitch, z_thread_end - z_thread_start);
  }
}

module socket_cut() {
  // Hex socket cut from top face downward; extend slightly for clean boolean
  translate([0,0,z_head_top - socket_depth - eps])
    hex_prism_af(socket_hex_af, socket_depth + 2*eps);
}

difference() {
  screw_solid();
  socket_cut();
}