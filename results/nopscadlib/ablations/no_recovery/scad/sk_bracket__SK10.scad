// Parameters
rod_diameter = 10; //[5:20:0.1]
bracket_height = 20; //[10:40:0.5]
base_width = 30; //[15:60:0.5]
base_length = 40; //[20:80:0.5]
body_thickness = 8; //[4:16:0.5]
rod_clearance = 0.2; //[0:0.6:0.05]
mount_hole_diameter = 5; //[3:8:0.1]
mount_hole_spacing = 24; //[12:48:0.5]
edge_margin = 5; //[2.5:10:0.5]
clamp_screw_diameter = 4; //[2:6:0.1]
gusset_thickness = 4; //[2:8:0.5]
base_thickness = 6; //[3:12:0.5]
overlap = 1; //[0.5:2:0.1]
bore_center_z = 14; //[10:18:0.5]
upright_width = 22; //[12:40:0.5]
rod_length = 60; //[30:120:1]
split_gap = 1.5; //[0.8:3:0.1]

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
      // Base plate
      translate([0, 0, base_thickness/2])
        cube([base_width, base_length, base_thickness], center=true);
      
      // Upright block
      translate([0, 0, base_thickness + (bracket_height - base_thickness + overlap)/2 - overlap])
        cube([upright_width, body_thickness, bracket_height - base_thickness + overlap], center=true);
      
      // Gusset left
      translate([-(base_width/2 - (base_width/2 - edge_margin)/2 - edge_margin/2), 0, base_thickness + (bracket_height - base_thickness)/2 - overlap])
        cube([base_width/2 - edge_margin, gusset_thickness, bracket_height - base_thickness], center=true);
      
      // Gusset right
      translate([(base_width/2 - (base_width/2 - edge_margin)/2 - edge_margin/2), 0, base_thickness + (bracket_height - base_thickness)/2 - overlap])
        cube([base_width/2 - edge_margin, gusset_thickness, bracket_height - base_thickness], center=true);
    }
    
    // Rod bore cutter
    translate([0, 0, bore_center_z])
      rotate([90, 0, 0])
      cylinder(r=(rod_diameter + rod_clearance)/2, h=body_thickness + 2*overlap, center=true, $fn=64);
    
    // Clamp split cutter
    translate([0, 0, base_thickness + (bracket_height - base_thickness)/2])
      cube([upright_width + 2*overlap, split_gap, bracket_height - base_thickness + 2*overlap], center=true);
    
    // Clamp screw cutter
    translate([0, 0, bore_center_z])
      rotate([0, 90, 0])
      cylinder(r=clamp_screw_diameter/2, h=upright_width + 2*overlap, center=true, $fn=32);
    
    // Mount hole cutter 1
    translate([0, mount_hole_spacing/2, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);
    
    // Mount hole cutter 2
    translate([0, -mount_hole_spacing/2, base_thickness/2])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  bracket();
  translate([0, 0, bore_center_z]) rotate([90, 0, 0]) rod();
}

assembly();