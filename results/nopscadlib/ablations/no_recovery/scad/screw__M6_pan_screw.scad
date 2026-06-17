// Parameters
shank_diameter_mm = 6; //[3:12:0.1]
head_diameter_mm = 12; //[6:24:0.1]
head_height_mm = 4.75; //[2.375:9.5:0.05]
length_under_head_mm = 10; //[5:20:0.1]
threaded = 0; //[0:1:1]
overlap_mm = 0.8; //[0.2:2:0.1]
fillet_radius_mm = 0.8; //[0.3:2:0.1]
thread_pitch_mm = 1; //[0.5:2:0.1]
thread_ridge_depth_mm = 0.35; //[0.1:0.8:0.05]
thread_ridge_width_mm = 0.6; //[0.2:1.5:0.05]
thread_ridge_count = 8; //[2:30:1]
washer_outer_diameter_mm = 14; //[8:28:0.1]
washer_thickness_mm = 1.2; //[0.6:3:0.1]
washer_hole_diameter_mm = 6.6; //[6.2:8:0.1]
spacer_height_mm = 6; //[3:15:0.1]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_clearance_diameter_mm = 6.6; //[6.2:8:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 7; //[3.5:14:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shank
    translate([0, 0, -length_under_head_mm/2])
      cylinder(h=length_under_head_mm, r=shank_diameter_mm/2, center=true, $fn=64);
    
    // Pan Head
    translate([0, 0, head_height_mm/2 - overlap_mm])
      rotate_extrude($fn=64)
        polygon(points=[
          [0, 0],
          [head_diameter_mm/2, 0],
          [head_diameter_mm/2, head_height_mm*0.35],
          [head_diameter_mm/2 - head_height_mm*0.55, head_height_mm],
          [0, head_height_mm]
        ]);
    
    // Under-head Fillet
    translate([0, 0, -fillet_radius_mm + overlap_mm])
      rotate_extrude($fn=64)
        translate([shank_diameter_mm/2, 0])
          circle(r=fillet_radius_mm*0.6);
    
    // Optional Thread Representation
    if (threaded) {
      for (i = [0:thread_ridge_count-1]) {
        translate([0, 0, -thread_pitch_mm*i - thread_ridge_width_mm/2])
          rotate_extrude($fn=64)
            translate([shank_diameter_mm/2, 0])
              circle(r=thread_ridge_depth_mm);
      }
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, washer_thickness_mm/2 - overlap_mm])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true, $fn=64);
      translate([0, 0, washer_thickness_mm/2 - overlap_mm])
        cylinder(h=washer_thickness_mm + overlap_mm*2, r=washer_hole_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([0, 0, -length_under_head_mm - spacer_height_mm/2 + overlap_mm])
        cylinder(h=spacer_height_mm, r=spacer_clearance_diameter_mm/2 + spacer_wall_mm, center=true, $fn=64);
      translate([0, 0, -length_under_head_mm - spacer_height_mm/2 + overlap_mm])
        cylinder(h=spacer_height_mm + overlap_mm*2, r=spacer_clearance_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -length_under_head_mm - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();