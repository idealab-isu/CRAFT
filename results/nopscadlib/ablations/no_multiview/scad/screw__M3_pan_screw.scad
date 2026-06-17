// Parameters
shaft_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 5.4; //[2.7:10.8:0.1]
head_height_mm = 2; //[1:4:0.1]

// Use 1–2mm overlap to guarantee watertight connections
overlap_mm = 1.2; //[0.2:2:0.1]

washer_outer_diameter_mm = 7; //[4:14:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.5]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
buzzer_body_diameter_mm = 12; //[6:24:0.5]
buzzer_body_height_mm = 7; //[3.5:14:0.5]

// Derived dimensions / Z layout (all centered on Z axis)
shaft_len = length_mm - head_height_mm;

// Place head on top of shaft with overlap
z_shaft_center = 0;
z_head_center  = (shaft_len/2 + head_height_mm/2 - overlap_mm);

// Washer sits under head, overlapping both head and spacer
z_washer_center = (z_head_center - head_height_mm/2 - washer_thickness_mm/2 + overlap_mm);

// Spacer sits under washer, overlapping washer and buzzer
z_spacer_center = (z_washer_center - washer_thickness_mm/2 - pcb_spacer_height_mm/2 + overlap_mm);

// Buzzer sits under spacer, overlapping spacer
z_buzzer_center = (z_spacer_center - pcb_spacer_height_mm/2 - buzzer_body_height_mm/2 + overlap_mm);

// Screw and Washer - connected geometry
module screw_and_washer() {
  // Shaft
  color("DimGray")
    translate([0, 0, z_shaft_center])
      cylinder(h=shaft_len, r=shaft_diameter_mm/2, center=true);

  // Pan Head (overlaps shaft)
  color("DimGray")
    translate([0, 0, z_head_center])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);

  // Washer (overlaps head and spacer)
  color("DimGray")
    difference() {
      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=shaft_diameter_mm/2 + overlap_mm/4, center=true);
    }
}

// PCB Spacer - connected to washer and provides through-hole for shaft
module pcb_spacer() {
  color("Silver")
    difference() {
      translate([0, 0, z_spacer_center])
        cylinder(h=pcb_spacer_height_mm, r=shaft_diameter_mm/2 + pcb_spacer_wall_mm, center=true);
      translate([0, 0, z_spacer_center])
        cylinder(h=pcb_spacer_height_mm + 2*overlap_mm, r=shaft_diameter_mm/2 + overlap_mm/4, center=true);
    }
}

// Buzzer - connected to spacer (slight overlap)
module buzzer() {
  color("Black")
    translate([0, 0, z_buzzer_center])
      cylinder(h=buzzer_body_height_mm, r=buzzer_body_diameter_mm/2, center=true);
}

// Assembly - single connected solid
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();
  }
}

assembly();