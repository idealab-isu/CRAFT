// Parameters
body_diameter_mm = 7; //[3.5:14:0.1]
overall_height_mm = 13.6; //[6.8:27.2:0.1]
body_height_mm = 13.6; //[6.8:27.2:0.1]
lever_length_mm = 10; //[5:20:0.1]
lever_diameter_mm = 2.2; //[1:5:0.1]
thread_outer_diameter_mm = 6.5; //[3.25:13:0.1]
thread_length_mm = 6; //[3:12:0.1]
panel_thickness_mm = 3; //[1:8:0.1]
mounting_hardware_included = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
toggle_tip_diameter_mm = 3.2; //[1.6:6.4:0.1]
toggle_tip_height_mm = 4; //[2:8:0.1]
nut_seat_outer_diameter_mm = 10; //[5:20:0.1]
nut_seat_height_mm = 2.2; //[1:5:0.1]

// Toggle switch - complete geometry
module toggle() {
  union() {
    // Cylindrical body
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true);
    }
    
    // Panel mount thread or collar
    color("Silver") {
      translate([0, 0, body_height_mm/2 + thread_length_mm/2 - overlap_mm])
        cylinder(r=thread_outer_diameter_mm/2, h=thread_length_mm, center=true);
    }
    
    // Mounting nut and washer seat
    if (mounting_hardware_included) {
      color("Silver") {
        translate([0, 0, body_height_mm/2 + nut_seat_height_mm/2 - overlap_mm])
          cylinder(r=nut_seat_outer_diameter_mm/2, h=nut_seat_height_mm, center=true);
      }
    }
    
    // Actuator lever
    color("Black") {
      translate([0, 0, body_height_mm/2 + lever_length_mm/2 - overlap_mm])
        cylinder(r=lever_diameter_mm/2, h=lever_length_mm, center=true);
    }
    
    // Toggle tip
    color("Black") {
      translate([0, 0, body_height_mm/2 + lever_length_mm - overlap_mm + toggle_tip_height_mm/2])
        cylinder(r=toggle_tip_diameter_mm/2, h=toggle_tip_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();