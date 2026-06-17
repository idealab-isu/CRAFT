// Parameters
bore_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 12; //[6:24:0.1]
length_mm = 19; //[10:38:0.1]
bore_radius_mm = 3; //[1.5:6:0.1]
outer_radius_mm = 6; //[3:12:0.1]
casing_thickness_mm = 0.6; //[0.3:1.2:0.05]
groove_radius_mm = 5.5; //[4.5:6:0.05]
groove_length_mm = 1.2; //[0.6:2.4:0.05]
groove_spacing_mm = 12; //[6:18:0.1]
seal_clearance_mm = 0.2; //[0.05:0.5:0.05]
seal_outer_scale = 1.12; //[1.05:1.25:0.01]
eps_mm = 0.5; //[0.2:2:0.1]
screw_shank_radius_mm = 1.5; //[0.8:3:0.1]
screw_length_mm = 12; //[6:24:0.5]
screw_head_radius_mm = 3; //[1.5:6:0.1]
screw_head_height_mm = 2.5; //[1:5:0.1]
washer_radius_mm = 4; //[2:8:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]

// Connectivity overlap (1–2mm) to guarantee attachment
overlap_mm = 1.5;

// Linear Bearing body (kept as original "shell" logic)
module linear_bearing_body() {
  color("DimGray")
    difference() {
      // Outer shell
      cylinder(r=outer_radius_mm, h=length_mm, center=true);

      // Inner bore
      cylinder(r=bore_radius_mm, h=length_mm + 2*eps_mm, center=true);

      // Outer casing (as in original code)
      cylinder(r=outer_radius_mm - casing_thickness_mm, h=length_mm, center=true);

      // Grooves
      translate([0, 0, -groove_spacing_mm/2])
        cylinder(r=outer_radius_mm + eps_mm, h=groove_length_mm, center=true);
      translate([0, 0,  groove_spacing_mm/2])
        cylinder(r=outer_radius_mm + eps_mm, h=groove_length_mm, center=true);

      // Seal cut
      cylinder(r=bore_radius_mm * seal_outer_scale, h=length_mm, center=true);
    }
}

// Add top/bottom dark rings/caps and physically attach them to the body
module bearing_with_caps() {
  cap_h = groove_length_mm;

  // Ensure caps INTERSECT the body by overlap_mm (no gaps):
  // Body spans z = [-length/2, +length/2]
  // Cap spans z = [z_cap - cap_h/2, z_cap + cap_h/2]
  // Make cap intrude into body by overlap_mm:
  // cap bottom = length/2 - overlap_mm  => z_cap = length/2 - overlap_mm + cap_h/2
  z_cap = length_mm/2 - overlap_mm + cap_h/2;

  union() {
    // Main body
    linear_bearing_body();

    // Top cap (attached with overlap)
    color("DimGray")
      translate([0, 0,  z_cap])
        cylinder(r=outer_radius_mm, h=cap_h, center=true);

    // Bottom cap (attached with overlap)
    color("DimGray")
      translate([0, 0, -z_cap])
        cylinder(r=outer_radius_mm, h=cap_h, center=true);
  }
}

// Screw and Washer - repositioned to intersect the bearing body (no floating)
module screw_and_washer_attached() {
  // Screw axis is parallel to Z; move it in +X so it penetrates the bearing wall by overlap_mm.
  // Ensure shank intersects: (x_screw + shank_r) > outer_r  AND (x_screw - shank_r) < outer_r
  x_screw = outer_radius_mm - screw_shank_radius_mm + overlap_mm;

  // Washer should also intersect the bearing by overlap_mm:
  // washer inner edge at (x_washer - washer_r) should be inside outer_radius by overlap_mm
  // => x_washer - washer_r = outer_r - overlap_mm  => x_washer = outer_r + washer_r - overlap_mm
  x_washer = outer_radius_mm + washer_radius_mm - overlap_mm;

  // Keep head above washer; ensure head overlaps washer slightly
  z_washer = 0;
  z_head   = washer_thickness_mm/2 + screw_head_height_mm/2 - overlap_mm;

  color("Silver")
    union() {
      // Screw shank (intersects bearing due to x_screw)
      translate([x_screw, 0, 0])
        cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);

      // Washer (intersects bearing due to x_washer)
      translate([x_washer, 0, z_washer])
        cylinder(r=washer_radius_mm, h=washer_thickness_mm, center=true);

      // Screw head (on top of washer, overlapping slightly)
      translate([x_washer, 0, z_head])
        cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
    }
}

// Assembly: ALL parts in a single solid union (no floating parts)
module assembly() {
  union() {
    bearing_with_caps();
    screw_and_washer_attached();
  }
}

assembly();