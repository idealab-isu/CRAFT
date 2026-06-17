// Parameters
rod_diameter_mm = 16.0; //[8.0:32.0:0.1]
overall_height_mm = 27.0; //[14.0:54.0:0.1]
bracket_width_mm = 40.0; //[20.0:80.0:0.1]
base_length_mm = 50.0; //[25.0:100.0:0.1]
base_thickness_mm = 6.0; //[3.0:12.0:0.1]
wall_thickness_mm = 6.0; //[3.0:12.0:0.1]
rod_clearance_mm = 0.2; //[0.0:0.6:0.05]
mount_hole_diameter_mm = 5.5; //[3.0:10.0:0.1]
mount_hole_spacing_mm = 32.0; //[16.0:64.0:0.1]
clamp_bolt_diameter_mm = 5.0; //[3.0:8.0:0.1]
clamp_bolt_count = 2; //[1:4:1]
edge_fillet_radius_mm = 2.0; //[0.0:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
rod_length_mm = 60.0; //[30.0:150.0:0.5]
clamp_block_length_mm = 22.0; //[12.0:40.0:0.1]
clamp_split_gap_mm = 1.2; //[0.6:2.5:0.1]
clamp_bolt_spacing_mm = 16.0; //[10.0:28.0:0.1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter_mm/2, h=rod_length_mm, center=true, $fn=64);
  }
}

// Bracket - complete geometry
module bracket() {
  color("Silver") difference() {
    union() {
      // Mounting base
      translate([0, 0, 0])
        cube([base_length_mm, bracket_width_mm, base_thickness_mm], center=true);
      
      // Main body block
      translate([0, 0, (base_thickness_mm/2) + (overall_height_mm - base_thickness_mm)/2 - overlap_mm])
        cube([clamp_block_length_mm, bracket_width_mm, overall_height_mm - base_thickness_mm], center=true);
      
      // Gusset left
      translate([0, 0, 0])
        linear_extrude(height=bracket_width_mm, center=true)
        rotate([90, 0, 0])
        polygon(points=[
          [-base_length_mm/2, -base_thickness_mm/2],
          [-clamp_block_length_mm/2, -base_thickness_mm/2],
          [-clamp_block_length_mm/2, overall_height_mm - base_thickness_mm/2]
        ]);
      
      // Gusset right
      translate([0, 0, 0])
        linear_extrude(height=bracket_width_mm, center=true)
        rotate([90, 0, 0])
        polygon(points=[
          [clamp_block_length_mm/2, -base_thickness_mm/2],
          [base_length_mm/2, -base_thickness_mm/2],
          [clamp_block_length_mm/2, overall_height_mm - base_thickness_mm/2]
        ]);
    }
    
    // Rod seat or bore
    translate([0, 0, -base_thickness_mm/2 + wall_thickness_mm + (rod_diameter_mm + rod_clearance_mm)/2])
      rotate([90, 0, 0])
      cylinder(r=(rod_diameter_mm + rod_clearance_mm)/2, h=bracket_width_mm + 2*overlap_mm, center=true, $fn=64);
    
    // Clamp split
    translate([clamp_block_length_mm/2 - clamp_split_gap_mm/2, 0, (overall_height_mm/2) - (base_thickness_mm/2)])
      cube([clamp_split_gap_mm, bracket_width_mm + 2*overlap_mm, overall_height_mm + 2*overlap_mm], center=true);
    
    // Clamp bolt holes
    translate([0, clamp_bolt_spacing_mm/2, -base_thickness_mm/2 + wall_thickness_mm + (rod_diameter_mm + rod_clearance_mm)/2])
      rotate([0, 90, 0])
      cylinder(r=clamp_bolt_diameter_mm/2, h=clamp_block_length_mm + 2*overlap_mm, center=true, $fn=32);
    
    translate([0, -clamp_bolt_spacing_mm/2, -base_thickness_mm/2 + wall_thickness_mm + (rod_diameter_mm + rod_clearance_mm)/2])
      rotate([0, 90, 0])
      cylinder(r=clamp_bolt_diameter_mm/2, h=clamp_block_length_mm + 2*overlap_mm, center=true, $fn=32);
    
    // Mounting holes
    translate([mount_hole_spacing_mm/2, 0, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true, $fn=32);
    
    translate([-mount_hole_spacing_mm/2, 0, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  bracket();
  translate([0, 0, -base_thickness_mm/2 + wall_thickness_mm + (rod_diameter_mm)/2])
    rod();
}

assembly();