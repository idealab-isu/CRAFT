// Parameters (mm)
total_length_mm = 12; //[6:24:0.5]
outer_width_mm = 12; //[6:24:0.5]
outer_height_mm = 8; //[4:16:0.5]
wall_thickness_mm = 1; //[0.5:2:0.1]
internal_corner_fillet_radius_mm = 0.5; //[0.25:1:0.05]
length_mm = 100; //[12:240:1]
centered = 1; //[0:1:1]
overlap_mm = 0.8; //[0.5:2:0.1]
material = 1; //[1:1:1]

// Quality
$fn=32;

// ---------- Helpers ----------
module _rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
  }
}

module _tube_with_internal_fillets(ow, oh, L, t, r, overlap) {
  // Outer is sharp rectangle; inner void has rounded corners (fillets)
  // This yields a realistic hollow tube with internal corner radii.
  difference() {
    cube([ow, oh, L], center=true);

    // Inner void with filleted corners
    translate([0,0,0])
      linear_extrude(height=L + 2*overlap, center=true, convexity=10)
        _rounded_rect_2d(ow - 2*t, oh - 2*t, r);
  }
}

// ---------- Base-shape modules (MANDATORY) ----------

module box_corner_profile_section() {
  // Represents one internal corner fillet "profile section" as a quarter-cylinder
  // positioned at the inner corner location.
  color([0.85, 0.85, 0.88, 0.55]) {
    translate([
      outer_width_mm/2 - wall_thickness_mm - internal_corner_fillet_radius_mm,
      outer_height_mm/2 - wall_thickness_mm - internal_corner_fillet_radius_mm,
      0
    ])
    intersection() {
      cylinder(r=internal_corner_fillet_radius_mm, h=length_mm + 2*overlap_mm, center=true);
      // Keep only the quadrant facing inward (toward -x, -y from this corner)
      translate([-internal_corner_fillet_radius_mm/2, -internal_corner_fillet_radius_mm/2, 0])
        cube([internal_corner_fillet_radius_mm, internal_corner_fillet_radius_mm, length_mm + 2*overlap_mm + 0.2], center=true);
    }
  }
}

module box_corner_profile_sections() {
  // Four mirrored corner profile sections
  union() {
    box_corner_profile_section();
    mirror([1,0,0]) box_corner_profile_section();
    mirror([0,1,0]) box_corner_profile_section();
    mirror([0,1,0]) mirror([1,0,0]) box_corner_profile_section();
  }
}

module corner() {
  // "Corner" component: show the internal fillet volumes as a connected set,
  // plus a thin reference ring to make it visually recognizable as a corner feature.
  color([0.80, 0.82, 0.86, 0.65]) {
    union() {
      box_corner_profile_sections();

      // Subtle visual cue: a thin inner perimeter ring at mid-length
      // (kept small to avoid altering the intended boolean behavior elsewhere)
      translate([0,0,0])
        linear_extrude(height=0.6, center=true)
          difference() {
            _rounded_rect_2d(outer_width_mm - 2*wall_thickness_mm, outer_height_mm - 2*wall_thickness_mm, internal_corner_fillet_radius_mm);
            _rounded_rect_2d(outer_width_mm - 2*wall_thickness_mm - 0.8, outer_height_mm - 2*wall_thickness_mm - 0.8, max(internal_corner_fillet_radius_mm-0.2, 0.05));
          }
    }
  }
}

module box_shelf_screw_positions() {
  // Represent "top screws" as short screw heads + shanks at the top face.
  // Plan provides one cylinder at center; we keep that and add a realistic screw-like form.
  screw_shank_r = wall_thickness_mm/2;
  screw_head_r  = max(screw_shank_r*1.8, screw_shank_r + 0.6);
  shank_h = max(wall_thickness_mm, 1);
  head_h  = max(wall_thickness_mm*0.7, 0.8);

  color([0.35, 0.35, 0.38]) {
    translate([0,0,length_mm/2 - wall_thickness_mm/2]) {
      union() {
        // Shank
        cylinder(r=screw_shank_r, h=shank_h, center=true);

        // Head (slightly above)
        translate([0,0, (shank_h+head_h)/2 - 0.01])
          cylinder(r=screw_head_r, h=head_h, center=true);

        // Simple cross recess
        difference() {
          translate([0,0, (shank_h+head_h)/2 - 0.01])
            cylinder(r=screw_head_r, h=head_h, center=true);
          translate([0,0, (shank_h+head_h)/2 - 0.01]) {
            cube([screw_head_r*1.6, screw_head_r*0.35, head_h+0.2], center=true);
            cube([screw_head_r*0.35, screw_head_r*1.6, head_h+0.2], center=true);
          }
        }
      }
    }
  }
}

module box_section() {
  // Final tube body per plan: outer box minus inner void minus internal_corner_fillet union,
  // then union with screw position feature.
  color([0.75, 0.75, 0.77]) {
    union() {
      // Tube body with internal fillets (implemented directly as rounded inner void)
      _tube_with_internal_fillets(
        outer_width_mm,
        outer_height_mm,
        length_mm,
        wall_thickness_mm,
        internal_corner_fillet_radius_mm,
        overlap_mm
      );

      // Add the screw position feature (as in plan union)
      box_shelf_screw_positions();
    }
  }
}

// ---------- Assembly ----------
module assembly() {
  // PRIMARY at origin: corner (as requested)
  // SECONDARY attaches/overlaps with primary: box_section and screw feature are co-located.
  // No floating parts: all share the same coordinate system and intersect/attach.
  corner();
  box_section();
}

assembly();