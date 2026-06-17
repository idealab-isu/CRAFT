// Parameters
stator_diameter_mm = 28.0; //[14.0:56.0:0.5]
stator_height_mm = 17.25; //[8.0:35.0:0.25]
tolerance_mm = 0.2; //[0.0:1.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
central_bore_diameter_mm = 0.0; //[0.0:12.0:0.1]
shaft_diameter_mm = 0.0; //[0.0:12.0:0.1]
end_face_thickness_mm = 1.0; //[0.5:3.0:0.1]
mount_ring_thickness_mm = 2.0; //[1.0:6.0:0.25]
mount_ring_radial_mm = 3.0; //[1.0:10.0:0.25]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 5.0; //[2.0:12.0:0.25]
buzzer_pin_diameter_mm = 2.0; //[1.0:3.0:0.1]
buzzer_pin_height_mm = 2.0; //[0.5:6.0:0.25]

// Buzzer - complete geometry
module buzzer() {
  color([0.85, 0.85, 0.8]) {
    // Buzzer body
    translate([stator_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm, 0, stator_height_mm/2 + buzzer_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
    // Buzzer pin
    translate([stator_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm, 0, stator_height_mm/2 + buzzer_height_mm - overlap_mm])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true, $fn=16);
  }
}

// Stator with end faces and mounting interface
module stator_with_end_faces_and_mount() {
  color("DimGray") {
    // Stator cylinder
    cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true, $fn=64);
    // End face top
    translate([0, 0, stator_height_mm/2 + end_face_thickness_mm/2 - overlap_mm])
      cylinder(r=stator_diameter_mm/2, h=end_face_thickness_mm, center=true, $fn=64);
    // End face bottom
    translate([0, 0, -stator_height_mm/2 - end_face_thickness_mm/2 + overlap_mm])
      cylinder(r=stator_diameter_mm/2, h=end_face_thickness_mm, center=true, $fn=64);
    // Mounting interface
    difference() {
      translate([0, 0, stator_height_mm/2 + mount_ring_thickness_mm/2 - overlap_mm])
        cylinder(r=stator_diameter_mm/2 + mount_ring_radial_mm, h=mount_ring_thickness_mm, center=true, $fn=64);
      translate([0, 0, stator_height_mm/2 + mount_ring_thickness_mm/2 - overlap_mm])
        cylinder(r=stator_diameter_mm/2 - overlap_mm, h=mount_ring_thickness_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// Final assembly
module assembly() {
  difference() {
    union() {
      stator_with_end_faces_and_mount();
      buzzer();
    }
    // Central bore or shaft clearance
    if (max(central_bore_diameter_mm, shaft_diameter_mm) > 0) {
      cylinder(r=max(central_bore_diameter_mm, shaft_diameter_mm)/2 + tolerance_mm, h=stator_height_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

assembly();