// Parameters
shaft_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 5.5; //[2.75:11:0.1]
head_height_mm = 2; //[1:4:0.1]
thread_depth_mm = 0.2; //[0.1:0.5:0.05]
thread_pitch_mm = 0.5; //[0.3:1:0.05]
threaded_fraction = 1; //[0.5:1:0.05]
washer_outer_diameter_mm = 7; //[4:14:0.1]
washer_thickness_mm = 0.8; //[0.4:2:0.05]
washer_hole_clearance_mm = 0.3; //[0.1:0.8:0.05]
spacer_height_mm = 6; //[3:12:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_hole_clearance_mm = 0.4; //[0.2:1:0.05]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 7; //[3.5:14:0.5]
buzzer_post_diameter_mm = 2; //[1:4:0.1]
buzzer_post_height_mm = 3; //[1.5:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// --- Z reference (all parts stacked downward from head top) ---
// Place head with its TOP at z=0 (not centered), then stack parts below with overlap.
z_head_top = 0;
z_head_bottom = z_head_top - head_height_mm;

z_washer_top = z_head_bottom + overlap_mm;
z_washer_bottom = z_washer_top - washer_thickness_mm;

z_spacer_top = z_washer_bottom + overlap_mm;
z_spacer_bottom = z_spacer_top - spacer_height_mm;

z_post_top = z_spacer_bottom + overlap_mm;
z_post_bottom = z_post_top - buzzer_post_height_mm;

z_buzzer_top = z_post_bottom + overlap_mm;
z_buzzer_bottom = z_buzzer_top - buzzer_height_mm;

// Shaft runs from just under head down to length, overlapping into head.
z_shaft_top = z_head_bottom + overlap_mm;
z_shaft_bottom = z_shaft_top - length_mm;

// Screw and Washer
module screw_and_washer() {
  color("DimGray") {
    // Pan Head (top at z=0)
    translate([0, 0, z_head_top - head_height_mm/2])
      cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=64);

    // Threaded Shaft (overlaps into head by overlap_mm)
    union() {
      translate([0, 0, (z_shaft_top + z_shaft_bottom)/2])
        cylinder(r=shaft_diameter_mm/2, h=length_mm, center=true, $fn=64);

      translate([0, 0, (z_shaft_top + z_shaft_bottom)/2])
        cylinder(r=shaft_diameter_mm/2 + thread_depth_mm, h=length_mm*threaded_fraction, center=true, $fn=64);
    }

    // Washer (touches head underside with overlap)
    difference() {
      translate([0, 0, (z_washer_top + z_washer_bottom)/2])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=64);

      translate([0, 0, (z_washer_top + z_washer_bottom)/2])
        cylinder(r=(shaft_diameter_mm + washer_hole_clearance_mm)/2,
                 h=washer_thickness_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// PCB Spacer
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([0, 0, (z_spacer_top + z_spacer_bottom)/2])
        cylinder(r=(shaft_diameter_mm + spacer_hole_clearance_mm)/2 + spacer_wall_mm,
                 h=spacer_height_mm, center=true, $fn=64);

      translate([0, 0, (z_spacer_top + z_spacer_bottom)/2])
        cylinder(r=(shaft_diameter_mm + spacer_hole_clearance_mm)/2,
                 h=spacer_height_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// Buzzer
module buzzer() {
  color("Black") {
    // Buzzer Post (overlaps into spacer)
    translate([0, 0, (z_post_top + z_post_bottom)/2])
      cylinder(r=buzzer_post_diameter_mm/2, h=buzzer_post_height_mm, center=true, $fn=64);

    // Buzzer Body (large black cylinder/base) overlaps into post
    translate([0, 0, (z_buzzer_top + z_buzzer_bottom)/2])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=64);
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();
  }
}

assembly();