// Parameters
height_mm = 70.7; //[35.35:141.4:0.1]
diameter_mm = 18.4; //[9.2:36.8:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
positive_terminal_diameter_mm = 5.5; //[2.75:11:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.4:0.05]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
edge_chamfer_mm = 0.3; //[0.15:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Battery cell body
    union() {
      // Core
      translate([0, 0, 0])
        cylinder(r=diameter_mm/2, h=height_mm - 2*edge_chamfer_mm, center=true, $fn=64);
      
      // Top chamfer
      translate([0, 0, (height_mm - 2*edge_chamfer_mm)/2 + edge_chamfer_mm/2])
        cylinder(r1=diameter_mm/2, r2=diameter_mm/2 - edge_chamfer_mm, h=edge_chamfer_mm, center=true, $fn=64);
      
      // Bottom chamfer
      translate([0, 0, -((height_mm - 2*edge_chamfer_mm)/2 + edge_chamfer_mm/2)])
        cylinder(r1=diameter_mm/2 - edge_chamfer_mm, r2=diameter_mm/2, h=edge_chamfer_mm, center=true, $fn=64);
    }
    
    // Positive terminal button
    translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - overlap_mm])
      cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true, $fn=32);
    
    // Negative terminal flat end
    translate([0, 0, -height_mm/2 - negative_terminal_height_mm/2 + overlap_mm])
      cylinder(r=negative_terminal_diameter_mm/2, h=negative_terminal_height_mm, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();