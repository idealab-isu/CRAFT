// Aluminium extrusion profile: 30mm x 30mm cross section, 100mm long
// Single connected solid (one part). No extra floating "view" helpers.

// Parameters
cross_section_width_mm  = 30.0;
cross_section_height_mm = 30.0;
length_mm              = 100.0;

cornerHole = 1; // [0:1:1]

// Feature parameters (kept from original, but applied only to the single extrusion)
t_slot_opening_width_mm   = 6.2;
t_slot_inner_width_mm     = 12.0;
t_slot_depth_mm           = 8.0;
t_slot_lip_thickness_mm   = 2.0;

center_bore_diameter_mm   = 6.8;

corner_hole_diameter_mm           = 4.2;
corner_hole_offset_from_edge_mm   = 7.5;

overlap_mm = 1.0;

// Single extrusion module
module extrusion_3030(L=length_mm, W=cross_section_width_mm, H=cross_section_height_mm) {
  color("Silver")
  difference() {
    // Outer body: 30x30 cross-section, 100mm long along Z
    cube([W, H, L], center=true);

    // Subtractive features (all extend through full length)
    union() {
      // T-slots on all four sides (subtractive)
      // +X
      translate([ W/2 - (t_slot_depth_mm + overlap_mm)/2, 0, 0])
        cube([t_slot_depth_mm + overlap_mm, t_slot_inner_width_mm, L + 2*overlap_mm], center=true);
      translate([ W/2 - (t_slot_lip_thickness_mm + overlap_mm)/2, 0, 0])
        cube([t_slot_lip_thickness_mm + overlap_mm, t_slot_opening_width_mm, L + 2*overlap_mm], center=true);

      // -X
      translate([-W/2 + (t_slot_depth_mm + overlap_mm)/2, 0, 0])
        cube([t_slot_depth_mm + overlap_mm, t_slot_inner_width_mm, L + 2*overlap_mm], center=true);
      translate([-W/2 + (t_slot_lip_thickness_mm + overlap_mm)/2, 0, 0])
        cube([t_slot_lip_thickness_mm + overlap_mm, t_slot_opening_width_mm, L + 2*overlap_mm], center=true);

      // +Y
      translate([0, H/2 - (t_slot_depth_mm + overlap_mm)/2, 0])
        cube([t_slot_inner_width_mm, t_slot_depth_mm + overlap_mm, L + 2*overlap_mm], center=true);
      translate([0, H/2 - (t_slot_lip_thickness_mm + overlap_mm)/2, 0])
        cube([t_slot_opening_width_mm, t_slot_lip_thickness_mm + overlap_mm, L + 2*overlap_mm], center=true);

      // -Y
      translate([0, -H/2 + (t_slot_depth_mm + overlap_mm)/2, 0])
        cube([t_slot_inner_width_mm, t_slot_depth_mm + overlap_mm, L + 2*overlap_mm], center=true);
      translate([0, -H/2 + (t_slot_lip_thickness_mm + overlap_mm)/2, 0])
        cube([t_slot_opening_width_mm, t_slot_lip_thickness_mm + overlap_mm, L + 2*overlap_mm], center=true);

      // Center bore
      cylinder(d=center_bore_diameter_mm, h=L + 2*overlap_mm, center=true, $fn=64);

      // Corner holes
      if (cornerHole) {
        for (sx = [-1, 1], sy = [-1, 1]) {
          translate([sx*(W/2 - corner_hole_offset_from_edge_mm),
                     sy*(H/2 - corner_hole_offset_from_edge_mm),
                     0])
            cylinder(d=corner_hole_diameter_mm, h=L + 2*overlap_mm, center=true, $fn=48);
        }
      }
    }
  }
}

// Build single connected solid
extrusion_3030();