// Parameters
stator_diameter_mm = 23.0; //[12.0:46.0:0.5]
stator_height_mm = 12.0; //[6.0:24.0:0.5]
stator_inner_bore_diameter_mm = 5.0; //[2.5:10.0:0.25]
outer_can_diameter_mm = 25.0; //[13.0:50.0:0.5]
outer_can_height_mm = 14.0; //[7.0:28.0:0.5]
clearance_mm = 0.2; //[0.0:1.0:0.05]
outer_can_wall_mm = 0.8; //[0.4:2.0:0.1]
connect_overlap_mm = 1.0; //[0.5:2.0:0.1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 6.0; //[3.0:12.0:0.5]
buzzer_inner_radius_mm = 1.0; //[0.5:2.0:0.1]
buzzer_pin_diameter_mm = 2.0; //[1.0:3.0:0.1]
buzzer_pin_height_offset_mm = 3.0; //[1.0:6.0:0.5]
bridge_thickness_mm = 2.0; //[1.0:4.0:0.25]
bridge_width_mm = 4.0; //[2.0:10.0:0.5]

// Buzzer - complete geometry
module buzzer() {
  color([0.15, 0.2, 0.35]) {
    // Buzzer body
    difference() {
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=buzzer_inner_radius_mm, h=buzzer_height_mm + 2*connect_overlap_mm, center=true);
    }
    // Buzzer pin
    translate([0, 0, (-buzzer_height_mm/2) + (max(buzzer_height_mm - buzzer_pin_height_offset_mm, connect_overlap_mm))/2])
      cylinder(r=buzzer_pin_diameter_mm/2, h=max(buzzer_height_mm - buzzer_pin_height_offset_mm, connect_overlap_mm), center=true);
  }
}

// Assembly
module assembly() {
  // Stator
  color("DimGray") {
    difference() {
      cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true);
      cylinder(r=stator_inner_bore_diameter_mm/2, h=stator_height_mm + 2*connect_overlap_mm, center=true);
    }
  }
  
  // Outer can
  color("Silver") {
    difference() {
      cylinder(r=outer_can_diameter_mm/2, h=outer_can_height_mm, center=true);
      cylinder(r=outer_can_diameter_mm/2 - outer_can_wall_mm, h=outer_can_height_mm + 2*connect_overlap_mm, center=true);
    }
  }
  
  // Buzzer with bridge
  translate([outer_can_diameter_mm/2 + clearance_mm + buzzer_diameter_mm/2 - connect_overlap_mm, 0, 0]) {
    buzzer();
    // Bridge
    translate([-(clearance_mm + 2*connect_overlap_mm)/2 + connect_overlap_mm, 0, 0])
      color("Black") cube([clearance_mm + 2*connect_overlap_mm, bridge_width_mm, bridge_thickness_mm], center=true);
  }
}

assembly();