// Parameters
outer_diameter_mm = 12.5; //[6.25:25:0.1]
overall_length_mm = 25; //[12.5:50:0.1]
bore1_diameter_mm = 5; //[2.5:10:0.1]
bore2_diameter_mm = 8; //[4:16:0.1]
bore1_depth_mm = 12.5; //[6.25:25:0.1]
bore2_depth_mm = 12.5; //[6.25:25:0.1]
center_divider_thickness_mm = 0; //[0:3:0.1]
grub_screw_count_per_end = 2; //[1:4:1]
grub_screw_angular_spacing_deg = 90; //[30:180:1]
grub_screw_offset_from_end_mm = 5; //[2.5:10:0.1]
grub_screw_hole_diameter_mm = 2.5; //[1.5:4:0.1]
grub_screw_hole_depth_mm = 5; //[2.5:10:0.1]
grub_screw_seat_diameter_mm = 4.8; //[3.5:8:0.1]
grub_screw_seat_depth_mm = 1.5; //[0:4:0.1]
tolerance_bore_mm = 0; //[-0.2:0.5:0.01]
overlap_mm = 0.8; //[0.2:2:0.1]

// Shaft Coupling - complete geometry
module shaft_coupling() {
  color("Silver") {
    difference() {
      // Coupling body
      cylinder(r=outer_diameter_mm/2, h=overall_length_mm, center=true);

      // Bores
      translate([0, 0, -overall_length_mm/2 + bore1_depth_mm/2])
        cylinder(r=(bore1_diameter_mm + tolerance_bore_mm)/2, h=bore1_depth_mm + overlap_mm, center=true);
      translate([0, 0, overall_length_mm/2 - bore2_depth_mm/2])
        cylinder(r=(bore2_diameter_mm + tolerance_bore_mm)/2, h=bore2_depth_mm + overlap_mm, center=true);

      // Optional center divider
      if (center_divider_thickness_mm > 0) {
        translate([0, 0, 0])
          cube([outer_diameter_mm*1.2, outer_diameter_mm*1.2, center_divider_thickness_mm], center=true);
      }

      // Grub screw holes
      for (end = [-1, 1]) {
        for (angle = [0, grub_screw_angular_spacing_deg]) {
          rotate([0, 90, angle])
            translate([outer_diameter_mm/2 - (grub_screw_hole_depth_mm + overlap_mm)/2, 0, end * (overall_length_mm/2 - grub_screw_offset_from_end_mm)])
              cylinder(r=grub_screw_hole_diameter_mm/2, h=grub_screw_hole_depth_mm + overlap_mm, center=true);
        }
      }

      // Grub screw seats
      for (end = [-1, 1]) {
        for (angle = [0, grub_screw_angular_spacing_deg]) {
          rotate([0, 90, angle])
            translate([outer_diameter_mm/2 - (grub_screw_seat_depth_mm + overlap_mm)/2, 0, end * (overall_length_mm/2 - grub_screw_offset_from_end_mm)])
              cylinder(r=grub_screw_seat_diameter_mm/2, h=grub_screw_seat_depth_mm + overlap_mm, center=true);
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