// Pan head screw — 3.0mm shank dia, 5.4mm head dia, 2.0mm head height, 10mm overall length
// One connected solid, oriented along +Z, tip at z=0, head top at z=screw_L.

$fn = 128;

// Parameters (mm)
shank_d   = 3.0;
screw_L   = 10.0;

head_d    = 5.4;
head_h    = 2.0;

thread_pitch      = 0.5;
thread_length     = 8.0;     // from tip upward
thread_major_d    = shank_d;
thread_minor_d    = 2.7;     // visual approximation
thread_profile_w  = 0.28;    // axial thickness of ridge

drive_recess_d     = 2.2;
drive_recess_depth = 1.2;
drive_slot_w       = 0.55;
drive_slot_len     = 2.6;

tip_chamfer_h = 0.6;

// Use a real overlap (1–2mm) for robust connectivity as requested
overlap = 1.2;
eps     = 0.02;

// Derived
head_base_z = screw_L - head_h;          // underside of head
shank_h     = screw_L - head_h;          // length below head
thread_z0   = 0;
thread_z1   = min(thread_length, shank_h);

// --- Pan head (rounded top + near-vertical sides) ---
// Build as: cylindrical skirt + spherical-cap crown, then a small under-head blend.
// This avoids the previous rotate_extrude profile that produced a cone-like silhouette.
module pan_head() {
  r = head_d/2;
  z0 = head_base_z;
  zt = screw_L;

  // Keep a clear cylindrical skirt so it reads as a pan head (not countersunk)
  skirt_h = head_h * 0.55;               // ~1.1mm
  crown_h = head_h - skirt_h;            // remaining height
  z_skirt_top = z0 + skirt_h;

  // Spherical cap that meets the skirt at radius r and rises crown_h to the top.
  // Sphere radius for cap: R = (a^2 + h^2) / (2h), where a=r, h=crown_h
  // Sphere center is on axis at zc = zt - R.
  R  = (r*r + crown_h*crown_h) / (2*crown_h);
  zc = zt - R;

  union() {
    // Cylindrical skirt
    translate([0,0, z0 - overlap/2])
      cylinder(h=skirt_h + overlap, r=r, center=false);

    // Crown (spherical cap), clipped to only the cap region
    intersection() {
      translate([0,0, zc])
        sphere(r=R);
      translate([0,0, z_skirt_top - overlap/2])
        cylinder(h=crown_h + overlap, r=r + 0.5, center=false);
    }

    // Under-head blend to shank (ensures strong connection and avoids a sharp step)
    blend_h = 0.6;
    translate([0,0, z0 - blend_h + overlap/2])
      cylinder(h=blend_h + overlap, r1=r, r2=thread_major_d/2, center=false);
  }
}

module shank_core() {
  // Core at minor diameter so thread ridge is visible; extends to underside of head with overlap.
  translate([0,0, (shank_h + overlap)/2])
    cylinder(h=shank_h + overlap, r=thread_minor_d/2, center=true);
}

module tip_chamfer() {
  // Chamfer at tip, connected to shank core
  translate([0,0, tip_chamfer_h/2])
    cylinder(h=tip_chamfer_h, r1=thread_major_d/2, r2=thread_minor_d/2, center=true);
}

module helical_thread() {
  // Visual thread ridge swept helically around the core from z=thread_z0 to z=thread_z1.
  turns = (thread_z1 - thread_z0) / thread_pitch;
  steps_per_turn = 28;
  steps = max(8, ceil(turns * steps_per_turn));

  ridge_rad = thread_minor_d/2;                 // start at core surface
  ridge_h   = (thread_major_d - thread_minor_d)/2;

  // Slightly extend into the head region to guarantee union with the shank/head blend
  z_start = thread_z0;
  z_end   = min(thread_z1 + overlap, shank_h + overlap);

  translate([0,0, z_start])
    linear_extrude(height=(z_end - z_start), twist=360*turns*( (z_end-z_start)/(thread_z1-thread_z0 + eps) ),
                  slices=steps, convexity=10)
      translate([ridge_rad + ridge_h/2, 0, 0])  // protrude outward from core
        square([ridge_h, thread_profile_w], center=true);
}

module phillips_recess() {
  // Cut from head top downward
  recess_zc = screw_L - drive_recess_depth/2 + overlap/2;

  union() {
    translate([0,0, recess_zc])
      cylinder(h=drive_recess_depth + overlap, r=drive_recess_d/2, center=true);

    for (a = [0, 90]) {
      rotate([0,0,a])
        translate([0,0, recess_zc])
          cube([drive_slot_len, drive_slot_w, drive_recess_depth + overlap], center=true);
    }
  }
}

module screw() {
  difference() {
    union() {
      // Shank + threads + tip
      union() {
        shank_core();
        helical_thread();
        tip_chamfer();
      }

      // Pan head (connected at head_base_z to shank via blend + overlaps)
      pan_head();
    }

    // Drive recess
    phillips_recess();

    // Tiny top flatten to avoid coincident surfaces
    translate([0,0, screw_L + 0.15])
      cube([head_d*2, head_d*2, 0.3], center=true);
  }
}

screw();