// Parameters
rod_diameter = 8.0; //[4.0:16.0:0.1]
overall_height = 20.0; //[10.0:40.0:0.5]
base_width = 30.0; //[15.0:60.0:0.5]
base_length = 30.0; //[15.0:60.0:0.5]
base_thickness = 6.0; //[3.0:12.0:0.2]
upright_thickness = 8.0; //[4.0:16.0:0.2]
rod_center_height = 14.0; //[8.0:30.0:0.2]
rod_clearance = 0.2; //[0.0:0.6:0.05]
mount_hole_diameter = 4.2; //[3.0:6.5:0.1]
mount_hole_spacing = 20.0; //[12.0:40.0:0.5]
clamp_screw_diameter = 3.2; //[2.5:5.0:0.1]
clamp_screw_spacing = 16.0; //[10.0:30.0:0.5]
edge_chamfer = 1.0; //[0.0:3.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
clamp_cap_thickness = 6.0; //[3.0:12.0:0.2]
clamp_cap_height = 6.0; //[3.0:12.0:0.2]
rod_length = 40.0; //[20.0:120.0:1]
rod_web_thickness = 0.8; //[0.4:2.0:0.1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=64);
  }
}

// Bracket - complete geometry
module bracket() {
  color("Silver") difference() {
    union() {
      // Base block
      translate([0, 0, base_thickness/2])
        cube([base_width, base_length, base_thickness], center=true);
      
      // Support upright
      translate([0, 0, base_thickness + (overall_height - base_thickness)/2])
        cube([base_width, upright_thickness, overall_height - base_thickness], center=true);
      
      // Clamp cap or retainer
      translate([0, (upright_thickness/2 + clamp_cap_thickness/2 - overlap), 
                 rod_center_height + (rod_diameter + 2*rod_clearance)/2 + clamp_cap_height/2 - overlap])
        cube([base_width, clamp_cap_thickness, clamp_cap_height], center=true);
      
      // Rod connect web
      translate([0, 0, rod_center_height - (rod_diameter/4)])
        cube([rod_web_thickness, upright_thickness, (rod_diameter/2) + overlap], center=true);
      
      // Rod
      translate([0, 0, rod_center_height])
        rotate([0, 90, 0]) rod();
    }
    
    // Mounting holes
    translate([-mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);
    translate([mount_hole_spacing/2, 0, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);
    
    // Rod saddle bore
    translate([0, 0, rod_center_height])
      rotate([0, 90, 0])
      cylinder(r=(rod_diameter + 2*rod_clearance)/2, h=base_width + 2*overlap, center=true, $fn=64);
    
    // Fastener clearance holes
    translate([-clamp_screw_spacing/2, upright_thickness/2 + clamp_cap_thickness/2 - overlap, 
               rod_center_height + (rod_diameter + 2*rod_clearance)/2 + clamp_cap_height/2 - overlap])
      rotate([90, 0, 0])
      cylinder(r=clamp_screw_diameter/2, h=upright_thickness + clamp_cap_thickness + 4*overlap, center=true, $fn=32);
    translate([clamp_screw_spacing/2, upright_thickness/2 + clamp_cap_thickness/2 - overlap, 
               rod_center_height + (rod_diameter + 2*rod_clearance)/2 + clamp_cap_height/2 - overlap])
      rotate([90, 0, 0])
      cylinder(r=clamp_screw_diameter/2, h=upright_thickness + clamp_cap_thickness + 4*overlap, center=true, $fn=32);
    
    // Chamfer cuts
    translate([base_width/2 - edge_chamfer, base_length/2 - edge_chamfer, base_thickness/2])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, base_thickness + 2*overlap], center=true);
    translate([-base_width/2 + edge_chamfer, base_length/2 - edge_chamfer, base_thickness/2])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, base_thickness + 2*overlap], center=true);
    translate([base_width/2 - edge_chamfer, -base_length/2 + edge_chamfer, base_thickness/2])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, base_thickness + 2*overlap], center=true);
    translate([-base_width/2 + edge_chamfer, -base_length/2 + edge_chamfer, base_thickness/2])
      rotate([0, 0, 45])
      cube([edge_chamfer*2, edge_chamfer*2, base_thickness + 2*overlap], center=true);
  }
}

// Assembly
module assembly() {
  bracket();
}

assembly();