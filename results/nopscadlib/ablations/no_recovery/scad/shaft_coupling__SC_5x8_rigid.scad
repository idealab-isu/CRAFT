// Parameters
outer_diameter_mm = 12.5; //[6.25:25:0.1]
length_mm = 25; //[12.5:50:0.1]
bore1_diameter_mm = 5; //[2.5:10:0.05]
bore2_diameter_mm = 8; //[4:16:0.05]
bore_split_position_mm_from_end = 12.5; //[6.25:18.75:0.1]
tolerance_mm = 0.1; //[0:0.5:0.01]
set_screw_count_per_side = 0; //[0:4:1]
set_screw_hole_diameter_mm = 3; //[2:6:0.1]
set_screw_hole_depth_mm = 7; //[3:15:0.1]
set_screw_edge_offset_z_mm = 5; //[2:10:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Shaft Coupling - complete geometry
module shaft_coupling() {
  color("Silver") {
    difference() {
      // Coupling body
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      
      // Bore 5mm half
      translate([0, 0, -length_mm/2 + (bore_split_position_mm_from_end + overlap_mm)/2])
        cylinder(r=(bore1_diameter_mm + tolerance_mm)/2, h=bore_split_position_mm_from_end + overlap_mm, center=true, $fn=64);
      
      // Bore 8mm half
      translate([0, 0, -length_mm/2 + bore_split_position_mm_from_end + ((length_mm - bore_split_position_mm_from_end) + overlap_mm)/2 - overlap_mm])
        cylinder(r=(bore2_diameter_mm + tolerance_mm)/2, h=(length_mm - bore_split_position_mm_from_end) + overlap_mm, center=true, $fn=64);
      
      // Mid-plane bore transition
      translate([0, 0, -length_mm/2 + bore_split_position_mm_from_end])
        cylinder(r=(max(bore1_diameter_mm, bore2_diameter_mm) + tolerance_mm)/2, h=overlap_mm, center=true, $fn=64);
      
      // Set screw holes (optional)
      if (set_screw_count_per_side > 0) {
        union() {
          // Side 1
          for (i = [0 : set_screw_count_per_side - 1]) {
            rotate([0, 0, i * 360 / set_screw_count_per_side]) {
              translate([outer_diameter_mm/2 - set_screw_hole_depth_mm/2 + overlap_mm/2, 0, -length_mm/2 + set_screw_edge_offset_z_mm])
                rotate([0, 90, 0])
                cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_hole_depth_mm, center=true, $fn=32);
              
              translate([0, outer_diameter_mm/2 - set_screw_hole_depth_mm/2 + overlap_mm/2, -length_mm/2 + set_screw_edge_offset_z_mm])
                rotate([90, 0, 0])
                cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_hole_depth_mm, center=true, $fn=32);
            }
          }
          // Side 2
          for (i = [0 : set_screw_count_per_side - 1]) {
            rotate([0, 0, i * 360 / set_screw_count_per_side]) {
              translate([outer_diameter_mm/2 - set_screw_hole_depth_mm/2 + overlap_mm/2, 0, length_mm/2 - set_screw_edge_offset_z_mm])
                rotate([0, 90, 0])
                cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_hole_depth_mm, center=true, $fn=32);
              
              translate([0, outer_diameter_mm/2 - set_screw_hole_depth_mm/2 + overlap_mm/2, length_mm/2 - set_screw_edge_offset_z_mm])
                rotate([90, 0, 0])
                cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_hole_depth_mm, center=true, $fn=32);
            }
          }
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