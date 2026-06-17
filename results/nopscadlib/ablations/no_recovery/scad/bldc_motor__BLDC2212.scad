// Parameters
stator_diameter_mm = 28.0; //[14.0:56.0:0.1]
motor_height_mm = 27.0; //[13.5:54.0:0.1]
shaft_diameter_mm = 5.0; //[2.5:10.0:0.1]
shaft_extension_front_mm = 10.0; //[0.0:20.0:0.1]
shaft_extension_rear_mm = 0.0; //[0.0:20.0:0.1]
housing_wall_thickness_mm = 1.0; //[0.5:2.0:0.1]
housing_clearance_mm = 0.5; //[0.2:1.5:0.1]
endcap_thickness_mm = 2.0; //[1.0:4.0:0.1]
mounting_flange_diameter_mm = 32.0; //[16.0:64.0:0.1]
mounting_flange_thickness_mm = 2.0; //[1.0:6.0:0.1]
mount_hole_count = 4; //[2:8:1]
mount_hole_diameter_mm = 3.0; //[2.0:6.0:0.1]
mount_hole_circle_diameter_mm = 25.0; //[12.5:50.0:0.1]
wire_exit_width_mm = 6.0; //[3.0:12.0:0.1]
wire_exit_height_mm = 3.0; //[1.5:8.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
bearing_seat_diameter_mm = 10.0; //[6.0:16.0:0.1]
bearing_seat_depth_mm = 1.5; //[0.5:3.0:0.1]
vent_count = 6; //[3:12:1]
vent_width_mm = 3.0; //[1.5:6.0:0.1]
vent_height_mm = 10.0; //[5.0:20.0:0.1]
set_screw_boss_diameter_mm = 6.0; //[4.0:12.0:0.1]
set_screw_boss_length_mm = 5.0; //[3.0:12.0:0.1]
set_screw_hole_diameter_mm = 2.0; //[1.0:4.0:0.1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.1]
buzzer_height_mm = 5.0; //[2.5:10.0:0.1]

// Buzzer - Detailed geometry
module buzzer() {
  color([0.85, 0.85, 0.8]) {
    cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
  }
}

// Motor Assembly
module assembly() {
  // Stator Cylinder
  color("DimGray") {
    translate([0, 0, 0])
      cylinder(r=stator_diameter_mm/2, h=motor_height_mm, center=true, $fn=64);
  }

  // Rotor Can Housing
  color([0.12, 0.12, 0.14]) {
    difference() {
      translate([0, 0, 0])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, h=motor_height_mm, center=true, $fn=64);
      translate([0, 0, 0])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm, h=motor_height_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }

  // Endcaps
  color("Silver") {
    union() {
      translate([0, 0, motor_height_mm/2 + endcap_thickness_mm/2 - overlap_mm])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, h=endcap_thickness_mm, center=true, $fn=64);
      translate([0, 0, -motor_height_mm/2 - endcap_thickness_mm/2 + overlap_mm])
        cylinder(r=stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm, h=endcap_thickness_mm, center=true, $fn=64);
      translate([0, 0, motor_height_mm/2 + endcap_thickness_mm - overlap_mm + bearing_seat_depth_mm/2])
        cylinder(r=bearing_seat_diameter_mm/2, h=bearing_seat_depth_mm, center=true, $fn=32);
      translate([0, 0, -motor_height_mm/2 - endcap_thickness_mm + overlap_mm - bearing_seat_depth_mm/2])
        cylinder(r=bearing_seat_diameter_mm/2, h=bearing_seat_depth_mm, center=true, $fn=32);
    }
  }

  // Central Shaft
  color("Silver") {
    translate([0, 0, (shaft_extension_front_mm - shaft_extension_rear_mm)/2])
      cylinder(r=shaft_diameter_mm/2, h=motor_height_mm + 2*endcap_thickness_mm + shaft_extension_front_mm + shaft_extension_rear_mm, center=true, $fn=32);
  }

  // Mounting Flange
  color("Silver") {
    difference() {
      translate([0, 0, motor_height_mm/2 + endcap_thickness_mm + mounting_flange_thickness_mm/2 - overlap_mm])
        cylinder(r=mounting_flange_diameter_mm/2, h=mounting_flange_thickness_mm, center=true, $fn=64);
      for (i = [0:3]) {
        rotate([0, 0, i*90])
          translate([mount_hole_circle_diameter_mm/2, 0, motor_height_mm/2 + endcap_thickness_mm + mounting_flange_thickness_mm/2 - overlap_mm])
            cylinder(r=mount_hole_diameter_mm/2, h=mounting_flange_thickness_mm + 2*overlap_mm, center=true, $fn=32);
      }
    }
  }

  // Wire Exit Slot
  color("Black") {
    translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm/2, 0, -motor_height_mm/2 + wire_exit_height_mm/2 + overlap_mm])
      cube([housing_wall_thickness_mm + 2*overlap_mm, wire_exit_width_mm, wire_exit_height_mm], center=true);
  }

  // Cooling Vents
  color("Black") {
    for (i = [0:vent_count-1]) {
      rotate([0, 0, i*360/vent_count])
        translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm/2, 0, 0])
          cube([housing_wall_thickness_mm + 2*overlap_mm, vent_width_mm, vent_height_mm], center=true);
    }
  }

  // Set Screw Boss
  color("Black") {
    difference() {
      translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm - overlap_mm + set_screw_boss_length_mm/2, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=set_screw_boss_diameter_mm/2, h=set_screw_boss_length_mm, center=true, $fn=32);
      translate([stator_diameter_mm/2 + housing_clearance_mm + housing_wall_thickness_mm - overlap_mm + set_screw_boss_length_mm/2, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_boss_length_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }

  // Auxiliary Cylinder (Buzzer)
  translate([0, 0, motor_height_mm/2 + endcap_thickness_mm + mounting_flange_thickness_mm - overlap_mm + buzzer_height_mm/2])
    buzzer();
}

// Final Assembly
assembly();