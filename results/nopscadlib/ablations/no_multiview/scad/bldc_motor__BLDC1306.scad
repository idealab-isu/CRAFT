// Parameters
stator_diameter_mm = 17.75; //[9:36:0.05]
stator_height_mm = 14.5; //[7:30:0.1]
stator_inner_bore_diameter_mm = 5; //[0:12:0.05]
housing_outer_diameter_mm = 19; //[10:40:0.05]
housing_height_mm = 16; //[8:40:0.1]
base_thickness_mm = 1; //[0.5:3:0.05]
clearance_mm = 0.2; //[0:1:0.05]
housing_wall_thickness_mm = 0.6; //[0.3:2:0.05]
overlap_mm = 0.8; //[0.2:2:0.05]
buzzer_diameter_mm = 10; //[5:20:0.1]
buzzer_height_mm = 5; //[2:12:0.1]
buzzer_pin_diameter_mm = 2; //[1:4:0.05]
buzzer_pin_height_mm = 2; //[0.5:6:0.1]

// Buzzer - complete geometry
module buzzer() {
  color([0.2, 0.2, 0.2]) {
    // Buzzer body
    translate([0, 0, housing_height_mm/2 + buzzer_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
    // Buzzer pin
    translate([0, 0, housing_height_mm/2 + buzzer_height_mm - overlap_mm + buzzer_pin_height_mm/2])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  // Outer housing can
  color([0.75, 0.75, 0.77]) {
    difference() {
      translate([0, 0, 0])
        cylinder(r=housing_outer_diameter_mm/2, h=housing_height_mm, center=true, $fn=64);
      translate([0, 0, base_thickness_mm/2])
        cylinder(r=housing_outer_diameter_mm/2 - housing_wall_thickness_mm, h=housing_height_mm - base_thickness_mm, center=true, $fn=64);
    }
  }
  
  // Mounting base face
  translate([0, 0, -housing_height_mm/2 + base_thickness_mm/2])
    cylinder(r=housing_outer_diameter_mm/2, h=base_thickness_mm, center=true, $fn=64);
  
  // Stator with bore
  color([0.4, 0.4, 0.43]) {
    difference() {
      translate([0, 0, 0])
        cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true, $fn=64);
      translate([0, 0, 0])
        cylinder(r=max(stator_inner_bore_diameter_mm/2, clearance_mm/2), h=stator_height_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
  
  // Buzzer
  buzzer();
}

assembly();