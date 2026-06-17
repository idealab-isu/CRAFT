// Parameters
shank_diameter_mm = 2.2; //[1.1:4.4:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 4.2; //[2.1:8.4:0.1]
head_height_mm = 1.7; //[0.85:3.4:0.05]
overlap_mm = 1.2; //[0.2:2:0.1]   // ensure 1–2mm overlap for solid connections
head_rounding_factor = 0.55; //[0.2:1:0.05]
washer_thickness_mm = 0.6; //[0.3:1.2:0.05]
washer_outer_diameter_mm = 5.2; //[3:10.4:0.1]
spacer_height_mm = 6; //[3:12:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
buzzer_radius_mm = 6; //[3:12:0.5]
buzzer_height_mm = 5; //[2.5:10:0.5]

// Derived Z stack (all parts centered on Z, then positioned so faces overlap)
shank_h = length_mm - head_height_mm;

// Place head top at +length/2, shank bottom at -length/2
z_head =  length_mm/2 - head_height_mm/2;
z_shank = -length_mm/2 + shank_h/2;

// Washer sits directly under head, overlapping into head by overlap_mm
z_washer = (z_head - head_height_mm/2) - washer_thickness_mm/2 + overlap_mm;

// Spacer sits under washer, overlapping into washer by overlap_mm
z_spacer = (z_washer - washer_thickness_mm/2) - spacer_height_mm/2 + overlap_mm;

// Buzzer sits under spacer, overlapping into spacer by overlap_mm
z_buzzer = (z_spacer - spacer_height_mm/2) - buzzer_height_mm/2 + overlap_mm;

// Screw and Washer - connected geometry
module screw_and_washer() {
  color("DimGray")
  union() {
    // Shank (overlaps into head by overlap_mm)
    translate([0, 0, z_shank + overlap_mm/2])
      cylinder(h=shank_h + overlap_mm, r=shank_diameter_mm/2, center=true);

    // Pan Head (overlaps into shank by overlap_mm)
    translate([0, 0, z_head - overlap_mm/2])
      union() {
        cylinder(h=head_height_mm + overlap_mm, r=head_diameter_mm/2, center=true);
        translate([0, 0, head_height_mm/2 - (head_height_mm*head_rounding_factor)])
          sphere(r=(head_diameter_mm/2) - (head_height_mm*head_rounding_factor), center=true);
      }

    // Washer (touches/overlaps head underside by overlap_mm)
    translate([0, 0, z_washer])
      difference() {
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        cylinder(h=washer_thickness_mm + overlap_mm, r=shank_diameter_mm/2 + overlap_mm/4, center=true);
      }
  }
}

// PCB Spacer - connected geometry
module pcb_spacer() {
  color("Silver")
  translate([0, 0, z_spacer])
    difference() {
      cylinder(h=spacer_height_mm, r=(shank_diameter_mm/2) + spacer_wall_mm, center=true);
      cylinder(h=spacer_height_mm + overlap_mm, r=shank_diameter_mm/2 + overlap_mm/4, center=true);
    }
}

// Buzzer - connected geometry
module buzzer() {
  color("Black")
  translate([0, 0, z_buzzer])
    cylinder(h=buzzer_height_mm, r=buzzer_radius_mm, center=true);
}

// Assembly (single solid union for connectivity)
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();
  }
}

assembly();