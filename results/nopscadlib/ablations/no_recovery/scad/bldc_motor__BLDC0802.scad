// Parameters
stator_diameter_mm = 11.5; //[6:23:0.1]
stator_height_mm = 9.5; //[5:19:0.1]
housing_wall_thickness_mm = 0.6; //[0.3:1.2:0.05]
housing_clearance_mm = 0.2; //[0.1:0.6:0.05]
shaft_diameter_mm = 2; //[1:4:0.05]
shaft_length_mm = 15; //[8:30:0.5]
endcap_thickness_mm = 1; //[0.5:2:0.05]
bearing_outer_diameter_mm = 5; //[3:10:0.1]
bearing_thickness_mm = 2; //[1:4:0.1]
flange_diameter_mm = 14; //[8:28:0.1]
flange_thickness_mm = 1.5; //[0.8:3:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]
housing_extra_height_mm = 2; //[0.5:6:0.1]
wire_grommet_diameter_mm = 3; //[1.5:6:0.1]
wire_grommet_length_mm = 2.5; //[1:6:0.1]
vent_hole_diameter_mm = 1.2; //[0.6:2.5:0.1]
vent_hole_count = 6; //[3:12:1]
buzzer_diameter_mm = 8; //[4:16:0.1]
buzzer_height_mm = 4; //[2:10:0.1]
buzzer_pin_diameter_mm = 2; //[1:3:0.1]
buzzer_pin_height_mm = 2; //[0.5:6:0.1]

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    // Buzzer body
    cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
    // Buzzer pin
    translate([0, 0, buzzer_height_mm/2 - buzzer_pin_height_mm/2])
      cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_height_mm, center=true);
  }
}

// Motor assembly
module assembly() {
  color("DimGray") {
    // Stator core
    translate([0, 0, 0])
      cylinder(r=stator_diameter_mm/2, h=stator_height_mm, center=true);

    // Housing can
    difference() {
      cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, 
               h=stator_height_mm + housing_extra_height_mm, center=true);
      cylinder(r=stator_diameter_mm/2 + housing_clearance_mm, 
               h=stator_height_mm + housing_extra_height_mm + 2*overlap_mm, center=true);
    }

    // Central shaft
    translate([0, 0, 0])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

    // End caps
    union() {
      translate([0, 0, (stator_height_mm + housing_extra_height_mm)/2 - endcap_thickness_mm/2 + overlap_mm/2])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, 
                 h=endcap_thickness_mm, center=true);
      translate([0, 0, -(stator_height_mm + housing_extra_height_mm)/2 + endcap_thickness_mm/2 - overlap_mm/2])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, 
                 h=endcap_thickness_mm, center=true);
    }

    // Bearing seats
    union() {
      translate([0, 0, (stator_height_mm + housing_extra_height_mm)/2 - endcap_thickness_mm - bearing_thickness_mm/2 + overlap_mm])
        cylinder(r=bearing_outer_diameter_mm/2, h=bearing_thickness_mm, center=true);
      translate([0, 0, -(stator_height_mm + housing_extra_height_mm)/2 + endcap_thickness_mm + bearing_thickness_mm/2 - overlap_mm])
        cylinder(r=bearing_outer_diameter_mm/2, h=bearing_thickness_mm, center=true);
    }

    // Mounting flange
    translate([0, 0, -(stator_height_mm + housing_extra_height_mm)/2 - flange_thickness_mm/2 + overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    // Wire exit grommet
    translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm + wire_grommet_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=wire_grommet_diameter_mm/2, h=wire_grommet_length_mm, center=true);

    // Vent holes
    for (i = [0:vent_hole_count-1]) {
      rotate([0, 0, i*360/vent_hole_count])
        translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=vent_hole_diameter_mm/2, 
                 h=2*(stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm) + 2*overlap_mm, 
                 center=true);
    }
  }

  // Buzzer
  translate([0, 0, -(stator_height_mm + housing_extra_height_mm)/2 - flange_thickness_mm - buzzer_height_mm/2 + overlap_mm])
    buzzer();
}

// Final assembly
assembly();