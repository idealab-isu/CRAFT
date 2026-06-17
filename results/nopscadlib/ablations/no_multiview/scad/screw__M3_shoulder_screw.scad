// Parameters
shaft_diameter_mm = 4.0; //[2.0:8.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 7.0; //[3.5:14.0:0.1]
head_height_mm = 2.4; //[1.2:4.8:0.1]
overlap_mm = 1.2; //[0.5:2.0:0.1]  // use 1-2mm to guarantee connection

washer_outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.0:0.1]

spacer_height_mm = 6.0; //[3.0:12.0:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]

buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 6.0; //[3.0:12.0:0.5]

// Derived
shaft_len_mm = length_mm - head_height_mm;

// Radii
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;
washer_r = washer_outer_diameter_mm/2;

spacer_outer_r = shaft_r + spacer_wall_mm;
buzzer_r = buzzer_diameter_mm/2;

// Z positions (centered primitives), with guaranteed overlaps
z_shaft_center  = shaft_len_mm/2;                                  // shaft spans [0 .. shaft_len]
z_head_center   = shaft_len_mm + head_height_mm/2 - overlap_mm;     // overlaps into shaft
z_washer_center = shaft_len_mm - washer_thickness_mm/2 + overlap_mm;// overlaps into shaft (under head)
z_spacer_center = -spacer_height_mm/2 + overlap_mm;                // overlaps into shaft at z=0

// Buzzer attachment: ensure it intersects BOTH spacer and screw assembly.
// 1) Radial overlap into spacer wall
buzzer_attach_overlap_mm = overlap_mm;
buzzer_center_x = spacer_outer_r + buzzer_r - buzzer_attach_overlap_mm;

// 2) Vertical overlap into washer/head region so it cannot float relative to screw
// Place buzzer so its bottom slightly intersects the washer top (or head underside).
// Washer top Z = (z_washer_center + washer_thickness/2)
z_washer_top = z_washer_center + washer_thickness_mm/2;
z_buzzer_center = z_washer_top + buzzer_height_mm/2 - overlap_mm;

// Screw and Washer - complete geometry
module screw_and_washer() {
  // Shaft
  translate([0, 0, z_shaft_center])
    cylinder(h=shaft_len_mm, r=shaft_r, center=true);

  // Head (overlaps shaft)
  translate([0, 0, z_head_center])
    cylinder(h=head_height_mm, r=head_r, center=true);

  // Washer (overlaps shaft)
  difference() {
    translate([0, 0, z_washer_center])
      cylinder(h=washer_thickness_mm, r=washer_r, center=true);
    translate([0, 0, z_washer_center])
      cylinder(h=washer_thickness_mm + 2*overlap_mm, r=shaft_r, center=true);
  }
}

// PCB Spacer - complete geometry (overlaps shaft at z=0)
module pcb_spacer() {
  difference() {
    translate([0, 0, z_spacer_center])
      cylinder(h=spacer_height_mm, r=spacer_outer_r, center=true);
    translate([0, 0, z_spacer_center])
      cylinder(h=spacer_height_mm + 2*overlap_mm, r=shaft_r, center=true);
  }
}

// Buzzer - attached with radial overlap into spacer AND vertical overlap into washer/head
module buzzer() {
  translate([buzzer_center_x, 0, z_buzzer_center])
    cylinder(h=buzzer_height_mm, r=buzzer_r, center=true);
}

// Assembly (single connected solid)
module assembly() {
  union() {
    // Colors kept for preview; union ensures one connected solid
    color("DimGray") screw_and_washer();
    color("Silver")  pcb_spacer();
    color("Black")   buzzer();
  }
}

assembly();