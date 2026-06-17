// Parameters
rod_diameter_mm = 12.0; //[6.0:24.0:0.1]
rod_length_mm = 60.0; //[30.0:120.0:1]
overall_height_mm = 23.0; //[12.0:46.0:0.1]
bore_clearance_mm = 0.2; //[0.0:0.6:0.05]
bracket_width_mm = 30.0; //[15.0:60.0:0.5]
bracket_depth_mm = 20.0; //[10.0:40.0:0.5]
base_thickness_mm = 6.0; //[3.0:12.0:0.5]
side_wall_thickness_mm = 5.0; //[2.5:10.0:0.5]
mount_hole_diameter_mm = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_mm = 20.0; //[10.0:40.0:0.5]
clamp_split_width_mm = 2.0; //[0.8:4.0:0.1]
fillet_radius_mm = 2.0; //[0.5:5.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter_mm/2, h=rod_length_mm, center=true, $fn=32);
  }
}

// Bracket - complete geometry
module bracket() {
  color("Silver") {
    difference() {
      union() {
        // Base foot
        translate([0, 0, base_thickness_mm/2])
          cube([bracket_width_mm, bracket_depth_mm, base_thickness_mm], center=true);
        
        // Bracket body with gussets
        union() {
          // Bracket body block
          translate([0, 0, base_thickness_mm + (overall_height_mm - base_thickness_mm)/2 - overlap_mm])
            cube([bracket_width_mm, side_wall_thickness_mm, overall_height_mm - base_thickness_mm], center=true);
          
          // Gusset left
          translate([-bracket_width_mm/2 + fillet_radius_mm, 0, base_thickness_mm + (overall_height_mm - base_thickness_mm)/2 - overlap_mm])
            cube([fillet_radius_mm*2, bracket_depth_mm, overall_height_mm - base_thickness_mm], center=true);
          
          // Gusset right
          translate([bracket_width_mm/2 - fillet_radius_mm, 0, base_thickness_mm + (overall_height_mm - base_thickness_mm)/2 - overlap_mm])
            cube([fillet_radius_mm*2, bracket_depth_mm, overall_height_mm - base_thickness_mm], center=true);
        }
      }
      
      // Rod bore
      translate([0, 0, base_thickness_mm + (overall_height_mm - base_thickness_mm) - (rod_diameter_mm + bore_clearance_mm)/2 - overlap_mm])
        rotate([0, 90, 0])
        cylinder(r=(rod_diameter_mm + bore_clearance_mm)/2, h=bracket_width_mm + 2*overlap_mm, center=true, $fn=32);
      
      // Clamp split slot
      translate([bracket_width_mm/2 - clamp_split_width_mm/2, 0, base_thickness_mm + (overall_height_mm - base_thickness_mm)/2])
        cube([clamp_split_width_mm, side_wall_thickness_mm + 2*overlap_mm, (overall_height_mm - base_thickness_mm) + 2*overlap_mm], center=true);
      
      // Mounting holes
      translate([-mount_hole_spacing_mm/2, 0, base_thickness_mm/2])
        cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true, $fn=32);
      translate([mount_hole_spacing_mm/2, 0, base_thickness_mm/2])
        cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  bracket();
  translate([0, 0, base_thickness_mm + (overall_height_mm - base_thickness_mm) - (rod_diameter_mm + bore_clearance_mm)/2 - overlap_mm])
    rotate([0, 90, 0])
    rod();
}

assembly();