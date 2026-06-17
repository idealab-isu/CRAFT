// Parameters
height_mm = 65; //[32.5:130:0.1]
diameter_mm = 18.3; //[9.15:36.6:0.1]
positive_terminal_diameter_mm = 5.5; //[2.75:11:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
edge_chamfer_mm = 0.3; //[0.15:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Main cylindrical body
    cylinder(h=height_mm, r=diameter_mm/2, center=true, $fn=64);
    
    // Positive terminal button
    translate([0, 0, height_mm/2 - overlap_mm])
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
    
    // Negative terminal flat end
    translate([0, 0, -height_mm/2 + edge_chamfer_mm/2])
      cylinder(h=edge_chamfer_mm, r=diameter_mm/2, center=true, $fn=64);
    
    // Negative edge chamfer cut
    difference() {
      cylinder(h=height_mm, r=diameter_mm/2, center=true, $fn=64);
      translate([0, 0, -height_mm/2 + edge_chamfer_mm/2])
        cylinder(h=edge_chamfer_mm, r1=diameter_mm/2, r2=0, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();