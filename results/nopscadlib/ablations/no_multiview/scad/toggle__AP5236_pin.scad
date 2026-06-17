// Parameters
body_diameter_mm = 0.8; //[0.4:1.6:0.01]
overall_height_mm = 4.7; //[2.35:9.4:0.01]
body_height_mm = 3.5; //[1.75:7:0.01]
lever_height_mm = 1.2; //[0.6:2.4:0.01]
lever_diameter_mm = 0.3; //[0.15:0.6:0.01]
base_chamfer_mm = 0.05; //[0.02:0.1:0.005]
connection_overlap_mm = 0.05; //[0.02:0.2:0.005]
toggle_diameter_mm = 0.55; //[0.3:1.1:0.01]
toggle_height_mm = 0.35; //[0.15:0.8:0.01]

// Toggle switch - complete geometry
module toggle_switch() {
  union() {
    // Cylindrical Body
    color("DimGray") translate([0, 0, body_height_mm/2])
      cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true, $fn=32);
    
    // Base Chamfer
    color("DimGray") translate([0, 0, base_chamfer_mm])
      cylinder(h=base_chamfer_mm*2, r1=body_diameter_mm/2, r2=max(body_diameter_mm/2 - base_chamfer_mm, body_diameter_mm/4), center=true, $fn=32);
    
    // Actuator Lever
    color("Silver") translate([0, 0, body_height_mm + lever_height_mm/2 - connection_overlap_mm])
      cylinder(h=lever_height_mm, r=lever_diameter_mm/2, center=true, $fn=16);
    
    // Toggle Cap
    color("Silver") translate([0, 0, body_height_mm + lever_height_mm - connection_overlap_mm + toggle_height_mm/2])
      cylinder(h=toggle_height_mm, r=toggle_diameter_mm/2, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  toggle_switch();
}

assembly();