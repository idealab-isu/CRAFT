// Parameters
shaft_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 10; //[5:20:0.5]
head_across_flats_mm = 6.4; //[3.2:12.8:0.1]
head_height_mm = 2.125; //[1.0625:4.25:0.025]
washer_outer_diameter_mm = 7; //[4:14:0.1]
washer_thickness_mm = 0.8; //[0.4:2:0.05]
washer_hole_clearance_mm = 0.3; //[0.1:0.8:0.05]
spacer_height_mm = 6; //[3:12:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_clearance_mm = 0.3; //[0.1:0.8:0.05]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 7; //[3.5:14:0.5]
buzzer_offset_x_mm = 10; //[5:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Derived
shaft_r  = shaft_diameter_mm/2;
head_r   = head_across_flats_mm/(2*cos(30)); // circumscribed radius for $fn=6
washer_r = washer_outer_diameter_mm/2;

// Z layout (non-centered solids for robust stacking)
z_head_bottom   = 0;
z_head_top      = z_head_bottom + head_height_mm;

// FIX: make the shank start inside the head and extend down to full length.
// This guarantees a real overlap/merge with the head (no tangential contact).
z_shank_top     = z_head_top - overlap_mm;          // inside head by overlap_mm
z_shank_bottom  = z_head_top - length_mm;           // overall screw length from head top to tip
shank_h         = z_shank_top - z_shank_bottom;     // = length_mm - overlap_mm

// Washer under head, overlapping into head by overlap_mm
z_washer_top    = z_head_bottom + overlap_mm;
z_washer_bottom = z_washer_top - washer_thickness_mm;

// Spacer under washer, overlapping into washer by overlap_mm
z_spacer_top    = z_washer_bottom + overlap_mm;
z_spacer_bottom = z_spacer_top - spacer_height_mm;

// Place buzzer so it physically intersects the head on the side by ~overlap_mm
buzzer_x = head_r + buzzer_diameter_mm/2 - overlap_mm;
buzzer_z = (z_head_bottom + z_head_top)/2;

// Screw and Washer - fused geometry
module screw_and_washer() {
  union() {
    // Hex Head (base at z=0)
    color("DimGray")
      rotate([0, 0, 30])
        translate([0, 0, z_head_bottom])
          cylinder(h=head_height_mm, r=head_r, center=false, $fn=6);

    // Shank (overlaps into head by overlap_mm; full length measured from head top)
    color("DimGray")
      translate([0, 0, z_shank_bottom])
        cylinder(h=shank_h, r=shaft_r, center=false);

    // Washer (overlaps into head by overlap_mm)
    color("DimGray")
      difference() {
        translate([0, 0, z_washer_bottom])
          cylinder(h=washer_thickness_mm, r=washer_r, center=false);
        translate([0, 0, z_washer_bottom - overlap_mm])
          cylinder(h=washer_thickness_mm + 2*overlap_mm,
                   r=(shaft_diameter_mm + washer_hole_clearance_mm)/2,
                   center=false);
      }
  }
}

// PCB Spacer - positioned to overlap washer by overlap_mm
module pcb_spacer() {
  color("Silver")
    difference() {
      translate([0, 0, z_spacer_bottom])
        cylinder(h=spacer_height_mm,
                 r=(shaft_r + spacer_clearance_mm) + spacer_wall_mm,
                 center=false);
      translate([0, 0, z_spacer_bottom - overlap_mm])
        cylinder(h=spacer_height_mm + 2*overlap_mm,
                 r=(shaft_r + spacer_clearance_mm),
                 center=false);
    }
}

// Buzzer - positioned to intersect the hex head (no floating)
module buzzer() {
  color("Black")
    translate([buzzer_x, 0, buzzer_z - buzzer_height_mm/2])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=false);
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