// Parameters
led_d = 5; //[3:10:1]
led_height = 8.5; //[5:17:0.5]
rim_thickness = 1.2; //[0.6:2.4:0.1]
rim_d = 6; //[4:12:0.5]
lead_pitch = 2.54; //[1.5:5.08:0.01]
lead_thickness = 0.6; //[0.3:1.2:0.05]
lead = 5; //[2.5:15:0.5]
right_angle = 0; //[0:10:1]
bend_radius = 0.8; //[0.4:2:0.1]
solder_length = 1.2; //[0.6:3:0.1]
solder_d = 0.9; //[0.5:2:0.05]
overlap = 0.8; //[0.5:2:0.1]

// LED Module
module led() {
  color("red") {
    // LED Body
    translate([0, 0, rim_thickness/2 + led_height/2 - overlap])
      cylinder(r=led_d/2, h=led_height, center=true, $fn=32);
    
    // Rim Flange
    translate([0, 0, 0])
      cylinder(r=rim_d/2, h=rim_thickness, center=true, $fn=32);
    
    // Leads
    union() {
      // Left Lead
      translate([-lead_pitch/2, 0, -(lead + overlap)/2 + rim_thickness/2 - overlap])
        cube([lead_thickness, lead_thickness, lead + overlap], center=true);
      
      // Right Lead
      translate([lead_pitch/2, 0, -(lead + overlap)/2 + rim_thickness/2 - overlap])
        cube([lead_thickness, lead_thickness, lead + overlap], center=true);
    }
    
    // Solder Ends
    union() {
      // Left Solder End
      translate([-lead_pitch/2, 0, -lead + rim_thickness/2 - solder_length/2])
        cylinder(r=solder_d/2, h=solder_length, center=true, $fn=16);
      
      // Right Solder End
      translate([lead_pitch/2, 0, -lead + rim_thickness/2 - solder_length/2])
        cylinder(r=solder_d/2, h=solder_length, center=true, $fn=16);
    }
    
    // Right Angle Bend (if applicable)
    if (right_angle > 0) {
      union() {
        // Left Horizontal Bend
        translate([-lead_pitch/2, -right_angle/2 - lead_thickness/2 + overlap, -lead + rim_thickness/2 + lead_thickness/2 - overlap])
          cube([lead_thickness, right_angle, lead_thickness], center=true);
        
        // Right Horizontal Bend
        translate([lead_pitch/2, -right_angle/2 - lead_thickness/2 + overlap, -lead + rim_thickness/2 + lead_thickness/2 - overlap])
          cube([lead_thickness, right_angle, lead_thickness], center=true);
        
        // Left Elbow
        translate([-lead_pitch/2, -lead_thickness/2 + overlap, -lead + rim_thickness/2 + lead_thickness/2 - overlap])
          sphere(r=bend_radius, $fn=16);
        
        // Right Elbow
        translate([lead_pitch/2, -lead_thickness/2 + overlap, -lead + rim_thickness/2 + lead_thickness/2 - overlap])
          sphere(r=bend_radius, $fn=16);
      }
    }
  }
}

// Assembly
module assembly() {
  led();
}

assembly();