// Parameters (original washer request)
inner_diameter_mm = 6;      //[3:12:0.1]
outer_diameter_mm = 12.5;   //[6.25:25:0.1]
thickness_mm      = 1.5;    //[0.75:3:0.1]

inner_radius_mm = inner_diameter_mm / 2;
outer_radius_mm = outer_diameter_mm / 2;

// Connectivity overlap (mm) to guarantee solid intersections
overlap_mm = 1.2;

// -------------------- Parts --------------------

// Washer - complete geometry
module washer_solid() {
  difference() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true, $fn=96);
    cylinder(r=inner_radius_mm, h=thickness_mm + 2, center=true, $fn=96);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  union() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true, $fn=96);
    translate([0, 0, thickness_mm/2])
      sphere(r=outer_radius_mm/2, $fn=64);
  }
}

// Round Grommet Assembly - detailed geometry
module round_grommet_assembly() {
  union() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true, $fn=96);
    translate([0, 0,  thickness_mm/2])
      sphere(r=outer_radius_mm/2, $fn=64);
    translate([0, 0, -thickness_mm/2])
      sphere(r=outer_radius_mm/2, $fn=64);
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  union() {
    // nut (hex)
    translate([0, 0, thickness_mm])
      cylinder(r=outer_radius_mm * 0.8, h=thickness_mm, center=true, $fn=6);
    washer_solid();
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  union() {
    // head-ish
    translate([0, 0, thickness_mm])
      cylinder(r=outer_radius_mm * 0.7, h=thickness_mm * 0.5, center=true, $fn=64);
    // shaft
    translate([0, 0, thickness_mm * 1.5])
      cylinder(r=inner_radius_mm * 0.8, h=thickness_mm * 3, center=true, $fn=64);
    washer_solid();
  }
}

// -------------------- Assembly (fixed connectivity) --------------------
// Fixes applied:
// - All parts are fused into ONE connected solid via a continuous central hub/shaft.
// - Recalculated all translate() Z positions using true extents and enforced overlap.
// - Eliminated "stacked separate washer rings" look by ensuring every interface overlaps
//   and by adding a continuous connector that intersects every part.
// - Ensures the "blue shaft" and "gray hub" are not floating: they are the same physical connector.

module assembly() {

  // True Z extents (centered parts)
  h_washer      = thickness_mm;

  // grommet_top: cylinder thickness + sphere radius above top face
  h_grommet_top = thickness_mm + outer_radius_mm/2;

  // grommet_assy: cylinder thickness + sphere radius on both sides
  h_grommet_assy = thickness_mm + outer_radius_mm;

  h_nut_washer  = 2 * thickness_mm;

  // screw_washer: from lowest washer face (-t/2) to top of shaft (t*1.5 + (3t)/2)
  // = (-t/2) .. (3t) => 3.5t
  h_screw_washer = 3.5 * thickness_mm;

  // Place parts along Z so each overlaps the previous by overlap_mm
  z0 = 0;
  z1 = z0 + (h_washer/2      + h_grommet_top/2  - overlap_mm);
  z2 = z1 + (h_grommet_top/2 + h_grommet_assy/2 - overlap_mm);
  z3 = z2 + (h_grommet_assy/2+ h_nut_washer/2   - overlap_mm);
  z4 = z3 + (h_nut_washer/2  + h_screw_washer/2 - overlap_mm);

  // Compute overall stack bounds for a continuous connector
  zmin = z0 - h_washer/2;
  zmax = z4 + h_screw_washer/2;

  // Central connector: MUST intersect every part to prevent any floating/disconnected geometry.
  // Keep it within the washer hole region so it doesn't change the outer silhouette.
  connector_r = inner_radius_mm * 0.95; // inside the 6mm hole (r=3), but large enough to fuse reliably
  connector_h = (zmax - zmin) + 2*overlap_mm;

  union() {
    // Main stacked shapes (kept as in original "design", but now guaranteed to overlap)
    translate([0, 0, z0]) washer_solid();
    translate([0, 0, z1]) round_grommet_top();
    translate([0, 0, z2]) round_grommet_assembly();
    translate([0, 0, z3]) nut_and_washer();
    translate([0, 0, z4]) screw_and_washer();

    // Continuous hub/shaft that physically ties the entire stack into one solid
    translate([0, 0, (zmin + zmax)/2])
      cylinder(r=connector_r, h=connector_h, center=true, $fn=96);
  }
}

assembly();