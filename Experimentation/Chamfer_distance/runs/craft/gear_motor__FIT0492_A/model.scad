// Parameters
gearbox_diameter = 37; //[18.5:74:0.1]
gearbox_height = 24.5; //[12.25:49:0.1]
motor_diameter = 35.6; //[17.8:71.2:0.1]
motor_length = 32; //[16:64:0.1]
shaft_diameter = 6; //[3:12:0.1]
shaft_length = 14.7; //[7.35:29.4:0.1]
interface_step_length = 3.2; //[1.6:6.4:0.1]
front_face_boss_diameter = 24.5; //[12.25:49:0.1]
front_face_boss_height = 3.2; //[1.6:6.4:0.1]
motor_shaft_diameter = 2.5; //[1.25:5:0.1]
motor_shaft_length = 10; //[5:20:0.1]
grommet_thickness = 2.5; //[1.25:5:0.1]
grommet_od = 12; //[6:24:0.1]
grommet_id = 6.5; //[3.25:13:0.1]
overlap = 1; //[0.5:2:0.1]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    cylinder(d=shaft_diameter, h=shaft_length, center=true);
  }
}

// Geared Stepper
module geared_stepper() {
  color("Black") {
    // Body
    cube([42.3, 42.3, motor_length], center=true);
    // Faceplate
    translate([0, 0, motor_length/2]) cylinder(d=front_face_boss_diameter, h=front_face_boss_height, $fn=32);
    // Shaft
    color("Silver") translate([0, 0, motor_length/2])
      cylinder(d=5, h=20, $fn=16);
  }
}

// Round Grommet Top
module round_grommet_top() {
  difference() {
    cylinder(d=grommet_od, h=grommet_thickness, center=true);
    translate([0, 0, -overlap]) cylinder(d=grommet_id, h=grommet_thickness + overlap*2, center=true);
  }
}

// Round Grommet Bottom
module round_grommet_bottom() {
  difference() {
    cylinder(d=grommet_od, h=grommet_thickness, center=true);
    translate([0, 0, -overlap]) cylinder(d=grommet_id, h=grommet_thickness + overlap*2, center=true);
  }
}

// Round Grommet Assembly
module round_grommet_assembly() {
  union() {
    translate([0, 0, grommet_thickness/2]) round_grommet_top();
    translate([0, 0, -grommet_thickness/2]) round_grommet_bottom();
  }
}

// Assembly
module assembly() {
  translate([0, 0, 0]) geared_stepper();
  translate([0, 0, gearbox_height/2 + motor_length - motor_shaft_length/2 - overlap]) motor_shaft();
  translate([0, 0, gearbox_height/2 + motor_length - grommet_thickness/2 - overlap]) round_grommet_assembly();
}

assembly();