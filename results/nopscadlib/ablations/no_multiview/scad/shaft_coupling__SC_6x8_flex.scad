// Parameters
outer_diameter_mm = 19; //[10:38:0.5]
length_mm = 25; //[12.5:50:0.5]
bore1_diameter_mm = 6; //[3:12:0.1]
bore2_diameter_mm = 8; //[4:16:0.1]
flexible = 1; //[0:1:1]
grub_screw_count = 4; //[2:8:1]
grub_screw_axial_offset_mm = 5; //[2.5:10:0.5]
grub_screw_hole_diameter_mm = 3; //[2:5:0.1]
grub_screw_hole_depth_mm = 6; //[4:12:0.5]
overlap_mm = 1; //[0.5:2:0.1]
helix_turns = 5; //[2:10:1]
helix_cut_width_mm = 1.2; //[0.6:2.5:0.1]
helix_cut_radial_depth_mm = 4; //[2:7:0.5]

// Helical Flexure
module flex() {
  color("Silver") {
    difference() {
      // Outer cylinder
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      
      // Bore 1
      translate([0, 0, -length_mm/4])
        cylinder(r=bore1_diameter_mm/2, h=length_mm/2 + overlap_mm, center=true, $fn=64);
      
      // Bore 2
      translate([0, 0, length_mm/4])
        cylinder(r=bore2_diameter_mm/2, h=length_mm/2 + overlap_mm, center=true, $fn=64);
      
      // Helical cut
      rotate_extrude(angle=-helix_turns*360, $fn=helix_turns*16)
        translate([bore1_diameter_mm/2, 0, 0])
          square([helix_cut_radial_depth_mm, helix_cut_width_mm], center=true);
    }
  }
}

// Shaft Coupling
module shaft_coupling() {
  color("Silver") {
    difference() {
      // Outer cylinder
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      
      // Bore 1
      translate([0, 0, -length_mm/4])
        cylinder(r=bore1_diameter_mm/2, h=length_mm/2 + overlap_mm, center=true, $fn=64);
      
      // Bore 2
      translate([0, 0, length_mm/4])
        cylinder(r=bore2_diameter_mm/2, h=length_mm/2 + overlap_mm, center=true, $fn=64);
      
      // Grub screw holes
      for (i = [0:1]) {
        for (j = [0:1]) {
          rotate([0, 0, j*90])
            translate([0, 0, (i*2-1)*(length_mm/2 - grub_screw_axial_offset_mm)])
              rotate([0, 90, 0])
                cylinder(r=grub_screw_hole_diameter_mm/2, h=outer_diameter_mm + 2*overlap_mm, center=true, $fn=32);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  flex();
  translate([0, 0, 0]) shaft_coupling();
}

assembly();