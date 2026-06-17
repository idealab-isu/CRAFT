// Parameters
led_type = 5; //[3:10:1]
colour = 0; //[0:0:1]
lead = 5; //[2.5:10:0.5]
right_angle = 0; //[0:12:1]
eps = 0.8; //[0.5:2:0.1]
body_d = 5; //[2.5:10:0.5]
body_h = 8; //[4:16:0.5]
rim_t = 1.2; //[0.6:2.4:0.1]
rim_d = 6; //[3:12:0.5]
lead_pitch = 2.54; //[1.27:5.08:0.01]
lead_t = 0.6; //[0.3:1.2:0.05]
solder_len = 1.5; //[0.8:3:0.1]

// LED Module
module led() {
  // LED Body
  color("red") {
    union() {
      // Main body
      translate([0, 0, body_h/2])
        cylinder(r=body_d/2, h=body_h, center=true, $fn=32);
      // Rim
      translate([0, 0, rim_t/2])
        cylinder(r=rim_d/2, h=rim_t, center=true, $fn=32);
    }
  }
  
  // Leads
  color("Silver") {
    union() {
      // Left lead
      translate([-lead_pitch/2, 0, -(lead + eps)/2])
        cube([lead_t, lead_t, lead + eps], center=true);
      // Right lead
      translate([lead_pitch/2, 0, -(lead + eps)/2])
        cube([lead_t, lead_t, lead + eps], center=true);
      // Solder ends
      translate([-lead_pitch/2, 0, -lead + solder_len/2])
        cube([lead_t*1.2, lead_t*1.2, solder_len], center=true);
      translate([lead_pitch/2, 0, -lead + solder_len/2])
        cube([lead_t*1.2, lead_t*1.2, solder_len], center=true);
      
      // Right-angle bends (if applicable)
      if (right_angle > 0) {
        translate([-lead_pitch/2, -right_angle/2 - lead_t/2 + eps, -lead + lead_t/2])
          cube([lead_t, right_angle, lead_t], center=true);
        translate([lead_pitch/2, -right_angle/2 - lead_t/2 + eps, -lead + lead_t/2])
          cube([lead_t, right_angle, lead_t], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  led();
}

assembly();