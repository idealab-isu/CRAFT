// Parameters
rod_diameter = 10.0; //[5.0:20.0:0.1]
rod_length = 60.0; //[30.0:120.0:1]
overall_height = 20.0; //[10.0:40.0:0.5]
fit_clearance = 0.2; //[0.0:0.6:0.05]
wall_thickness = 4.0; //[2.0:8.0:0.5]
base_thickness = 5.0; //[2.5:10.0:0.5]
base_length = 40.0; //[20.0:80.0:1]
base_width = 20.0; //[10.0:40.0:1]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing = 30.0; //[15.0:60.0:1]
mount_hole_edge_margin = 5.0; //[3.0:12.0:0.5]
bore_center_height_from_base = 12.0; //[6.0:24.0:0.5]
clamp_gap = 2.0; //[0.5:5.0:0.25]
overlap = 1.0; //[0.5:2.0:0.1]

// SK10 Bracket - complete geometry
module sk_bracket() {
  color("Silver") {
    // Mounting base
    translate([0, 0, base_thickness/2])
      cube([base_length, base_width, base_thickness], center=true);
    
    // Main body
    translate([0, 0, base_thickness + (overall_height - base_thickness)/2 - overlap])
      cube([2*(rod_diameter/2 + fit_clearance + wall_thickness), base_width, overall_height - base_thickness], center=true);
    
    // Rod support bore
    translate([0, 0, bore_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=rod_diameter/2 + fit_clearance, h=base_width + 2*overlap, center=true);
    
    // Clamp split
    translate([(rod_diameter/2 + fit_clearance + wall_thickness) - clamp_gap/2 + overlap, 0, overall_height/2])
      cube([clamp_gap, base_width + 2*overlap, overall_height + 2*overlap], center=true);
    
    // Mounting holes
    translate([-mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    translate([mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
  }
}

// Rod - complete geometry
module rod() {
  color("DimGray") {
    translate([0, 0, bore_center_height_from_base])
      rotate([90, 0, 0])
      cylinder(r=rod_diameter/2, h=rod_length, center=true);
  }
}

// Assembly
module assembly() {
  sk_bracket();
  rod();
}

assembly();