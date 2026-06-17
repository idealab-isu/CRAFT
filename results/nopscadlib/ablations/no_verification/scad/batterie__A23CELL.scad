// Parameters
cell_height_mm = 28.5; //[14.25:57:0.1]
cell_diameter_mm = 10.3; //[5.15:20.6:0.1]
positive_terminal_diameter_mm = 4.5; //[2.25:9:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.05]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
edge_fillet_radius_mm = 0.5; //[0.25:1:0.05]
connect_overlap_mm = 0.8; //[0.2:2:0.1]
minkowski_resolution_sphere_radius_mm = 0.5; //[0.25:1:0.05]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Cylindrical cell body with filleted edges
    minkowski() {
      translate([0, 0, (-cell_height_mm/2) + (cell_height_mm - positive_terminal_height_mm)/2])
        cylinder(r=cell_diameter_mm/2 - edge_fillet_radius_mm, 
                 h=cell_height_mm - positive_terminal_height_mm - edge_fillet_radius_mm*2, 
                 center=true, $fn=64);
      sphere(r=minkowski_resolution_sphere_radius_mm, center=true, $fn=32);
    }
    
    // Positive terminal button
    translate([0, 0, cell_height_mm/2 - positive_terminal_height_mm/2 - connect_overlap_mm/2])
      cylinder(r=positive_terminal_diameter_mm/2, 
               h=positive_terminal_height_mm, 
               center=true, $fn=32);
    
    // Negative terminal flat end
    translate([0, 0, -cell_height_mm/2 + negative_terminal_height_mm/2 + connect_overlap_mm/2])
      cylinder(r=negative_terminal_diameter_mm/2, 
               h=negative_terminal_height_mm, 
               center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();