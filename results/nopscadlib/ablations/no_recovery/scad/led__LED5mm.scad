// Parameters
led_diameter_mm = 5; //[2.5:10:0.1]
body_height_mm = 5.9; //[3:12:0.1]
dome_height_mm = 2.5; //[1.25:5:0.1]
rim_thickness_mm = 1; //[0.5:2:0.1]
rim_diameter_mm = 5.8; //[4:11.6:0.1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_length_mm = 5; //[2.5:10:0.1]
lead_thickness_mm = 0.5; //[0.25:1:0.05]
overlap_mm = 0.8; //[0.2:2:0.1]
grill_hole_mm = 2; //[1:4:0.1]
grill_width_mm = 10; //[5:20:0.5]
grill_height_mm = 10; //[5:20:0.5]

// LED - complete geometry
module led() {
  color("red") {
    // LED Body
    union() {
      // Cylindrical body
      translate([0, 0, rim_thickness_mm + (body_height_mm - dome_height_mm)/2 - overlap_mm])
        cylinder(r=led_diameter_mm/2, h=body_height_mm - dome_height_mm, center=true);
      
      // Dome
      translate([0, 0, rim_thickness_mm + (body_height_mm - dome_height_mm) - overlap_mm])
        difference() {
          sphere(r=led_diameter_mm/2, center=true);
          translate([0, 0, -led_diameter_mm])
            cube([led_diameter_mm*2, led_diameter_mm*2, led_diameter_mm*2], center=true);
        }
    }
    
    // Rim Flange
    translate([0, 0, rim_thickness_mm/2])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true);
    
    // Leads
    union() {
      translate([-lead_pitch_mm/2, 0, (rim_thickness_mm - (lead_length_mm + rim_thickness_mm + overlap_mm))/2])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + rim_thickness_mm + overlap_mm], center=true);
      translate([lead_pitch_mm/2, 0, (rim_thickness_mm - (lead_length_mm + rim_thickness_mm + overlap_mm))/2])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + rim_thickness_mm + overlap_mm], center=true);
    }
  }
}

// Grill Hole Positions - complete geometry
module grill_hole_positions() {
  color("Silver") {
    union() {
      translate([-grill_width_mm/4, -grill_height_mm/4, rim_thickness_mm/2 - overlap_mm])
        cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true);
      translate([grill_width_mm/4, -grill_height_mm/4, rim_thickness_mm/2 - overlap_mm])
        cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true);
      translate([0, grill_height_mm/4, rim_thickness_mm/2 - overlap_mm])
        cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  led();
  grill_hole_positions();
}

assembly();