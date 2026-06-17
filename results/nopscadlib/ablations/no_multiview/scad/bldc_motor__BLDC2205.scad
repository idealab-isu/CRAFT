// Parameters
stator_diameter = 28.0; //[14.0:56.0:0.25]
stator_height = 17.25; //[8.625:34.5:0.25]
central_bore_diameter = 5.0; //[2.5:10.0:0.25]
outer_can_diameter = 30.0; //[15.0:60.0:0.25]
outer_can_height = 18.0; //[9.0:36.0:0.25]
clearance_radial = 0.25; //[0.1:1.0:0.05]
clearance_axial = 0.25; //[0.1:1.0:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
can_wall = 1.0; //[0.6:2.5:0.1]
buzzer_diameter = 12.0; //[6.0:24.0:0.5]
buzzer_height = 6.0; //[3.0:12.0:0.25]
buzzer_pin_diameter = 2.0; //[1.0:4.0:0.25]
buzzer_pin_height = 3.0; //[1.0:8.0:0.25]

// Buzzer - complete geometry
module buzzer() {
  color([0.85, 0.85, 0.8]) {
    // Buzzer body
    translate([0, 0, stator_height/2 + buzzer_height/2 - overlap])
      cylinder(r=buzzer_diameter/2, h=buzzer_height, center=true, $fn=32);
    // Buzzer pin
    translate([0, 0, stator_height/2 + buzzer_height - overlap + buzzer_pin_height/2])
      cylinder(r=buzzer_pin_diameter/2, h=buzzer_pin_height, center=true, $fn=16);
  }
}

// Motor assembly
module assembly() {
  // Stator with central bore
  color("DimGray") {
    difference() {
      translate([0, 0, 0])
        cylinder(r=stator_diameter/2, h=stator_height, center=true, $fn=64);
      translate([0, 0, 0])
        cylinder(r=central_bore_diameter/2, h=stator_height + 2*overlap, center=true, $fn=32);
    }
  }
  
  // Outer can envelope
  color("Black") {
    difference() {
      translate([0, 0, 0])
        cylinder(r=outer_can_diameter/2 + clearance_radial, h=outer_can_height + 2*clearance_axial, center=true, $fn=64);
      translate([0, 0, 0])
        cylinder(r=outer_can_diameter/2 + clearance_radial - can_wall, h=outer_can_height + 2*clearance_axial + 2*overlap, center=true, $fn=64);
    }
  }
  
  // Buzzer
  buzzer();
}

assembly();