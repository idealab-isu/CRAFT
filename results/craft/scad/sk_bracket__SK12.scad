// Parameters
rod_diameter = 12.0; //[6.0:24.0:0.1]
rod_length = 60.0; //[30.0:120.0:1]
bracket_height = 23.0; //[12.0:46.0:0.1]
clearance_diameter = 0.2; //[0.0:0.6:0.05]
wall_thickness = 4.0; //[2.0:8.0:0.1]
base_thickness = 5.0; //[3.0:10.0:0.1]
base_width = 30.0; //[15.0:60.0:0.5]
base_length = 40.0; //[20.0:80.0:0.5]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing = 24.0; //[12.0:48.0:0.5]
bore_center_height_from_base = 17.0; //[10.0:30.0:0.1]
clamp_gap = 2.0; //[1.0:6.0:0.1]
retention_screw_diameter = 5.0; //[3.0:8.0:0.1]
retention_boss_diameter = 12.0; //[8.0:20.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// SK12 Bracket - complete geometry
module sk_bracket() {
  color("Silver") {
    // Base
    translate([0, 0, base_thickness/2])
      cube([base_width, base_length, base_thickness], center=true);
    
    // Main Bracket Body
    translate([0, 0, base_thickness + (bracket_height - base_thickness)/2 - overlap])
      cube([base_width, base_length*0.6, bracket_height - base_thickness], center=true);
    
    // Rod Retention Feature
    translate([0, 0, bore_center_height_from_base])
      rotate([0, 90, 0])
      cylinder(r=retention_boss_diameter/2, h=base_width, center=true);
    
    // Rod Support Bore or Cradle
    translate([0, 0, bore_center_height_from_base])
      rotate([0, 90, 0])
      cylinder(r=(rod_diameter + clearance_diameter)/2, h=base_width + 2*overlap, center=true);
    
    // Clamp Gap Cut
    translate([0, 0, bracket_height/2])
      cube([clamp_gap, base_length*0.6 + 2*overlap, bracket_height + 2*overlap], center=true);
    
    // Mounting Holes
    translate([0, mount_hole_spacing/2, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    translate([0, -mount_hole_spacing/2, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    
    // Retention Screw Hole
    translate([0, 0, bore_center_height_from_base])
      rotate([0, 90, 0])
      cylinder(r=retention_screw_diameter/2, h=base_width + 2*overlap, center=true);
  }
}

// Rod - complete geometry
module rod() {
  color("DimGray") {
    translate([0, 0, bore_center_height_from_base])
      rotate([0, 90, 0])
      cylinder(r=rod_diameter/2, h=rod_length, center=true);
  }
}

// Assembly
module assembly() {
  sk_bracket();
  rod();
}

assembly();