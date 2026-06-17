// Parameters
outer_diameter_mm = 15; //[7.5:30:0.1]
length_mm = 12; //[6:24:0.1]
screw_diameter_mm = 6; //[3:12:0.1]
internal_thread_pitch_mm = 1; //[0.5:2:0.05]
internal_minor_diameter_mm = 5; //[4:6:0.05]
top_chamfer_height_mm = 1; //[0.5:2:0.05]
bottom_chamfer_height_mm = 1; //[0.5:2:0.05]
external_knurl_depth_mm = 0.5; //[0.2:1.2:0.05]
external_knurl_pitch_mm = 1; //[0.5:2.5:0.05]
knurl_count_around = 24; //[12:60:1]
knurl_ridge_width_mm = 1; //[0.5:2:0.05]
knurl_overlap_mm = 0.8; //[0.3:2:0.05]
bore_clearance_extra_mm = 0.2; //[0:0.6:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Insert body
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);

        // Knurl ridges
        for (i = [0:knurl_count_around-1]) {
          rotate([0, 0, i*360/knurl_count_around])
          translate([outer_diameter_mm/2 - knurl_overlap_mm + (external_knurl_depth_mm + knurl_overlap_mm)/2, 0, 0])
          cube([external_knurl_depth_mm + knurl_overlap_mm, knurl_ridge_width_mm, external_knurl_pitch_mm], center=true);
        }

        // Top entry chamfer
        translate([0, 0, length_mm/2 - top_chamfer_height_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - top_chamfer_height_mm, h=top_chamfer_height_mm, center=true);

        // Bottom lead-in chamfer
        translate([0, 0, -length_mm/2 + bottom_chamfer_height_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - bottom_chamfer_height_mm, h=bottom_chamfer_height_mm, center=true);
      }

      // Internal thread bore for M6
      cylinder(r=(internal_minor_diameter_mm + bore_clearance_extra_mm)/2, h=length_mm + 2*eps_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();