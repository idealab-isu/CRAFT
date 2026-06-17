// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
overall_length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 5.7; //[3.0:11.4:0.1]
head_height_mm = 1.65; //[0.8:3.3:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]
thread_major_radius_mm = 1.5; //[0.75:3.0:0.05]
head_radius_mm = 2.85; //[1.5:5.7:0.05]
socket_af_mm = 2.5; //[1.5:4.0:0.1]
socket_depth_mm = 1.2; //[0.6:2.4:0.1]
washer_outer_diameter_mm = 7.0; //[4.0:14.0:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.05]
washer_hole_diameter_mm = 3.4; //[3.1:4.5:0.05]
spacer_height_mm = 6.0; //[3.0:12.0:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_inner_diameter_mm = 3.4; //[3.1:4.5:0.05]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 5.0; //[2.5:10.0:0.5]
buzzer_stem_diameter_mm = 3.0; //[1.5:6.0:0.1]
buzzer_stem_height_mm = 2.0; //[1.0:4.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Threaded Shaft
    translate([0, 0, -overall_length_mm/2])
      cylinder(h=overall_length_mm, r=thread_diameter_mm/2, center=true, $fn=32);
    
    // Dome Head
    intersection() {
      translate([0, 0, head_height_mm - head_diameter_mm/2])
        sphere(r=head_diameter_mm/2, $fn=32);
      translate([0, 0, head_height_mm - head_diameter_mm])
        cube([head_diameter_mm*2, head_diameter_mm*2, head_diameter_mm*2], center=true);
    }
    translate([0, 0, head_height_mm/2])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true, $fn=32);
    
    // Hex Socket Recess
    translate([0, 0, head_height_mm - socket_depth_mm/2])
      rotate([0, 0, 0])
        difference() {
          cylinder(h=socket_depth_mm + overlap_mm, r=(socket_af_mm/cos(30))/2, center=true, $fn=6);
        }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm/2])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true, $fn=32);
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm/2])
        cylinder(h=washer_thickness_mm + overlap_mm*2, r=washer_hole_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([0, 0, -washer_thickness_mm - spacer_height_mm/2 + overlap_mm])
        cylinder(h=spacer_height_mm, r=spacer_inner_diameter_mm/2 + spacer_wall_mm, center=true, $fn=32);
      translate([0, 0, -washer_thickness_mm - spacer_height_mm/2 + overlap_mm])
        cylinder(h=spacer_height_mm + overlap_mm*2, r=spacer_inner_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    // Buzzer Body
    translate([0, 0, -washer_thickness_mm - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true, $fn=32);
    
    // Buzzer Stem
    translate([0, 0, -washer_thickness_mm - spacer_height_mm + buzzer_stem_height_mm/2 - overlap_mm/2])
      cylinder(h=buzzer_stem_height_mm, r=buzzer_stem_diameter_mm/2, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();