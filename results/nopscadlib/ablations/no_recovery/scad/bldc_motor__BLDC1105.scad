// Parameters
stator_diameter_mm = 14.0; //[7.0:28.0:0.25]
stator_height_mm = 11.75; //[5.875:23.5:0.25]
stator_center_bore_diameter_mm = 0.0; //[0.0:6.0:0.25]
rotor_can_wall_thickness_mm = 0.5; //[0.25:2.0:0.05]
rotor_can_clearance_mm = 0.25; //[0.1:1.0:0.05]
shaft_diameter_mm = 0.0; //[0.0:6.0:0.25]
shaft_length_mm = 0.0; //[0.0:30.0:0.5]
connect_overlap_mm = 1.0; //[0.5:2.0:0.1]
envelope_extra_radius_mm = 0.3; //[0.0:2.0:0.05]
envelope_extra_height_mm = 0.5; //[0.0:5.0:0.1]
mount_face_ring_radial_mm = 1.0; //[0.5:4.0:0.1]
mount_face_ring_thickness_mm = 0.8; //[0.4:3.0:0.1]
buzzer_diameter_mm = 8.0; //[4.0:16.0:0.5]
buzzer_height_mm = 5.0; //[2.5:12.0:0.5]
buzzer_pin_diameter_mm = 2.0; //[1.0:3.0:0.25]
buzzer_pin_height_mm = 2.0; //[0.5:6.0:0.25]

// Buzzer - complete geometry
module buzzer() {
  color([0.2, 0.2, 0.2]) {
    // Buzzer body
    translate([stator_diameter_mm/2 + rotor_can_clearance_mm + rotor_can_wall_thickness_mm + buzzer_diameter_mm/2 - connect_overlap_mm, 0, 0])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
    // Buzzer pin
    translate([stator_diameter_mm/2 + rotor_can_clearance_mm + rotor_can_wall_thickness_mm + buzzer_diameter_mm/2 - connect_overlap_mm, 0, buzzer_height_mm/2 + buzzer_pin_height_mm/2 - connect_overlap_mm])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true, $fn=16);
  }
}

// Assembly - combines all parts
module assembly() {
  // Stator cylinder
  color("DimGray") translate([0, 0, 0])
    cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true, $fn=64);

  // Rotor can
  color("Black") difference() {
    translate([0, 0, 0])
      cylinder(r=stator_diameter_mm/2 + rotor_can_clearance_mm + rotor_can_wall_thickness_mm, h=stator_height_mm, center=true, $fn=64);
    translate([0, 0, 0])
      cylinder(r=stator_diameter_mm/2 + rotor_can_clearance_mm, h=stator_height_mm + 2*connect_overlap_mm, center=true, $fn=64);
  }

  // Motor envelope
  color([0.15, 0.15, 0.17]) translate([0, 0, 0])
    cylinder(r=stator_diameter_mm/2 + rotor_can_clearance_mm + rotor_can_wall_thickness_mm + envelope_extra_radius_mm, h=stator_height_mm + envelope_extra_height_mm, center=true, $fn=64);

  // Shaft stub
  if (shaft_diameter_mm > 0) {
    color("Silver") translate([0, 0, stator_height_mm/2 + max(shaft_length_mm, connect_overlap_mm)/2 - connect_overlap_mm])
      cylinder(r=max(shaft_diameter_mm, connect_overlap_mm)/2, h=max(shaft_length_mm, connect_overlap_mm), center=true, $fn=16);
  }

  // Mounting face reference
  color("Silver") difference() {
    translate([0, 0, stator_height_mm/2 - mount_face_ring_thickness_mm/2 + connect_overlap_mm])
      cylinder(r=stator_diameter_mm/2 + rotor_can_clearance_mm + rotor_can_wall_thickness_mm + mount_face_ring_radial_mm, h=mount_face_ring_thickness_mm, center=true, $fn=64);
    translate([0, 0, stator_height_mm/2 - mount_face_ring_thickness_mm/2 + connect_overlap_mm])
      cylinder(r=stator_diameter_mm/2 + rotor_can_clearance_mm + rotor_can_wall_thickness_mm, h=mount_face_ring_thickness_mm + 2*connect_overlap_mm, center=true, $fn=64);
  }

  // Buzzer
  buzzer();
}

// Final assembly call
assembly();