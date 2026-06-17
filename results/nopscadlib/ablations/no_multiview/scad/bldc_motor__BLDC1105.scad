// Parameters
stator_diameter = 14.0; //[7.0:28.0:0.1]
stator_height = 11.75; //[5.875:23.5:0.05]
stator_bore_diameter = 5.0; //[2.5:10.0:0.1]
rotor_outer_diameter = 15.0; //[7.5:30.0:0.1]
rotor_height = 12.5; //[6.25:25.0:0.05]
air_gap_radial = 0.25; //[0.1:0.8:0.05]
shaft_diameter = 2.0; //[1.0:4.0:0.05]
shaft_length_above = 10.0; //[5.0:20.0:0.5]
shaft_length_below = 5.0; //[2.5:10.0:0.5]
base_face_thickness = 1.0; //[0.5:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
rotor_can_wall = 0.6; //[0.3:1.2:0.05]
buzzer_diameter = 10.0; //[5.0:20.0:0.5]
buzzer_height = 5.0; //[2.5:10.0:0.5]
buzzer_pin_diameter = 2.0; //[1.0:3.0:0.1]
buzzer_pin_height = 2.0; //[0.5:5.0:0.1]

// Buzzer - complete geometry
module buzzer() {
  color([0.85, 0.85, 0.8]) {
    // Buzzer body
    translate([stator_diameter/2 + buzzer_diameter/2 - overlap, 0, -stator_height/2 - base_face_thickness + buzzer_height/2])
      cylinder(r=buzzer_diameter/2, h=buzzer_height, center=true);
    // Buzzer pin
    translate([stator_diameter/2 + buzzer_diameter/2 - overlap, 0, -stator_height/2 - base_face_thickness + buzzer_height/2 + buzzer_pin_height/2 - overlap])
      cylinder(r=buzzer_pin_diameter/2, h=buzzer_pin_height, center=true);
  }
}

// Motor assembly
module assembly() {
  color("DimGray") {
    // Stator core
    difference() {
      translate([0, 0, 0])
        cylinder(r=stator_diameter/2, h=stator_height, center=true);
      translate([0, 0, 0])
        cylinder(r=stator_bore_diameter/2, h=stator_height + 2*overlap, center=true);
    }
    // Rotor can
    translate([0, 0, (stator_height - rotor_height)/2])
      difference() {
        cylinder(r=rotor_outer_diameter/2, h=rotor_height, center=true);
        cylinder(r=rotor_outer_diameter/2 - rotor_can_wall, h=rotor_height + 2*overlap, center=true);
      }
    // Central shaft
    translate([0, 0, (shaft_length_above - shaft_length_below - base_face_thickness)/2])
      cylinder(r=shaft_diameter/2, h=shaft_length_above + stator_height + base_face_thickness + shaft_length_below, center=true);
    // Mounting base face
    translate([0, 0, -stator_height/2 - base_face_thickness/2 + overlap])
      cube([stator_diameter + 2*base_face_thickness, stator_diameter + 2*base_face_thickness, base_face_thickness], center=true);
  }
  // Buzzer
  buzzer();
}

// Final assembly
assembly();