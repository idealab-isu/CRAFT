// Parameters
body_diameter_mm = 3.0; //[1.5:6.0:0.05]
body_height_mm = 3.15; //[1.6:6.3:0.05]
rim_diameter_mm = 3.6; //[2.5:7.2:0.05]
rim_thickness_mm = 0.6; //[0.3:1.2:0.05]
rim_enabled = 1; //[0:1:1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.5; //[0.3:1.0:0.05]
lead_length_mm = 5.0; //[2.0:15.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
grill_width_mm = 20; //[10:60:1]
grill_height_mm = 20; //[10:60:1]
grill_hole_mm = 2.0; //[1.0:6.0:0.1]
grill_gap_mm = 1.0; //[0.5:6.0:0.1]
grill_nx = 6; //[2:20:1]
grill_ny = 6; //[2:20:1]
cos30 = 0.8660254; //[0.8660254:0.8660254:1]

// LED module
module led() {
  color("red") {
    // LED Body
    translate([0, 0, 0])
      cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true, $fn=32);
    
    // LED Rim/Flange
    if (rim_enabled) {
      translate([0, 0, -body_height_mm/2 + rim_thickness_mm/2 - overlap_mm])
        cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true, $fn=32);
    }
    
    // Lead Pins
    translate([-lead_pitch_mm/2, 0, -body_height_mm/2 - lead_length_mm/2 + overlap_mm])
      cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
    translate([lead_pitch_mm/2, 0, -body_height_mm/2 - lead_length_mm/2 + overlap_mm])
      cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
  }
}

// Grill Hole Positions module
module grill_hole_positions() {
  color("gray") {
    for (i = [0:grill_nx-1]) {
      for (j = [0:grill_ny-1]) {
        translate([
          -grill_width_mm/2 + (0.5 + i)*(grill_width_mm/grill_nx),
          -grill_height_mm/2 + (0.5 + j)*(grill_height_mm/grill_ny),
          0
        ])
        cylinder(r=grill_hole_mm/2, h=body_height_mm, center=true, $fn=16);
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