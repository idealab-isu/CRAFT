// Pan head screw: 3.0mm shank dia, 5.5mm head dia, head height 2.0mm, 10mm overall length
// One connected solid, with helical external threads and a Phillips-style cross recess.

$fn = 128;

// -------- Parameters (mm) --------
shank_d = 3.0;
screw_L = 10.0;

head_d = 5.5;
head_h = 2.0;

// Thread (approx M3 coarse)
thread_pitch = 0.5;
thread_major_d = shank_d;      // 3.0
thread_minor_d = 2.4;
thread_L = screw_L - head_h;   // 8.0

// Tip
tip_chamfer_h = 0.6;

// Head shaping
head_crown_h = 0.7;            // domed top height (within head_h)
under_fillet_r = 0.35;         // small under-head fillet

// Drive recess (Phillips-like)
recess_d = 3.0;
recess_depth = 1.2;
recess_arm_w = recess_d/3;

// Quality
thread_slices_per_turn = 28;
overlap = 0.08;

// -------- Coordinate system --------
// Put the screw axis on +Z, with the TOP of the head at z=0.
// This fixes orthographic views (Front/Back/Left/Right show the side profile).
z_head_top  = 0;
z_head_bot  = z_head_top - head_h;
z_tip       = z_head_bot - thread_L;   // bottom end of screw (tip end)

// -------- Helpers --------
module phillips_recess() {
  // Cross recess cut into head from top surface
  translate([0, 0, z_head_top - recess_depth/2 + overlap/2])
  union() {
    cube([recess_d, recess_arm_w, recess_depth + overlap], center=true);
    cube([recess_arm_w, recess_d, recess_depth + overlap], center=true);
  }
}

module pan_head() {
  // Pan head: cylindrical skirt + domed crown + under-head fillet
  union() {
    // Cylindrical skirt (lower part of head)
    translate([0, 0, z_head_bot + (head_h - head_crown_h)/2])
      cylinder(h=head_h - head_crown_h + overlap, r=head_d/2, center=true);

    // Domed crown (top part) as a sphere cap
    translate([0, 0, z_head_top - head_crown_h/2])
      intersection() {
        scale([1, 1, head_crown_h/(head_d/2)]) sphere(r=head_d/2);
        // keep only the lower half of the scaled sphere to form a cap
        translate([0, 0, -head_d]) cube([2*head_d, 2*head_d, 2*head_d], center=true);
      }

    // Under-head fillet (torus-like blend), overlaps into shank region
    translate([0, 0, z_head_bot + under_fillet_r])
      rotate_extrude(angle=360, convexity=10)
        translate([head_d/2 - under_fillet_r, 0, 0])
          circle(r=under_fillet_r, $fn=64);
  }
}

module thread_solid(z0, len, major_d, minor_d, pitch) {
  // Helical external thread approximation using linear_extrude twist of a triangular ridge.
  // z0 is the bottom of the threaded section.
  turns = len / pitch;
  steps = max(12, ceil(turns * thread_slices_per_turn));
  twist_deg = 360 * turns;

  union() {
    // Core (minor diameter)
    translate([0, 0, z0 + len/2])
      cylinder(h=len + overlap, r=minor_d/2, center=true);

    // Helical ridge
    translate([0, 0, z0])
      linear_extrude(height=len + overlap, twist=twist_deg, slices=steps, convexity=10)
        polygon(points=[
          [minor_d/2 - overlap, -pitch*0.18],
          [major_d/2,           0],
          [minor_d/2 - overlap,  pitch*0.18]
        ]);
  }
}

module tip_chamfer(z0) {
  // Conical tip at the end of the threaded section (at the very bottom)
  translate([0, 0, z0 + tip_chamfer_h/2])
    cylinder(h=tip_chamfer_h + overlap, r1=thread_minor_d/2, r2=0, center=true);
}

module screw() {
  difference() {
    union() {
      // Head
      pan_head();

      // Threaded shank: top meets underside of head at z_head_bot (with overlap)
      thread_solid(z_tip, thread_L, thread_major_d, thread_minor_d, thread_pitch);

      // Tip chamfer at the bottom, connected to thread core
      tip_chamfer(z_tip);
    }

    // Drive recess
    phillips_recess();
  }
}

color("DimGray") screw();