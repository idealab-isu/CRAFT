// Parameters
shank_diameter_mm = 6.0; //[3.0:12.0:0.1]
under_head_length_mm = 10.0; //[5.0:30.0:0.5]
head_diameter_mm = 10.0; //[6.0:20.0:0.1]
head_height_mm = 6.0; //[3.0:12.0:0.1]
socket_across_flats_mm = 5.0; //[3.0:10.0:0.1]
socket_depth_mm = 4.0; //[2.0:8.0:0.1]
under_head_chamfer_height_mm = 0.8; //[0.0:2.0:0.1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

// Pcb Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    cylinder(r=shank_diameter_mm/2 + 1.8, h=under_head_length_mm/2, center=true);
  }
}

// Screw And Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Shank
      translate([0, 0, -under_head_length_mm/2])
        cylinder(r=shank_diameter_mm/2, h=under_head_length_mm, center=true);
      // Cap Head
      translate([0, 0, head_height_mm/2 - overlap_mm])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
      // Under-head Chamfer
      translate([0, 0, -under_head_chamfer_height_mm/2])
        cylinder(r1=head_diameter_mm/2, r2=shank_diameter_mm/2, h=under_head_chamfer_height_mm, center=true);
    }
    // Hex Socket Recess
    translate([0, 0, head_height_mm - socket_depth_mm/2 - overlap_mm])
      rotate([0, 0, 0])
      cylinder(r=socket_across_flats_mm/(2*cos(30)), h=socket_depth_mm, center=true);
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, head_height_mm + (head_height_mm/4) - overlap_mm])
      cylinder(r=head_diameter_mm/2, h=head_height_mm/2, center=true);
  }
}

// Pin Socket - complete geometry
module pin_socket() {
  color([0.2, 0.2, 0.2]) {
    translate([head_diameter_mm/2 - overlap_mm, 0, head_height_mm + (head_height_mm/4) - overlap_mm])
      cube([head_diameter_mm, head_diameter_mm/2, head_height_mm/2], center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -under_head_length_mm - (under_head_length_mm/4) + overlap_mm]) pcb_spacer();
  buzzer();
  pin_socket();
}

assembly();