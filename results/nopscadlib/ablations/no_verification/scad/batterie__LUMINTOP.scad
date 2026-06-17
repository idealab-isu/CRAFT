// Parameters
cell_height_mm = 70.7; //[35.35:141.4:0.1]
cell_diameter_mm = 18.4; //[9.2:36.8:0.1]
positive_button_diameter_mm = 5.5; //[2.75:11:0.1]
positive_button_height_mm = 1.2; //[0.6:2.4:0.1]
negative_end_recess_mm = 0; //[0:2:0.1]
edge_fillet_radius_mm = 0.5; //[0:2:0.1]
connect_overlap_mm = 0.8; //[0.2:2:0.1]
recess_diameter_factor = 0.7; //[0.3:0.95:0.05]

// Battery - complete geometry
module battery() {
  color("Silver") {
    // Cylindrical cell body with edge fillet
    difference() {
      // Main body with fillet
      minkowski() {
        cylinder(h=cell_height_mm - 2*edge_fillet_radius_mm, 
                 r=cell_diameter_mm/2 - edge_fillet_radius_mm, center=true);
        sphere(r=edge_fillet_radius_mm, center=true);
      }
      // Negative end recess
      if (negative_end_recess_mm > 0) {
        translate([0, 0, -cell_height_mm/2 + negative_end_recess_mm/2])
          cylinder(h=negative_end_recess_mm, 
                   r=(cell_diameter_mm * recess_diameter_factor) / 2, center=true);
      }
    }
    
    // Positive terminal button
    translate([0, 0, cell_height_mm/2 + positive_button_height_mm/2 - connect_overlap_mm])
      cylinder(h=positive_button_height_mm, 
               r=positive_button_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();