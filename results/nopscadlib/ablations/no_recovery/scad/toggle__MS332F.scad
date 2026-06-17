// Parameters
body_diameter_mm = 12.6; //[6.3:25.2:0.1]
body_height_mm = 13.1; //[6.55:26.2:0.1]
panel_thickness_mm = 3; //[0.5:8:0.1]
thread_outer_diameter_mm = 6.35; //[3.2:12.7:0.05]
thread_length_mm = 8; //[4:16:0.1]
lever_length_mm = 18; //[9:36:0.1]
lever_angle_deg = 15; //[-45:45:1]
pin_count = 3; //[2:6:1]
pin_pitch_mm = 4.7; //[2.35:9.4:0.1]
eps_mm = 1; //[0.5:2:0.1]
washer_od_mm = 12; //[6:24:0.1]
washer_thickness_mm = 1; //[0.5:2.5:0.1]
nut_flat_width_mm = 11; //[6:22:0.1]
nut_thickness_mm = 3; //[1.5:6:0.1]
pin_length_mm = 6; //[3:12:0.1]
pin_width_mm = 1.2; //[0.6:2.4:0.05]
pin_thickness_mm = 0.6; //[0.3:1.2:0.05]
pin_row_spacing_mm = 3.5; //[1.75:7:0.1]
lever_diameter_mm = 3; //[1.5:6:0.1]
lever_knob_diameter_mm = 6; //[3:12:0.1]
lever_knob_height_mm = 4; //[2:8:0.1]

// Toggle switch - complete geometry
module toggle() {
  // Main switch body
  color("DimGray") {
    translate([0, 0, 0])
      cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true, $fn=64);
  }
  
  // Mounting bushing/thread section
  color("Silver") {
    translate([0, 0, body_height_mm/2 + thread_length_mm/2 - eps_mm])
      cylinder(h=thread_length_mm, r=thread_outer_diameter_mm/2, center=true, $fn=64);
  }
  
  // Toggle lever
  color("Black") {
    rotate([lever_angle_deg, 0, 0])
      translate([0, 0, body_height_mm/2 + thread_length_mm - eps_mm + lever_length_mm/2])
        cylinder(h=lever_length_mm, r=lever_diameter_mm/2, center=true, $fn=32);
    
    // Lever knob
    translate([0, 0, lever_length_mm/2 - lever_knob_height_mm/2])
      cylinder(h=lever_knob_height_mm, r=lever_knob_diameter_mm/2, center=true, $fn=32);
  }
  
  // Washer stack
  color("Silver") {
    translate([0, 0, body_height_mm/2 + thread_length_mm - eps_mm - washer_thickness_mm/2])
      cylinder(h=washer_thickness_mm, r=washer_od_mm/2, center=true, $fn=64);
    
    translate([0, 0, body_height_mm/2 + thread_length_mm - eps_mm - washer_thickness_mm - panel_thickness_mm - washer_thickness_mm/2])
      cylinder(h=washer_thickness_mm, r=washer_od_mm/2, center=true, $fn=64);
  }
  
  // Nut
  color("Silver") {
    translate([0, 0, body_height_mm/2 + thread_length_mm - eps_mm - washer_thickness_mm - panel_thickness_mm - washer_thickness_mm - nut_thickness_mm/2])
      cube([nut_flat_width_mm, nut_flat_width_mm, nut_thickness_mm], center=true);
  }
  
  // Electrical pins
  color("Copper") {
    for (i = [0:pin_count-1]) {
      translate([0, (i - (pin_count-1)/2) * pin_pitch_mm, -body_height_mm/2 - pin_length_mm/2 + eps_mm])
        cube([pin_width_mm, pin_thickness_mm, pin_length_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();