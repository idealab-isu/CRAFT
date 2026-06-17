// Threaded heat-set insert (simplified solid model)
// Target: 4.0mm OD, 4.6mm length, for M2.5 screws

$fn = 128;

// Parameters
outer_diameter_mm = 4; //[2:8:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]
screw_nominal_diameter_mm = 2.5; //[1.2:5:0.1]
internal_thread_pitch_mm = 0.45; //[0.2:0.9:0.01]
internal_minor_diameter_mm = 2.05; //[1.02:4.1:0.05]
internal_tap_drill_diameter_mm = 2.05; //[1.02:4.1:0.05]
outer_knurl_depth_mm = 0.25; //[0.1:0.6:0.01]
outer_knurl_pitch_mm = 0.6; //[0.3:1.2:0.05]
end_chamfer_length_mm = 0.4; //[0.2:0.9:0.05]
end_chamfer_angle_deg = 30; //[15:60:1]
knurl_groove_width_mm = 0.25; //[0.1:0.6:0.01]
knurl_groove_count = 18; //[8:40:1]
knurl_z_margin_mm = 0.2; //[0.1:0.6:0.05]
overlap_mm = 0.8; //[0.2:2:0.1]
bore_extra_mm = 0.2; //[0.05:0.6:0.05]

// Derived / safety clamps
eps = 0.01;

outer_r = max(eps, outer_diameter_mm/2);
inner_r = min(max(eps, internal_minor_diameter_mm/2), outer_r - 0.25); // ensure wall thickness

chamfer_h = min(max(eps, end_chamfer_length_mm), length_mm/2 - eps);
mid_h = max(eps, length_mm - 2*chamfer_h);

knurl_h = max(eps, length_mm - 2*knurl_z_margin_mm);
knurl_center_z = 0; // centered on part

// Threaded Insert - complete geometry (one connected solid)
module threaded_insert() {
  color([0.8, 0.6, 0.2])
  difference() {
    // Outer body with end chamfers (single connected solid)
    union() {
      // Middle straight section
      cylinder(h = mid_h, r = outer_r, center = true);

      // Top chamfer: from outer_r down to outer_r - chamfer_h (approx visual chamfer)
      translate([0, 0, (mid_h/2 + chamfer_h/2 - eps)])
        cylinder(h = chamfer_h, r1 = outer_r, r2 = max(eps, outer_r - chamfer_h), center = true);

      // Bottom chamfer
      translate([0, 0, -(mid_h/2 + chamfer_h/2 - eps)])
        cylinder(h = chamfer_h, r1 = max(eps, outer_r - chamfer_h), r2 = outer_r, center = true);
    }

    // Internal bore (through)
    cylinder(h = length_mm + bore_extra_mm, r = inner_r, center = true);

    // Knurl grooves (subtractive), guaranteed to intersect the body
    // Place groove center at radius where it cuts into the surface by outer_knurl_depth_mm.
    groove_radial_thickness = outer_knurl_depth_mm + 2*overlap_mm;
    groove_center_r = outer_r - outer_knurl_depth_mm/2; // ensures cut depth = outer_knurl_depth_mm

    for (i = [0 : knurl_groove_count - 1]) {
      rotate([0, 0, i * 360 / knurl_groove_count])
        translate([groove_center_r, 0, knurl_center_z])
          cube([groove_radial_thickness, knurl_groove_width_mm, knurl_h], center = true);
    }
  }
}

threaded_insert();