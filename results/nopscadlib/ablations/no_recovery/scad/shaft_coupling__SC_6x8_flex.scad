// Parameters
outer_diameter_mm = 19; //[10:38:0.1]
length_mm = 25; //[12.5:50:0.1]
bore1_diameter_mm = 6; //[3:12:0.1]
bore2_diameter_mm = 8; //[4:16:0.1]
bore1_depth_mm = 12.5; //[6:25:0.1]
bore2_depth_mm = 12.5; //[6:25:0.1]
flexible = 1; //[0:1:1]
flex_section_length_mm = 8; //[4:16:0.1]
flex_slot_width_mm = 1.2; //[0.6:2.4:0.1]
flex_slot_radial_depth_mm = 5.5; //[3:8:0.1]
grub_screw_hole_diameter_mm = 2.5; //[1.5:3.5:0.1]
grub_screw_hole_depth_mm = 5; //[3:10:0.1]
grub_screw_axial_offset_mm = 5; //[2:10:0.1]
grub_screw_overlap_mm = 1; //[0.5:2:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]

// Flex - Detailed geometry
module flex() {
  if (flexible == 1) {
    color("Silver") {
      difference() {
        // Main body
        cylinder(r=outer_diameter_mm/2, h=flex_section_length_mm, center=true, $fn=64);
        // Flexible slots
        for (i = [0:5]) {
          rotate([0, 0, i*60])
          translate([0, 0, 0])
          cube([outer_diameter_mm + connection_overlap_mm*2, flex_slot_width_mm, flex_section_length_mm], center=true);
        }
      }
    }
  }
}

// Shaft Coupling - Detailed geometry
module shaft_coupling() {
  color("Silver") {
    difference() {
      // Main body
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      // Bore 1
      translate([0, 0, -length_mm/2 + bore1_depth_mm/2])
        cylinder(r=bore1_diameter_mm/2, h=bore1_depth_mm + connection_overlap_mm, center=true, $fn=64);
      // Bore 2
      translate([0, 0, length_mm/2 - bore2_depth_mm/2])
        cylinder(r=bore2_diameter_mm/2, h=bore2_depth_mm + connection_overlap_mm, center=true, $fn=64);
      // Bore transition step
      cylinder(r=max(bore1_diameter_mm, bore2_diameter_mm)/2, h=connection_overlap_mm*2, center=true, $fn=64);
      // Grub screw holes
      for (i = [-1, 1]) {
        translate([outer_diameter_mm/2 - (grub_screw_hole_depth_mm + grub_screw_overlap_mm)/2, 0, i * (length_mm/2 - grub_screw_axial_offset_mm)])
          rotate([0, 90, 0])
          cylinder(r=grub_screw_hole_diameter_mm/2, h=grub_screw_hole_depth_mm + grub_screw_overlap_mm, center=true, $fn=32);
        translate([0, outer_diameter_mm/2 - (grub_screw_hole_depth_mm + grub_screw_overlap_mm)/2, i * (length_mm/2 - grub_screw_axial_offset_mm)])
          rotate([90, 0, 0])
          cylinder(r=grub_screw_hole_diameter_mm/2, h=grub_screw_hole_depth_mm + grub_screw_overlap_mm, center=true, $fn=32);
      }
    }
  }
}

// Assembly
module assembly() {
  shaft_coupling();
  if (flexible == 1) {
    translate([0, 0, 0]) flex();
  }
}

assembly();