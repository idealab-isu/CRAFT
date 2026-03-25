// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_height_mm = 12.7; //[6.35:25.4:0.01]
axis_ring_thickness_mm = 0.8; //[0.4:1.6:0.05]
axis_ring_height_mm = 1.2; //[0.6:2.4:0.05]
axis_ring_clearance_mm = 0.2; //[0.0:0.6:0.05]
toggle_shaft_diameter_mm = 2.0; //[1.0:4.0:0.05]
toggle_shaft_length_mm = 10.0; //[5.0:20.0:0.1]
toggle_tip_diameter_mm = 3.0; //[1.5:6.0:0.05]
toggle_tip_height_mm = 3.0; //[1.5:6.0:0.05]
toggle_overlap_mm = 1.0; //[0.5:2.0:0.1]
origin_centered_on_axis = 1; //[1:1:1]

// Toggle switch body
module toggle_switch_body() {
  color("DimGray") {
    cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true);
  }
}

// Mounting axis reference ring
module mounting_axis_reference() {
  color("Silver") {
    difference() {
      translate([0, 0, body_height_mm/2 - axis_ring_height_mm/2])
        cylinder(r=body_diameter_mm/2 + axis_ring_clearance_mm + axis_ring_thickness_mm, 
                 h=axis_ring_height_mm, center=true);
      translate([0, 0, body_height_mm/2 - axis_ring_height_mm/2])
        cylinder(r=body_diameter_mm/2 + axis_ring_clearance_mm, 
                 h=axis_ring_height_mm + 2, center=true);
    }
  }
}

// Toggle lever
module toggle() {
  color("Black") {
    union() {
      translate([0, 0, body_height_mm/2 + toggle_shaft_length_mm/2 - toggle_overlap_mm])
        cylinder(r=toggle_shaft_diameter_mm/2, h=toggle_shaft_length_mm, center=true);
      translate([0, 0, body_height_mm/2 + toggle_shaft_length_mm - toggle_overlap_mm + toggle_tip_height_mm/2])
        cylinder(r=toggle_tip_diameter_mm/2, h=toggle_tip_height_mm, center=true);
    }
  }
}

// Complete toggle switch assembly
module assembly() {
  toggle_switch_body();
  mounting_axis_reference();
  toggle();
}

assembly();