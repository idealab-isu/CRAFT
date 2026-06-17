// Parameters
outer_diameter_mm = 12.5; //[6.25:25:0.1]
overall_length_mm = 25; //[12.5:50:0.1]
bore1_diameter_mm = 5; //[2.5:10:0.1]
bore2_diameter_mm = 8; //[4:16:0.1]
bore1_length_mm = 12.5; //[6.25:25:0.1]
bore2_length_mm = 12.5; //[6.25:25:0.1]
set_screw_enabled = 1; //[0:1:1]
set_screw_count_per_bore = 2; //[1:4:1]
set_screw_axial_offset_from_end_mm = 5; //[2.5:10:0.1]
set_screw_hole_diameter_mm = 2.5; //[1.5:4:0.1]
set_screw_hole_depth_extra_mm = 2; //[0.5:5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Shaft Coupling - complete geometry
module shaft_coupling() {
  color("Silver") {
    difference() {
      // Coupling body
      cylinder(h=overall_length_mm, r=outer_diameter_mm/2, center=true);
      
      // Bore 1
      translate([0, 0, -overall_length_mm/2 + (bore1_length_mm + overlap_mm)/2])
        cylinder(h=bore1_length_mm + overlap_mm, r=bore1_diameter_mm/2, center=true);
      
      // Bore 2
      translate([0, 0, overall_length_mm/2 - (bore2_length_mm + overlap_mm)/2])
        cylinder(h=bore2_length_mm + overlap_mm, r=bore2_diameter_mm/2, center=true);
      
      // Set screw holes
      if (set_screw_enabled) {
        union() {
          // End 1, angle 0
          translate([0, 0, -overall_length_mm/2 + set_screw_axial_offset_from_end_mm])
            rotate([0, 90, 0])
            cylinder(h=outer_diameter_mm + 2*set_screw_hole_depth_extra_mm, r=set_screw_hole_diameter_mm/2, center=true);
          
          // End 1, angle 90
          translate([0, 0, -overall_length_mm/2 + set_screw_axial_offset_from_end_mm])
            rotate([90, 0, 0])
            cylinder(h=outer_diameter_mm + 2*set_screw_hole_depth_extra_mm, r=set_screw_hole_diameter_mm/2, center=true);
          
          // End 2, angle 0
          translate([0, 0, overall_length_mm/2 - set_screw_axial_offset_from_end_mm])
            rotate([0, 90, 0])
            cylinder(h=outer_diameter_mm + 2*set_screw_hole_depth_extra_mm, r=set_screw_hole_diameter_mm/2, center=true);
          
          // End 2, angle 90
          translate([0, 0, overall_length_mm/2 - set_screw_axial_offset_from_end_mm])
            rotate([90, 0, 0])
            cylinder(h=outer_diameter_mm + 2*set_screw_hole_depth_extra_mm, r=set_screw_hole_diameter_mm/2, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  shaft_coupling();
}

assembly();