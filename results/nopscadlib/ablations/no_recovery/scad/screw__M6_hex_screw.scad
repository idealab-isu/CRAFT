// Parameters
shaft_diameter = 6.0; //[3.0:12.0:0.1]
shaft_length_under_head = 10.0; //[5.0:20.0:0.1]
head_across_flats = 11.5; //[6.0:23.0:0.1]
head_height = 4.15; //[2.0:8.3:0.05]
chamfer_under_head = 0.3; //[0.1:1.0:0.05]
chamfer_tip = 0.3; //[0.1:1.0:0.05]
overlap = 0.8; //[0.2:2.0:0.1]
washer_thickness = 1.0; //[0.5:3.0:0.1]
washer_outer_diameter = 12.5; //[8.0:25.0:0.1]
washer_inner_clearance = 0.4; //[0.1:1.5:0.05]
buzzer_stub_radius = 2.0; //[1.0:5.0:0.1]
buzzer_stub_height = 2.0; //[1.0:6.0:0.1]

// Hex Head
module hex_head() {
  color("DimGray") {
    translate([0, 0, shaft_length_under_head + head_height / 2])
      cylinder(h = head_height, r = (head_across_flats / 2) / cos(30), center = true, $fn = 6);
  }
}

// Shaft
module shaft() {
  color("Silver") {
    translate([0, 0, shaft_length_under_head / 2])
      cylinder(h = shaft_length_under_head, r = shaft_diameter / 2, center = true);
  }
}

// Under Head Transition Chamfer
module under_head_transition_chamfer() {
  color("DimGray") {
    translate([0, 0, shaft_length_under_head + chamfer_under_head / 2 - overlap])
      cylinder(h = chamfer_under_head, r1 = (head_across_flats / 2) / cos(30), r2 = shaft_diameter / 2, center = true);
  }
}

// Washer Ring
module washer_ring() {
  color("Silver") {
    difference() {
      translate([0, 0, shaft_length_under_head + washer_thickness / 2 - overlap])
        cylinder(h = washer_thickness, r = washer_outer_diameter / 2, center = true);
      translate([0, 0, shaft_length_under_head + washer_thickness / 2 - overlap])
        cylinder(h = washer_thickness + 2 * overlap, r = (shaft_diameter + washer_inner_clearance) / 2, center = true);
    }
  }
}

// Tip Chamfer
module tip_chamfer() {
  color("DimGray") {
    translate([0, 0, chamfer_tip / 2 - overlap])
      cylinder(h = chamfer_tip, r1 = shaft_diameter / 2, r2 = max(shaft_diameter / 2 - chamfer_tip, shaft_diameter / 4), center = true);
  }
}

// Buzzer
module buzzer() {
  color("Black") {
    translate([0, 0, shaft_length_under_head + head_height + buzzer_stub_height / 2 - overlap])
      cylinder(h = buzzer_stub_height, r = buzzer_stub_radius, center = true);
  }
}

// PCB Spacer
module pcb_spacer() {
  color("Silver") {
    translate([0, 0, shaft_length_under_head + washer_thickness / 2 - overlap])
      cylinder(h = washer_thickness, r = washer_outer_diameter / 2, center = true);
  }
}

// Screw and Washer Assembly
module screw_and_washer() {
  union() {
    shaft();
    under_head_transition_chamfer();
    washer_ring();
    hex_head();
    tip_chamfer();
    buzzer();
  }
}

// Final Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
}

assembly();