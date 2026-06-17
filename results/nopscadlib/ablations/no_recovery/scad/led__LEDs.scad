// Parameters
led_diameter = 5; //[2.5:10:0.1]
led_height = 8; //[4:16:0.1]
rim_thickness = 1.2; //[0.6:2.4:0.1]
rim_diameter = 6; //[3:12:0.1]
lead_pitch = 2.54; //[1.27:5.08:0.01]
lead_thickness = 0.5; //[0.25:1:0.01]
lead_length = 5; //[2.5:20:0.1]
right_angle = 0; //[0:10:0.1]
solder_tip_length = 1.2; //[0.6:3:0.1]
overlap = 0.8; //[0.5:2:0.1]

// LED module with detailed geometry
module led() {
  color("red") {
    // LED Body
    translate([0, 0, rim_thickness/2 + led_height/2 - overlap])
      cylinder(r=led_diameter/2, h=led_height, center=true, $fn=32);
    
    // LED Rim
    translate([0, 0, 0])
      cylinder(r=rim_diameter/2, h=rim_thickness, center=true, $fn=32);
    
    // Leads
    union() {
      // Left Lead
      translate([-lead_pitch/2, 0, -rim_thickness/2 - lead_length/2 + overlap])
        cube([lead_thickness, lead_thickness, lead_length], center=true);
      
      // Right Lead
      translate([lead_pitch/2, 0, -rim_thickness/2 - lead_length/2 + overlap])
        cube([lead_thickness, lead_thickness, lead_length], center=true);
      
      // Solder Tips
      translate([-lead_pitch/2, 0, -rim_thickness/2 - lead_length - solder_tip_length/2 + overlap])
        cube([lead_thickness*1.2, lead_thickness*1.2, solder_tip_length], center=true);
      
      translate([lead_pitch/2, 0, -rim_thickness/2 - lead_length - solder_tip_length/2 + overlap])
        cube([lead_thickness*1.2, lead_thickness*1.2, solder_tip_length], center=true);
      
      // Right Angle Bend (if applicable)
      if (right_angle > 0) {
        translate([-lead_pitch/2, -right_angle/2 - lead_thickness/2 + overlap, -rim_thickness/2 - lead_thickness/2 + overlap])
          cube([lead_thickness, right_angle, lead_thickness], center=true);
        
        translate([lead_pitch/2, -right_angle/2 - lead_thickness/2 + overlap, -rim_thickness/2 - lead_thickness/2 + overlap])
          cube([lead_thickness, right_angle, lead_thickness], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  led();
}

assembly();