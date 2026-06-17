// Parameters
outer_diameter_mm = 18.0; //[9.0:36.0:0.1]
length_mm = 16.0; //[8.0:32.0:0.1]
screw_nominal_diameter_mm = 8.0; //[4.0:16.0:0.1]
internal_thread_pitch_mm = 1.25; //[0.6:2.5:0.05]
bore_minor_diameter_mm = 6.8; //[3.4:13.6:0.05]
bore_major_diameter_mm = 8.0; //[4.0:16.0:0.05]
end_chamfer_mm = 0.8; //[0.4:1.6:0.05]
lead_in_chamfer_angle_deg = 45.0; //[20.0:70.0:1]
knurl_depth_mm = 0.6; //[0.3:1.2:0.05]
knurl_pitch_mm = 1.2; //[0.6:2.4:0.05]
knurl_ridge_width_mm = 0.6; //[0.3:1.2:0.05]
knurl_count_around = 24; //[12:48:1]
knurl_count_along = 10; //[4:20:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
bore_clearance_mm = 0.2; //[0.0:0.6:0.05]

// Threaded Insert - complete geometry (connectivity fixed)
module threaded_insert() {
  color("Brass") {

    // --- Ring geometry (was floating): create as real solids and UNION into body with overlap ---
    ring_radial_thickness_mm = 0.8;                 // thin ring wall thickness
    ring_axial_height_mm     = 0.8;                 // thin ring height
    ring_overlap_axial_mm    = min(2.0, max(1.0, overlap_mm)); // guarantee 1-2mm overlap

    outer_r = outer_diameter_mm/2;
    ring_r_outer = outer_r + ring_radial_thickness_mm; // slight protrusion like outline ring
    ring_r_inner = outer_r - ring_radial_thickness_mm; // overlaps into body for solid attachment

    // Main solid with bore removed
    difference() {
      union() {
        // Main cylindrical body
        cylinder(r=outer_r, h=length_mm, center=true);

        // Knurl ridges (already overlapping into body)
        for (i = [0:knurl_count_along-1]) {
          translate([0, 0,
            (-length_mm/2 + end_chamfer_mm) +
            (i + 0.5) * ((length_mm - 2 * end_chamfer_mm) / knurl_count_along)
          ]) {
            for (j = [0:knurl_count_around-1]) {
              rotate([0, 0, j * 360 / knurl_count_around + (i % 2) * 180 / knurl_count_around])
                translate([outer_r + (knurl_depth_mm + overlap_mm)/2 - overlap_mm, 0, 0])
                  cube([
                    knurl_depth_mm + overlap_mm,
                    (2 * 3.141592653589793 * outer_r) / knurl_count_around,
                    knurl_ridge_width_mm
                  ], center=true);
            }
          }
        }

        // TOP ring: centered so it intersects the body by ring_overlap_axial_mm
        translate([0, 0, (length_mm/2) - (ring_axial_height_mm/2) + (ring_overlap_axial_mm/2)])
          difference() {
            cylinder(r=ring_r_outer, h=ring_axial_height_mm + ring_overlap_axial_mm, center=true);
            cylinder(r=ring_r_inner, h=ring_axial_height_mm + ring_overlap_axial_mm + 0.2, center=true);
          }

        // BOTTOM ring: centered so it intersects the body by ring_overlap_axial_mm
        translate([0, 0, (-length_mm/2) + (ring_axial_height_mm/2) - (ring_overlap_axial_mm/2)])
          difference() {
            cylinder(r=ring_r_outer, h=ring_axial_height_mm + ring_overlap_axial_mm, center=true);
            cylinder(r=ring_r_inner, h=ring_axial_height_mm + ring_overlap_axial_mm + 0.2, center=true);
          }
      }

      // Lead-in chamfer (subtractive)
      translate([0, 0, length_mm/2 - end_chamfer_mm/2])
        cylinder(r1=outer_r + overlap_mm, r2=outer_r - end_chamfer_mm,
                 h=end_chamfer_mm + overlap_mm, center=true);

      // Installation end chamfer (subtractive)
      translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
        cylinder(r1=outer_r - end_chamfer_mm, r2=outer_r + overlap_mm,
                 h=end_chamfer_mm + overlap_mm, center=true);

      // Internal bore (subtractive) - keep inside so rings remain attached to outer body
      cylinder(r=(bore_minor_diameter_mm + bore_clearance_mm)/2,
               h=length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  union() {
    threaded_insert();
  }
}

assembly();