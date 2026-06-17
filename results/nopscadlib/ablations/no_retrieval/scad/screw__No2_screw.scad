// Pan head screw: shank Ø2.2, head Ø4.2, head height 1.7, overall length 10
// One connected solid; all placements derived from dimensions.

$fn = 128;

// ---------------- Parameters ----------------
shank_d = 2.2;          // mm
screw_L = 10;           // mm overall length (tip to head top)
head_d  = 4.2;          // mm
head_h  = 1.7;          // mm

// Drive (simple Phillips-like cross)
drive_d     = 2.0;      // mm
drive_depth = 0.8;      // mm

// Head shaping
head_crown_h = 0.55;       // mm (rounded dome height on top of head)
underhead_fillet_r = 0.25; // mm

// Tip shaping
tip_chamfer_h  = 0.6;   // mm
tip_chamfer_d2 = 1.2;   // mm at very tip

// Thread (lightweight helical ridge)
thread_pitch    = 0.45; // mm
thread_len      = 8.0;  // mm (from near tip upward)
thread_radial_h = 0.18; // mm
thread_tooth_w  = 0.22; // mm
thread_steps    = 220;  // smoother helix

overlap = 0.06;         // small overlap to ensure manifold unions

// ---------------- Derived ----------------
shank_L = screw_L - head_h;   // length below head
z_head_bottom = 0;
z_head_top    = head_h;
z_tip         = -shank_L;

// ---------------- Geometry modules ----------------
module shank_cyl() {
  // Shank from head bottom down to tip
  translate([0, 0, (z_head_bottom + z_tip)/2])
    cylinder(h=shank_L, r=shank_d/2, center=true);
}

module tip_chamfer() {
  // Conical tip at very bottom, connected to shank
  translate([0, 0, z_tip + tip_chamfer_h/2 - overlap/2])
    cylinder(h=tip_chamfer_h + overlap, r1=shank_d/2, r2=tip_chamfer_d2/2, center=true);
}

module pan_head_solid() {
  union() {
    // Main head cylinder
    translate([0, 0, head_h/2])
      cylinder(h=head_h, r=head_d/2, center=true);

    // Rounded crown on top
    hull() {
      translate([0, 0, head_h - overlap])
        cylinder(h=overlap, r=head_d/2, center=false);
      translate([0, 0, head_h + head_crown_h])
        cylinder(h=overlap, r=(head_d*0.55)/2, center=false);
    }

    // Underhead fillet (torus-like blend), overlaps into head and shank
    translate([0, 0, z_head_bottom + underhead_fillet_r - overlap])
      rotate_extrude(convexity=10)
        translate([shank_d/2, 0, 0])
          circle(r=underhead_fillet_r, $fn=64);
  }
}

module drive_recess() {
  // Cross recess cut into head top
  zc = z_head_top - drive_depth/2;
  translate([0, 0, zc])
    union() {
      cube([drive_d, drive_d/4, drive_depth + 2*overlap], center=true);
      cube([drive_d/4, drive_d, drive_depth + 2*overlap], center=true);
    }
}

module head_with_drive() {
  difference() {
    pan_head_solid();
    drive_recess();
  }
}

module thread_tooth_proto() {
  // Small rectangular ridge placed at shank surface
  translate([shank_d/2 + thread_radial_h/2 - overlap, 0, 0])
    cube([thread_radial_h + 2*overlap, thread_tooth_w, thread_pitch*0.6], center=true);
}

module thread_union() {
  // Helical ridge along lower portion of shank
  z0 = z_tip + tip_chamfer_h + thread_pitch*0.25;
  z1 = min(z_tip + thread_len, z_head_bottom - thread_pitch*0.25);
  span = max(0.01, z1 - z0);

  union() {
    for (i = [0:thread_steps-1]) {
      t = i/(thread_steps-1);
      z = z0 + t*span;
      ang = 360 * ((z - z0) / thread_pitch);
      translate([0, 0, z])
        rotate([0, 0, ang])
          thread_tooth_proto();
    }
  }
}

module screw_complete() {
  // Rotate so the screw axis is along X.
  // This makes FRONT/BACK/LEFT/RIGHT orthographic views show the length,
  // while TOP/BOTTOM show the circular head as expected.
  rotate([0, 90, 0])
    union() {
      shank_cyl();
      tip_chamfer();
      head_with_drive();
      thread_union();
    }
}

// ---------------- Render ----------------
color("DimGray") screw_complete();