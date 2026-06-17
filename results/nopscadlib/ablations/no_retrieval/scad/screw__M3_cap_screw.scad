// Socket Head Cap Screw (M3-ish) — 3.0mm shank dia, 5.5mm head dia, 3.0mm head height, 10mm overall length

$fn = 96;

// Parameters (mm)
shank_d        = 3.0;
overall_L      = 10.0;   // total length including head
head_d         = 5.5;
head_h         = 3.0;

socket_hex_af  = 2.5;    // across flats
socket_depth   = 2.0;

underhead_fillet_r = 0.25;
head_top_chamfer_h = 0.25;

thread_pitch   = 0.5;    // visual thread
thread_depth   = 0.18;   // radial depth
thread_len     = overall_L - head_h; // threaded length (full shank)

tip_chamfer_h  = 0.4;

eps = 0.02;

// Helpers
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for regular hex with given across-flats

module hex_prism_af(af, h, center=false) {
  r = hex_R_from_AF(af);
  linear_extrude(height=h, center=center)
    polygon([for (i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

// Place head on top of shank: head spans z=[0, head_h], shank spans z=[-thread_len, 0]
module head_solid() {
  // Cylindrical head with slight top chamfer and small underhead fillet
  union() {
    // Main head cylinder
    cylinder(h=head_h, r=head_d/2);

    // Top chamfer (subtract later via difference in final head module)
    // Underhead fillet (adds a small torus-like blend)
    translate([0,0,0])
      rotate_extrude()
        translate([head_d/2 - underhead_fillet_r, 0, 0])
          circle(r=underhead_fillet_r);
  }
}

module head_with_features() {
  difference() {
    head_solid();

    // Top chamfer cut
    translate([0,0,head_h - head_top_chamfer_h])
      cylinder(h=head_top_chamfer_h + eps, r1=head_d/2, r2=max(0.01, head_d/2 - head_top_chamfer_h));

    // Internal hex socket recess (from top)
    translate([0,0,head_h - socket_depth])
      hex_prism_af(socket_hex_af, socket_depth + eps, center=false);
  }
}

module shank_core() {
  // Cylindrical shank (minor diameter core for thread to sit on)
  // Minor diameter approximated as shank_d - 2*thread_depth
  minor_d = max(0.2, shank_d - 2*thread_depth);
  translate([0,0,-thread_len])
    cylinder(h=thread_len, r=minor_d/2);
}

module helical_thread() {
  // Simple visual external thread using linear_extrude with twist
  // Cross-section is a small triangular "tooth" placed at minor radius.
  minor_r = max(0.1, (shank_d/2) - thread_depth);
  turns = thread_len / thread_pitch;
  tooth_w = 0.45 * thread_pitch; // along Z in the extrude direction (2D Y)
  tooth_h = thread_depth;        // radial height (2D X)

  translate([0,0,-thread_len])
    linear_extrude(height=thread_len, twist=turns*360, slices=max(ceil(turns*24), 60), convexity=10)
      translate([minor_r, 0])
        polygon(points=[
          [0, -tooth_w/2],
          [tooth_h, 0],
          [0,  tooth_w/2]
        ]);
}

module tip_chamfer() {
  // Chamfer at the very end of the screw
  translate([0,0,-thread_len])
    cylinder(h=tip_chamfer_h, r1=shank_d/2, r2=max(0.01, shank_d/2 - thread_depth));
}

module screw() {
  union() {
    // Head (z=0..head_h)
    head_with_features();

    // Shank + thread (z=-thread_len..0) with slight overlap into head for watertight union
    union() {
      translate([0,0,-eps]) cylinder(h=eps, r=shank_d/2); // tiny overlap disk into head
      translate([0,0,-thread_len]) cylinder(h=thread_len, r=shank_d/2); // major diameter envelope
      shank_core();
      helical_thread();
      tip_chamfer();
    }
  }
}

color("DimGray") screw();