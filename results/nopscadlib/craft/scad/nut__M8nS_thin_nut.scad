// Parameters
thread_nominal_diameter_mm = 8.0; //[4.0:16.0:0.1]
across_flats_mm = 13.0; //[6.5:26.0:0.1]
thickness_mm = 4.0; //[2.0:8.0:0.1]
hole_diameter_mm = 8.0; //[4.0:16.0:0.1]
outer_profile_sides = 6; //[6:6:1]
edge_break_mm = 0.2; //[0.0:0.8:0.05]
tolerance_mm = 0.2; //[0.0:0.6:0.05]
eps_mm = 0.5; //[0.2:2.0:0.1]
hex_circumradius_mm = 7.505553499; //[3.75:15.5:0.01]
hole_radius_mm = 4.1; //[2.0:8.5:0.01]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    difference() {
      // Hex Nut Body
      cylinder(r=across_flats_mm/1.7320508076, h=thickness_mm, center=true, $fn=outer_profile_sides);
      
      // Thread Through Hole
      translate([0, 0, 0])
        cylinder(r=(hole_diameter_mm + tolerance_mm)/2, h=thickness_mm + 2*eps_mm, center=true);
      
      // Chamfer or Edge Break
      union() {
        // Edge Break Top Cone
        translate([0, 0, thickness_mm/2 - (edge_break_mm + eps_mm)/2])
          cylinder(r1=(hole_diameter_mm + tolerance_mm)/2 + edge_break_mm, 
                   r2=(hole_diameter_mm + tolerance_mm)/2, 
                   h=edge_break_mm + eps_mm, center=true);
        
        // Edge Break Bottom Cone
        translate([0, 0, -thickness_mm/2 + (edge_break_mm + eps_mm)/2])
          cylinder(r1=(hole_diameter_mm + tolerance_mm)/2, 
                   r2=(hole_diameter_mm + tolerance_mm)/2 + edge_break_mm, 
                   h=edge_break_mm + eps_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();