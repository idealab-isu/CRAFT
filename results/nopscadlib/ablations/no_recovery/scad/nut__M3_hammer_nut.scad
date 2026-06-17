// Parameters
screw_diameter = 3.0; //[1.5:6.0:0.1]
hole_clearance = 0.3; //[0.0:0.8:0.05]
across_flats = 6.0; //[3.0:12.0:0.1]
thickness = 2.75; //[1.4:5.5:0.05]
t_slot_channel_width = 8.0; //[4.0:16.0:0.1]
t_slot_channel_depth = 6.0; //[3.0:12.0:0.1]
t_slot_lip_opening = 6.2; //[3.0:12.0:0.1]
retention_wing_thickness = 1.2; //[0.6:2.4:0.05]
retention_wing_height = 1.0; //[0.5:2.0:0.05]
retention_wing_length = 1.2; //[0.6:2.4:0.05]
lead_in_chamfer = 0.6; //[0.2:1.5:0.05]
overlap = 0.8; //[0.2:2.0:0.1]
washer_outer_diameter = 7.0; //[4.0:14.0:0.1]
washer_thickness = 0.8; //[0.4:2.0:0.05]
nut_and_washer_gap = 0.6; //[0.0:3.0:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex body
    difference() {
      union() {
        // Hex profile
        translate([0, 0, 0])
          cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
        
        // Retention wings
        translate([across_flats/2 + (retention_wing_length + overlap)/2 - overlap, 0, -thickness/2 + retention_wing_height/2])
          cube([retention_wing_length + overlap, retention_wing_thickness, retention_wing_height], center=true);
        translate([-(across_flats/2 + (retention_wing_length + overlap)/2 - overlap), 0, -thickness/2 + retention_wing_height/2])
          cube([retention_wing_length + overlap, retention_wing_thickness, retention_wing_height], center=true);
      }
      
      // Lead-in chamfers
      translate([across_flats/2 - lead_in_chamfer/2, across_flats/2 - lead_in_chamfer/2, 0])
        cube([lead_in_chamfer, lead_in_chamfer, thickness + 2*overlap], center=true);
      translate([-(across_flats/2 - lead_in_chamfer/2), across_flats/2 - lead_in_chamfer/2, 0])
        cube([lead_in_chamfer, lead_in_chamfer, thickness + 2*overlap], center=true);
      translate([across_flats/2 - lead_in_chamfer/2, -(across_flats/2 - lead_in_chamfer/2), 0])
        cube([lead_in_chamfer, lead_in_chamfer, thickness + 2*overlap], center=true);
      translate([-(across_flats/2 - lead_in_chamfer/2), -(across_flats/2 - lead_in_chamfer/2), 0])
        cube([lead_in_chamfer, lead_in_chamfer, thickness + 2*overlap], center=true);
      
      // Central screw hole
      translate([0, 0, 0])
        cylinder(r=(screw_diameter + hole_clearance)/2, h=thickness + 2*overlap, center=true);
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, thickness/2 + nut_and_washer_gap + washer_thickness/2 - overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, thickness/2 + nut_and_washer_gap + washer_thickness/2 - overlap])
        cylinder(r=(screw_diameter + hole_clearance)/2, h=washer_thickness + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();