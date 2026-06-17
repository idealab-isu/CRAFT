// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
head_across_flats_mm = 15; //[7.5:30:0.1]
head_height_mm = 5.65; //[2.825:11.3:0.05]
length_under_head_mm = 10; //[5:20:0.1]
overlap_mm = 1; //[0.5:2:0.1]
head_to_shank_chamfer_h_mm = 1.2; //[0.6:2.4:0.1]
head_to_shank_chamfer_extra_d_mm = 2; //[1:4:0.1]
tip_chamfer_h_mm = 1.5; //[0.75:3:0.1]
tip_chamfer_end_d_mm = 2; //[0.5:4:0.1]
washer_outer_d_mm = 16; //[8:32:0.1]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_spacer_outer_d_mm = 14; //[7:28:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.1]
buzzer_d_mm = 12; //[6:24:0.1]
buzzer_h_mm = 5; //[2.5:10:0.1]

// Hex Head Screw
module hex_head_screw() {
  union() {
    // Hex Head
    translate([0, 0, length_under_head_mm + head_height_mm / 2])
      cylinder(r=head_across_flats_mm / (2 * cos(30)), h=head_height_mm, center=true, $fn=6);
    
    // Shaft
    translate([0, 0, length_under_head_mm / 2])
      cylinder(r=shaft_diameter_mm / 2, h=length_under_head_mm, center=true);
    
    // Head to Shank Transition
    translate([0, 0, length_under_head_mm - head_to_shank_chamfer_h_mm / 2 + overlap_mm / 2])
      cylinder(r1=(shaft_diameter_mm + head_to_shank_chamfer_extra_d_mm) / 2, r2=shaft_diameter_mm / 2, h=head_to_shank_chamfer_h_mm, center=true);
    
    // Tip Chamfer
    translate([0, 0, tip_chamfer_h_mm / 2 - overlap_mm / 2])
      cylinder(r1=shaft_diameter_mm / 2, r2=tip_chamfer_end_d_mm / 2, h=tip_chamfer_h_mm, center=true);
  }
}

// PCB Spacer
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    translate([0, 0, length_under_head_mm + head_height_mm + pcb_spacer_height_mm / 2 - overlap_mm])
      cylinder(r=pcb_spacer_outer_d_mm / 2, h=pcb_spacer_height_mm, center=true);
  }
}

// Screw and Washer
module screw_and_washer() {
  union() {
    hex_head_screw();
    color("Silver") {
      translate([0, 0, length_under_head_mm + head_height_mm + washer_thickness_mm / 2 - overlap_mm])
        cylinder(r=washer_outer_d_mm / 2, h=washer_thickness_mm, center=true);
    }
  }
}

// Buzzer
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, length_under_head_mm + head_height_mm + pcb_spacer_height_mm + buzzer_h_mm / 2 - overlap_mm])
      cylinder(r=buzzer_d_mm / 2, h=buzzer_h_mm, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();