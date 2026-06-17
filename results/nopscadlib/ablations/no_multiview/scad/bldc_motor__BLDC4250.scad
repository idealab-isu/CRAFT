// Parameters
stator_diameter_mm = 42.5; //[21.25:85:0.1]
motor_height_mm = 48; //[24:96:0.1]
shaft_diameter_mm = 5; //[2.5:10:0.1]
shaft_extension_front_mm = 15; //[7.5:30:0.1]
shaft_extension_rear_mm = 5; //[2.5:10:0.1]
housing_wall_thickness_mm = 1.5; //[0.75:3:0.1]
endcap_thickness_mm = 2; //[1:4:0.1]
air_gap_mm = 0.5; //[0.25:1:0.05]
bearing_outer_diameter_mm = 10; //[5:20:0.1]
bearing_thickness_mm = 4; //[2:8:0.1]
mounting_hole_count = 4; //[3:8:1]
mounting_hole_diameter_mm = 3; //[1.5:6:0.1]
mounting_bolt_circle_diameter_mm = 30; //[15:60:0.1]
overlap_mm = 1; //[0.5:2:0.1]
housing_extra_radius_mm = 1; //[0.5:3:0.1]
mounting_face_thickness_mm = 3; //[1.5:6:0.1]
mounting_face_extra_radius_mm = 4; //[2:10:0.1]
wire_grommet_radius_mm = 3; //[1.5:6:0.1]
wire_grommet_length_mm = 6; //[3:12:0.1]
wire_grommet_hole_radius_mm = 1.5; //[0.75:3:0.1]
vent_hole_diameter_mm = 3; //[1.5:6:0.1]
vent_hole_count = 6; //[3:12:1]
vent_hole_radial_offset_mm = 6; //[3:12:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 6; //[3:12:0.1]
buzzer_pin_diameter_mm = 2; //[1:4:0.1]
buzzer_pin_height_mm = 3; //[1.5:6:0.1]

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    // Buzzer body
    cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
    // Buzzer pin
    translate([0, 0, buzzer_height_mm/2 - overlap_mm + buzzer_pin_height_mm/2])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true);
  }
}

// Motor assembly
module assembly() {
  difference() {
    union() {
      // Stator core
      color("DimGray")
      cylinder(r=stator_diameter_mm/2, h=motor_height_mm, center=true);

      // Rotor can
      color("Black")
      difference() {
        cylinder(r=stator_diameter_mm/2 + air_gap_mm + housing_wall_thickness_mm + housing_extra_radius_mm, h=motor_height_mm, center=true);
        cylinder(r=stator_diameter_mm/2 + air_gap_mm + housing_extra_radius_mm, h=motor_height_mm + overlap_mm*2, center=true);
      }

      // Endcaps
      color("Silver")
      translate([0, 0, motor_height_mm/2 - endcap_thickness_mm/2 + overlap_mm])
        cylinder(r=stator_diameter_mm/2 + air_gap_mm + housing_wall_thickness_mm + housing_extra_radius_mm, h=endcap_thickness_mm, center=true);
      translate([0, 0, -motor_height_mm/2 + endcap_thickness_mm/2 - overlap_mm])
        cylinder(r=stator_diameter_mm/2 + air_gap_mm + housing_wall_thickness_mm + housing_extra_radius_mm, h=endcap_thickness_mm, center=true);

      // Mounting face
      color("Silver")
      translate([0, 0, motor_height_mm/2 + mounting_face_thickness_mm/2 - overlap_mm])
        cylinder(r=stator_diameter_mm/2 + air_gap_mm + housing_wall_thickness_mm + housing_extra_radius_mm + mounting_face_extra_radius_mm, h=mounting_face_thickness_mm, center=true);

      // Central shaft
      color("Silver")
      translate([0, 0, (shaft_extension_front_mm - shaft_extension_rear_mm)/2])
        cylinder(r=shaft_diameter_mm/2, h=motor_height_mm + shaft_extension_front_mm + shaft_extension_rear_mm, center=true);

      // Wire exit grommet
      color("Black")
      difference() {
        translate([stator_diameter_mm/2 + air_gap_mm + housing_wall_thickness_mm + housing_extra_radius_mm + wire_grommet_length_mm/2 - overlap_mm, 0, -motor_height_mm/2 + endcap_thickness_mm + wire_grommet_radius_mm*2])
          rotate([0, 90, 0])
          cylinder(r=wire_grommet_radius_mm, h=wire_grommet_length_mm, center=true);
        translate([stator_diameter_mm/2 + air_gap_mm + housing_wall_thickness_mm + housing_extra_radius_mm + wire_grommet_length_mm/2 - overlap_mm, 0, -motor_height_mm/2 + endcap_thickness_mm + wire_grommet_radius_mm*2])
          rotate([0, 90, 0])
          cylinder(r=wire_grommet_hole_radius_mm, h=wire_grommet_length_mm + overlap_mm*2, center=true);
      }

      // Buzzer
      translate([0, 0, motor_height_mm/2 + mounting_face_thickness_mm + buzzer_height_mm/2 - overlap_mm])
        buzzer();
    }

    // Bearing seats
    translate([0, 0, motor_height_mm/2 - endcap_thickness_mm/2 + overlap_mm])
      cylinder(r=bearing_outer_diameter_mm/2, h=bearing_thickness_mm + overlap_mm*2, center=true);
    translate([0, 0, -motor_height_mm/2 + endcap_thickness_mm/2 - overlap_mm])
      cylinder(r=bearing_outer_diameter_mm/2, h=bearing_thickness_mm + overlap_mm*2, center=true);

    // Mounting holes
    for (i = [0:3]) {
      rotate([0, 0, i*90])
        translate([mounting_bolt_circle_diameter_mm/2, 0, motor_height_mm/2 + mounting_face_thickness_mm/2 - overlap_mm])
        cylinder(r=mounting_hole_diameter_mm/2, h=mounting_face_thickness_mm + overlap_mm*2, center=true);
    }

    // Vent holes
    for (i = [0:5]) {
      rotate([0, 0, i*60])
        translate([stator_diameter_mm/2 + air_gap_mm + housing_wall_thickness_mm + housing_extra_radius_mm - vent_hole_radial_offset_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=vent_hole_diameter_mm/2, h=housing_wall_thickness_mm + overlap_mm*2, center=true);
    }
  }
}

// Final assembly call
assembly();