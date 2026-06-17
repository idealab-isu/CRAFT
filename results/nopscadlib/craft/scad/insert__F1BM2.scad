// Threaded heat-set insert (simplified solid with knurl ribs + bore)
// Target: 4.0mm OD, 3.6mm long, for 2.0mm screws

outer_diameter_mm = 4.0; //[2.0:8.0:0.1]
length_mm = 3.6; //[1.8:7.2:0.1]
screw_diameter_mm = 2.0; //[1.0:4.0:0.05]
tolerance_outer_diameter_mm = 0.0; //[-0.2:0.2:0.01]
tolerance_inner_diameter_mm = 0.0; //[-0.2:0.4:0.01]
end_chamfer_mm = 0.3; //[0.1:0.8:0.05]
knurl_rib_count = 16; //[8:32:1]
knurl_rib_depth_mm = 0.25; //[0.1:0.6:0.05]
knurl_rib_width_mm = 0.5; //[0.2:1.2:0.05]
overlap_mm = 0.2; //[0.05:1.0:0.05]

$fn = 96;

module threaded_insert() {
  outer_r = max((outer_diameter_mm + tolerance_outer_diameter_mm) / 2, 0.01);
  inner_r = max((screw_diameter_mm + tolerance_inner_diameter_mm) / 2, 0.01);

  // Ensure valid geometry (avoid negative/zero heights and inverted chamfers)
  L = max(length_mm, 0.2);
  ov = max(overlap_mm, 0.01);

  // Keep chamfer within part length and radius
  chamfer_h = min(max(end_chamfer_mm, 0), L/2 - 0.01);
  chamfer_drop = min(chamfer_h, outer_r - 0.01);

  // Knurl ribs: protrude outward, overlap into body for connectivity
  rib_radial = max(knurl_rib_depth_mm, 0.01);
  rib_w = max(knurl_rib_width_mm, 0.01);
  rib_h = L + 2*ov;

  // Place rib so it intersects the base cylinder by ov
  rib_center_r = outer_r + rib_radial/2 - ov;

  // Prevent bore from deleting the whole part
  bore_r = min(inner_r, outer_r - 0.15);

  color([0.8, 0.6, 0.2])
  difference() {
    union() {
      // Main body
      cylinder(h=L, r=outer_r, center=true);

      // End chamfers (connected via overlap)
      if (chamfer_h > 0 && chamfer_drop > 0) {
        translate([0, 0,  L/2 - chamfer_h/2 + ov/2])
          cylinder(h=chamfer_h + ov, r1=outer_r, r2=outer_r - chamfer_drop, center=true);

        translate([0, 0, -L/2 + chamfer_h/2 - ov/2])
          cylinder(h=chamfer_h + ov, r1=outer_r - chamfer_drop, r2=outer_r, center=true);
      }

      // Knurl ribs (radial array)
      for (i = [0:knurl_rib_count-1]) {
        rotate([0, 0, i*360/knurl_rib_count])
          translate([rib_center_r, 0, 0])
            cube([rib_radial, rib_w, rib_h], center=true);
      }
    }

    // Internal screw bore (through)
    cylinder(h=L + 4*ov, r=bore_r, center=true);
  }
}

threaded_insert();