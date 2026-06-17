// Parameters
led_diameter_mm = 5; //[2.5:10:0.1]
body_height_mm = 5.9; //[3:12:0.1]
rim_thickness_mm = 1; //[0.5:2:0.1]
rim_diameter_mm = 6; //[5.2:12:0.1]
lead_pitch_mm = 2.54; //[1.5:5.08:0.01]
lead_thickness_mm = 0.5; //[0.3:1:0.05]
lead_length_mm = 10; //[5:25:0.5]
eps_mm = 0.8; //[0.2:2:0.1]
grill_width_mm = 12; //[6:24:0.5]
grill_height_mm = 12; //[6:24:0.5]
grill_hole_d_mm = 2; //[1:4:0.1]
grill_gap_mm = 1; //[0.5:3:0.1]
grill_marker_h_mm = 0.8; //[0.4:2:0.1]
grill_carrier_t_mm = 0.6; //[0.3:2:0.1]

// LED Module
module led() {
  color("red") {
    // LED Body
    translate([0, 0, body_height_mm/2])
      cylinder(r=led_diameter_mm/2, h=body_height_mm, center=true, $fn=32);
    
    // Rim Flange
    translate([0, 0, rim_thickness_mm/2])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true, $fn=32);
    
    // Leads
    translate([-lead_pitch_mm/2, 0, -(lead_length_mm + eps_mm)/2 + eps_mm/2])
      cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + eps_mm], center=true);
    translate([lead_pitch_mm/2, 0, -(lead_length_mm + eps_mm)/2 + eps_mm/2])
      cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + eps_mm], center=true);
  }
}

// Grill Hole Positions Module
module grill_hole_positions() {
  color("Silver") {
    // Carrier Plate
    translate([0, 0, rim_thickness_mm/2])
      cube([grill_width_mm, grill_height_mm, grill_carrier_t_mm], center=true);
    
    // Grill Markers
    for (x = [0:1]) {
      for (y = [0:1]) {
        translate([
          -grill_width_mm/2 + (x + 0.5) * (grill_width_mm / (floor(grill_width_mm / (grill_hole_d_mm + grill_gap_mm)))),
          -grill_height_mm/2 + (y + 0.5) * (grill_height_mm / (floor(grill_height_mm / ((grill_hole_d_mm + grill_gap_mm) * cos(30))))),
          rim_thickness_mm/2 + grill_carrier_t_mm/2 - eps_mm/2
        ])
        cylinder(r=grill_hole_d_mm/2, h=grill_marker_h_mm, center=true, $fn=16);
      }
    }
  }
}

// Assembly
module assembly() {
  led();
  grill_hole_positions();
}

assembly();