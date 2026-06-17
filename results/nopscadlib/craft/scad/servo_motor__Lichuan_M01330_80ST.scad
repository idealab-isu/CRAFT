// Parameters
body_width = 80; //[40:160:1]
body_height = 80; //[40:160:1]
body_length = 120; //[60:240:1]
flange_diameter_or_width = 90; //[45:180:1]
faceplate_thickness = 8; //[4:16:1]
pilot_diameter = 60; //[30:120:1]
pilot_length = 2; //[1:8:1]
mount_hole_diameter = 6.6; //[3:13:0.1]
mount_hole_pitch_x = 70; //[35:140:1]
mount_hole_pitch_y = 70; //[35:140:1]
shaft_diameter = 19; //[8:38:0.5]
shaft_length = 40; //[15:80:1]
shaft_key_width = 6; //[2:12:0.5]
shaft_key_depth = 2; //[1:6:0.5]
rear_cap_diameter = 78; //[39:156:1]
rear_cap_length = 12; //[6:30:1]
connector_boss_width = 30; //[15:60:1]
connector_boss_height = 20; //[10:40:1]
connector_boss_length = 18; //[8:40:1]
overlap = 1; //[0.5:2:0.1]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Body
    translate([0, 0, 0])
      cube([body_width, body_height, body_length], center=true);

    // Front faceplate flange
    translate([0, 0, body_length/2 + faceplate_thickness/2 - overlap])
      cylinder(r=flange_diameter_or_width/2, h=faceplate_thickness, center=true);

    // Front pilot
    translate([0, 0, body_length/2 + faceplate_thickness - overlap + pilot_length/2])
      cylinder(r=pilot_diameter/2, h=pilot_length, center=true);

    // Output shaft
    difference() {
      translate([0, 0, body_length/2 + faceplate_thickness - overlap + shaft_length/2])
        cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
      translate([shaft_diameter/2 - shaft_key_depth + shaft_key_width/2, 0, body_length/2 + faceplate_thickness - overlap + shaft_length/2])
        cube([shaft_key_width, shaft_diameter, shaft_length + 2*overlap], center=true);
    }

    // Rear cap or connector boss
    translate([0, 0, -body_length/2 - rear_cap_length/2 + overlap])
      cylinder(r=rear_cap_diameter/2, h=rear_cap_length, center=true);

    // Cable exit or connector interface
    translate([0, 0, -body_length/2 - rear_cap_length + overlap + connector_boss_length/2])
      cube([connector_boss_width, connector_boss_height, connector_boss_length], center=true);

    // Mounting holes
    color("White") {
      translate([mount_hole_pitch_x/2, mount_hole_pitch_y/2, body_length/2 + faceplate_thickness/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=faceplate_thickness + 2*overlap, center=true);
      translate([-mount_hole_pitch_x/2, mount_hole_pitch_y/2, body_length/2 + faceplate_thickness/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=faceplate_thickness + 2*overlap, center=true);
      translate([-mount_hole_pitch_x/2, -mount_hole_pitch_y/2, body_length/2 + faceplate_thickness/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=faceplate_thickness + 2*overlap, center=true);
      translate([mount_hole_pitch_x/2, -mount_hole_pitch_y/2, body_length/2 + faceplate_thickness/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=faceplate_thickness + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();