// Parameters
type = 0; //[0:2:1]
colour = 0; //[0:5:1]
lead = 5; //[2.5:10:0.5]
right_angle = 0; //[0:12:1]
eps = 0.8; //[0.5:2:0.1]
led_d = 5; //[3:10:1]
led_h = 8.5; //[5:17:0.5]
rim_t = 1.2; //[0.6:2.4:0.1]
rim_d = 6; //[3.6:12:0.2]
lead_t = 0.6; //[0.4:1.2:0.05]
lead_pitch = 2.54; //[1.5:5:0.01]
bend_r = 0.8; //[0.4:2:0.1]

// LED Module
module led() {
  // LED Body
  color("red") {
    union() {
      // Main cylindrical body
      translate([0, 0, led_h/2])
        cylinder(r=led_d/2, h=led_h, center=true, $fn=32);
      // Dome on top
      translate([0, 0, led_h])
        sphere(r=led_d/2, $fn=32);
      // Rim at the base
      translate([0, 0, rim_t/2])
        cylinder(r=rim_d/2, h=rim_t, center=true, $fn=32);
    }
  }
  
  // LED Leads
  color("Silver") {
    if (right_angle == 0) {
      // Straight leads
      union() {
        translate([-lead_pitch/2, 0, -(lead + eps)/2 + eps/2])
          cube([lead_t, lead_t, lead + eps], center=true);
        translate([lead_pitch/2, 0, -(lead + eps)/2 + eps/2])
          cube([lead_t, lead_t, lead + eps], center=true);
      }
    } else {
      // Right-angle leads
      union() {
        // Vertical part of the bend
        translate([-lead_pitch/2, 0, -(right_angle + eps)/2 + eps/2])
          cube([lead_t, lead_t, right_angle + eps], center=true);
        translate([lead_pitch/2, 0, -(right_angle + eps)/2 + eps/2])
          cube([lead_t, lead_t, right_angle + eps], center=true);
        
        // Horizontal part of the bend
        translate([-lead_pitch/2, -(right_angle + eps)/2 - lead_t/2 + eps/2, -right_angle + lead_t/2])
          cube([lead_t, right_angle + eps, lead_t], center=true);
        translate([lead_pitch/2, -(right_angle + eps)/2 - lead_t/2 + eps/2, -right_angle + lead_t/2])
          cube([lead_t, right_angle + eps, lead_t], center=true);
        
        // After bend
        translate([-lead_pitch/2, -(right_angle + eps) - (lead + eps)/2 - lead_t + eps, -right_angle + lead_t/2])
          cube([lead_t, lead + eps, lead_t], center=true);
        translate([lead_pitch/2, -(right_angle + eps) - (lead + eps)/2 - lead_t + eps, -right_angle + lead_t/2])
          cube([lead_t, lead + eps, lead_t], center=true);
        
        // Bend corners
        translate([-lead_pitch/2, -lead_t/2, -right_angle])
          sphere(r=bend_r, $fn=16);
        translate([lead_pitch/2, -lead_t/2, -right_angle])
          sphere(r=bend_r, $fn=16);
      }
    }
  }
}

// Assembly
module assembly() {
  led();
}

assembly();