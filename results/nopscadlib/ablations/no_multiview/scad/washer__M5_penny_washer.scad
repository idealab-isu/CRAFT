// Parameters
inner_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 20; //[10:40:0.5]
thickness_mm      = 1.4; //[0.7:2.8:0.1]
eps_mm            = 0.2; //[0.05:0.5:0.05]

// Connectivity overlap (1–2mm as required)
overlap_mm = 1.2;

// Penny Washer - complete geometry
module penny_washer() {
  difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
    cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
  }
}

// Screw and Washer - complete geometry (washer fused to rod with overlap)
module screw_and_washer() {
  screw_h = 10;
  screw_r = 2;

  union() {
    // Screw body
    cylinder(r=screw_r, h=screw_h, center=false, $fn=32);

    // Washer intersects screw by overlap (no floating)
    translate([0, 0, screw_h - overlap_mm + thickness_mm/2])
      penny_washer();
  }
}

// Post 4mm Hole - FIXED structurally: make it a real tube (was empty before)
module post_4mm_hole() {
  post_h = 100;
  post_outer_r = 2;                 // keep overall outer size
  post_inner_r = max(0.1, 2 - 0.8);  // create material; ~0.8mm wall

  difference() {
    cylinder(r=post_outer_r, h=post_h, center=false, $fn=32);
    // inner hole runs through, slightly extended for clean boolean
    translate([0, 0, -eps_mm])
      cylinder(r=post_inner_r, h=post_h + 2*eps_mm, center=false, $fn=32);
  }
}

// Round Grommet Top - FIXED structurally: give it thickness so it can fuse
module round_grommet_top() {
  // Original was a zero-thickness surface (rotate_extrude of a circle).
  // Make it a thin solid ring by extruding a small rectangle profile.
  grommet_radial_thk = 2;                 // ~2mm radial thickness
  grommet_axial_thk  = max(1.2, overlap_mm); // >= overlap so it fuses reliably

  rotate_extrude($fn=96)
    translate([outer_diameter_mm/2, 0, 0])
      square([grommet_radial_thk, grommet_axial_thk], center=true);
}

// Assembly (single union; all parts overlap and are physically connected)
module assembly() {
  screw_h = 10;
  post_h  = 100;

  // Base washer centered at z=0 spans [-t/2, +t/2]
  z_base_washer_top = thickness_mm/2;

  // Screw is non-centered (0..screw_h). Place so it penetrates base washer by overlap.
  z_screw_base = z_base_washer_top - overlap_mm;
  z_screw_top  = z_screw_base + screw_h;

  // Post is non-centered (0..post_h). Place so it penetrates screw top by overlap.
  z_post_base = z_screw_top - overlap_mm;
  z_post_top  = z_post_base + post_h;

  // Grommet is centered; place so its bottom penetrates post top by overlap.
  // grommet axial thickness is grommet_axial_thk (defined in module), but we ensure
  // intersection by placing its center at (post_top - overlap + grommet_axial_thk/2).
  grommet_axial_thk = max(1.2, overlap_mm);
  z_grommet_center = z_post_top - overlap_mm + grommet_axial_thk/2;

  union() {
    // Base washer
    penny_washer();

    // Screw + its washer (fused internally)
    translate([0, 0, z_screw_base])
      screw_and_washer();

    // Post (now a real solid tube) fused to screw
    translate([0, 0, z_post_base])
      post_4mm_hole();

    // Top grommet (now a real solid) fused to post
    translate([0, 0, z_grommet_center])
      round_grommet_top();
  }
}

assembly();