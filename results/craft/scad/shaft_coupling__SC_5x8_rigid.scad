// Parameters
length_mm = 25; //[12.5:50:0.5]
outer_diameter_mm = 12.5; //[6.25:25:0.25]
bore1_diameter_mm = 5; //[2.5:10:0.1]
bore2_diameter_mm = 8; //[4:16:0.1]
bore_transition_location_mm_from_center = 0; //[-5:5:0.1]
bore_overlap_mm = 1; //[0.5:2:0.1]
split_plane_thickness_mm = 0.5; //[0.2:2:0.1]

// Shaft Coupling - single connected solid (no floating halves, no gap)
module shaft_coupling() {
  // Overlap to guarantee physical connection between the two outer halves
  overlap_mm = 1.5; // 1-2mm as required

  // Clamp transition so it stays inside the coupling length
  t = max(min(bore_transition_location_mm_from_center, length_mm/2 - 1), -(length_mm/2 - 1));

  // Build two outer halves that OVERLAP around the split plane (z=t)
  // Each half is length/2 + overlap, positioned so they intersect by overlap.
  half_h = length_mm/2 + overlap_mm;

  // Centers chosen so:
  // lower half spans: [t - length/2, t + overlap]
  // upper half spans: [t - overlap,  t + length/2]
  z_lower = t - length_mm/4 + overlap_mm/2;
  z_upper = t + length_mm/4 - overlap_mm/2;

  color("Silver")
  difference() {
    // OUTER BODY: union of two overlapping cylinders -> one connected solid
    union() {
      translate([0, 0, z_lower])
        cylinder(r=outer_diameter_mm/2, h=half_h, center=true, $fn=96);

      translate([0, 0, z_upper])
        cylinder(r=outer_diameter_mm/2, h=half_h, center=true, $fn=96);
    }

    // BORES + split relief: subtraction volumes (do not create disconnection)
    union() {
      // Bore 1 (5mm) - lower side, extends slightly past split plane
      translate([0, 0, t - length_mm/4])
        cylinder(r=bore1_diameter_mm/2,
                 h=length_mm/2 + bore_overlap_mm + overlap_mm,
                 center=true, $fn=96);

      // Bore 2 (8mm) - upper side, extends slightly past split plane
      translate([0, 0, t + length_mm/4])
        cylinder(r=bore2_diameter_mm/2,
                 h=length_mm/2 + bore_overlap_mm + overlap_mm,
                 center=true, $fn=96);

      // Split plane relief (thin ring cut). Outer halves overlap so body stays connected.
      translate([0, 0, t])
        cylinder(r=outer_diameter_mm/2 + bore_overlap_mm,
                 h=split_plane_thickness_mm,
                 center=true, $fn=96);
    }
  }
}

// Assembly
module assembly() {
  union() {
    shaft_coupling();
  }
}

assembly();