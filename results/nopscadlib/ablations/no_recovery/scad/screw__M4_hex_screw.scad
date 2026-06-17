// Parameters
shank_diameter_mm = 4.0; //[2.0:8.0:0.1]
length_under_head_mm = 10.0; //[5.0:20.0:0.5]
head_across_flats_mm = 8.1; //[4.0:16.2:0.1]
head_height_mm = 2.925; //[1.5:6.0:0.025]
thread_length_mm = 10.0; //[0.0:20.0:0.5]
thread_major_diameter_mm = 4.0; //[2.0:8.0:0.1]
thread_minor_diameter_mm = 3.4; //[1.6:7.0:0.1]
thread_pitch_mm = 0.7; //[0.4:1.5:0.05]
thread_ring_thickness_mm = 0.25; //[0.1:0.6:0.05]
under_head_chamfer_height_mm = 0.6; //[0.2:1.5:0.05]
under_head_chamfer_radial_mm = 0.6; //[0.2:1.5:0.05]
tip_chamfer_height_mm = 0.8; //[0.2:2.0:0.05]
overlap_mm = 0.8; //[0.2:2.0:0.1]
placeholder_size_mm = 0.01; //[0.001:0.1:0.001]

// Hex Head
module hex_head() {
  color("DimGray") {
    translate([0, 0, head_height_mm/2])
      cylinder(h=head_height_mm, r=head_across_flats_mm/(2*cos(30)), center=true, $fn=6);
  }
}

// Shank
module shank() {
  color("Silver") {
    translate([0, 0, -length_under_head_mm/2])
      cylinder(h=length_under_head_mm, r=shank_diameter_mm/2, center=true);
  }
}

// Under Head Fillet or Chamfer
module under_head_fillet_or_chamfer() {
  color("Silver") {
    translate([0, 0, -under_head_chamfer_height_mm/2 + overlap_mm/2])
      cylinder(h=under_head_chamfer_height_mm, r1=shank_diameter_mm/2 + under_head_chamfer_radial_mm, r2=shank_diameter_mm/2, center=true);
  }
}

// Tip Chamfer
module tip_chamfer() {
  color("Silver") {
    translate([0, 0, -length_under_head_mm + tip_chamfer_height_mm/2 - overlap_mm/2])
      cylinder(h=tip_chamfer_height_mm, r1=shank_diameter_mm/2, r2=shank_diameter_mm/2 - tip_chamfer_height_mm/2, center=true);
  }
}

// Threaded Section
module threaded_section() {
  color("Silver") {
    union() {
      translate([0, 0, -length_under_head_mm + thread_length_mm/2])
        cylinder(h=thread_length_mm, r=thread_major_diameter_mm/2, center=true);
      for (i = [0:9]) {
        translate([0, 0, -length_under_head_mm + i*thread_pitch_mm + thread_ring_thickness_mm/2])
          cylinder(h=thread_ring_thickness_mm, r=thread_major_diameter_mm/2, center=true);
      }
    }
  }
}

// PCB Spacer
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(h=10, r=5, center=true);
      translate([0, 0, -5])
        cylinder(h=10, r=3.2, center=true);
    }
  }
}

// Screw and Washer
module screw_and_washer() {
  color("Silver") {
    union() {
      translate([0, 0, 1])
        cylinder(h=1, r=6, center=true);
      translate([0, 0, 0.5])
        cylinder(h=10, r=2, center=true);
    }
  }
}

// Buzzer
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    difference() {
      cylinder(h=5, r=10, center=true);
      translate([0, 0, -2.5])
        cylinder(h=5, r=8, center=true);
    }
  }
}

// Assembly
module assembly() {
  union() {
    hex_head();
    shank();
    under_head_fillet_or_chamfer();
    tip_chamfer();
    threaded_section();
    translate([0, 0, -length_under_head_mm - 5]) pcb_spacer();
    translate([0, 0, -length_under_head_mm - 15]) screw_and_washer();
    translate([0, 0, -length_under_head_mm - 25]) buzzer();
  }
}

assembly();