// Parameters
rod_diameter_mm = 12.0; //[6.0:24.0:0.1]
rod_length_mm = 60.0; //[30.0:120.0:1]
overall_height_mm = 23.0; //[12.0:46.0:0.1]
bracket_width_mm = 30.0; //[15.0:60.0:0.5]
bracket_depth_mm = 20.0; //[10.0:40.0:0.5]
base_thickness_mm = 6.0; //[3.0:12.0:0.1]
wall_thickness_mm = 4.0; //[2.0:8.0:0.1]
rod_clearance_mm = 0.2; //[0.0:0.8:0.05]
mount_hole_diameter_mm = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_mm = 20.0; //[10.0:40.0:0.5]
mount_hole_edge_margin_mm = 5.0; //[2.0:10.0:0.5]
fillet_radius_mm = 2.0; //[0.5:4.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    translate([0, 0, overall_height_mm - (rod_diameter_mm + rod_clearance_mm) / 2])
      rotate([0, 90, 0])
      cylinder(r=rod_diameter_mm / 2, h=rod_length_mm, center=true);
  }
}

// Bracket - complete geometry
module bracket() {
  color("Silver") {
    difference() {
      union() {
        // Mounting base
        translate([0, 0, base_thickness_mm / 2])
          cube([bracket_width_mm, bracket_depth_mm, base_thickness_mm], center=true);
        
        // Support body
        translate([0, 0, base_thickness_mm + (overall_height_mm - base_thickness_mm) / 2])
          cube([bracket_width_mm, wall_thickness_mm, overall_height_mm - base_thickness_mm], center=true);
        
        // Fillet gussets
        hull() {
          translate([-(bracket_width_mm / 2 - fillet_radius_mm), 0, base_thickness_mm + fillet_radius_mm])
            sphere(r=fillet_radius_mm);
          translate([-(bracket_width_mm / 2 - fillet_radius_mm), 0, base_thickness_mm + (overall_height_mm - base_thickness_mm) / 2])
            sphere(r=fillet_radius_mm);
        }
        hull() {
          translate([(bracket_width_mm / 2 - fillet_radius_mm), 0, base_thickness_mm + fillet_radius_mm])
            sphere(r=fillet_radius_mm);
          translate([(bracket_width_mm / 2 - fillet_radius_mm), 0, base_thickness_mm + (overall_height_mm - base_thickness_mm) / 2])
            sphere(r=fillet_radius_mm);
        }
      }
      
      // Rod bore or cradle
      translate([0, 0, overall_height_mm - (rod_diameter_mm + rod_clearance_mm) / 2])
        rotate([0, 90, 0])
        cylinder(r=(rod_diameter_mm + rod_clearance_mm) / 2, h=bracket_width_mm + 2 * overlap_mm, center=true);
      
      // Mounting holes
      translate([-mount_hole_spacing_mm / 2, 0, base_thickness_mm / 2])
        cylinder(r=mount_hole_diameter_mm / 2, h=base_thickness_mm + 2 * overlap_mm, center=true);
      translate([mount_hole_spacing_mm / 2, 0, base_thickness_mm / 2])
        cylinder(r=mount_hole_diameter_mm / 2, h=base_thickness_mm + 2 * overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  bracket();
  rod();
}

assembly();