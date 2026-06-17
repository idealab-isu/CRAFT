// Parameters
shank_diameter_mm = 3.5; //[1.75:7:0.1]
length_under_head_mm = 10; //[5:20:0.1]
head_diameter_mm = 6.9; //[3.45:13.8:0.1]
head_height_mm = 2.5; //[1.25:5:0.1]
tolerance_diameter_mm = 0; //[-0.2:0.2:0.01]
tolerance_length_mm = 0; //[-0.5:0.5:0.01]
overlap_mm = 0.8; //[0.2:2:0.1]
under_head_fillet_radius_mm = 0.6; //[0.2:1.5:0.1]
tip_chamfer_height_mm = 1.2; //[0.5:3:0.1]
spacer_height_mm = 4; //[2:12:0.1]
spacer_wall_mm = 1.8; //[0.8:3.6:0.1]
washer_thickness_mm = 1; //[0.5:2.5:0.1]
washer_outer_diameter_mm = 8; //[5:16:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 6; //[3:15:0.1]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    cylinder(r=((shank_diameter_mm + tolerance_diameter_mm)/2) + spacer_wall_mm, 
             h=spacer_height_mm, center=true);
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shank
    translate([0, 0, -(length_under_head_mm + tolerance_length_mm)/2])
      cylinder(r=(shank_diameter_mm + tolerance_diameter_mm)/2, 
               h=length_under_head_mm + tolerance_length_mm, center=true);
    
    // Pan Head
    translate([0, 0, (head_height_mm + tolerance_length_mm)/2 - overlap_mm])
      cylinder(r=(head_diameter_mm + tolerance_diameter_mm)/2, 
               h=head_height_mm + tolerance_length_mm, center=true);
    
    // Under Head Fillet
    translate([0, 0, -overlap_mm])
      rotate_extrude() 
        translate([((shank_diameter_mm + tolerance_diameter_mm)/2) + under_head_fillet_radius_mm, 0])
          circle(r=under_head_fillet_radius_mm);
    
    // Tip Chamfer
    translate([0, 0, -(length_under_head_mm + tolerance_length_mm) + tip_chamfer_height_mm/2 + overlap_mm])
      cylinder(r1=(shank_diameter_mm + tolerance_diameter_mm)/2, r2=0, 
               h=tip_chamfer_height_mm, center=true);
    
    // Washer
    translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
      cylinder(r=(washer_outer_diameter_mm + tolerance_diameter_mm)/2, 
               h=washer_thickness_mm, center=true);
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, -(length_under_head_mm + tolerance_length_mm) - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(r=(buzzer_diameter_mm + tolerance_diameter_mm)/2, 
               h=buzzer_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();