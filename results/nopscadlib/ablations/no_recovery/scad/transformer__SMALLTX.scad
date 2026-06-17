// Parameters
width_mm = 38; //[19:76:0.5]
depth_mm = 32; //[16:64:0.5]
height_mm = 33; //[16.5:66:0.5]
corner_radius_mm = 2; //[1:4:0.25]
mount_hole_diameter_mm = 3.2; //[2:6.4:0.1]
mount_hole_spacing_x_mm = 28; //[14:56:0.5]
mount_hole_spacing_y_mm = 22; //[11:44:0.5]
footplate_thickness_mm = 2; //[1:4:0.25]
lamination_height_mm = 22; //[11:44:0.5]
bobbin_height_mm = 9; //[4.5:18:0.5]
terminal_height_mm = 2; //[1:6:0.25]
lamination_width_ratio = 0.78; //[0.6:0.9:0.01]
lamination_depth_ratio = 0.72; //[0.55:0.9:0.01]
bobbin_width_ratio = 0.62; //[0.45:0.85:0.01]
bobbin_depth_ratio = 0.95; //[0.7:1:0.01]
terminal_width_ratio = 0.7; //[0.5:0.95:0.01]
terminal_depth_ratio = 0.75; //[0.5:0.95:0.01]
connect_overlap_mm = 1; //[0.5:2:0.1]

// Transformer - complete geometry
module transformer() {
  // Footplate with rounded corners
  color("DimGray") {
    difference() {
      hull() {
        translate([width_mm/2 - corner_radius_mm, depth_mm/2 - corner_radius_mm, footplate_thickness_mm/2])
          cylinder(r=corner_radius_mm, h=footplate_thickness_mm, center=true);
        translate([-width_mm/2 + corner_radius_mm, depth_mm/2 - corner_radius_mm, footplate_thickness_mm/2])
          cylinder(r=corner_radius_mm, h=footplate_thickness_mm, center=true);
        translate([-width_mm/2 + corner_radius_mm, -depth_mm/2 + corner_radius_mm, footplate_thickness_mm/2])
          cylinder(r=corner_radius_mm, h=footplate_thickness_mm, center=true);
        translate([width_mm/2 - corner_radius_mm, -depth_mm/2 + corner_radius_mm, footplate_thickness_mm/2])
          cylinder(r=corner_radius_mm, h=footplate_thickness_mm, center=true);
        translate([0, 0, footplate_thickness_mm/2])
          cube([width_mm - 2*corner_radius_mm, depth_mm - 2*corner_radius_mm, footplate_thickness_mm], center=true);
      }
      // Mounting holes
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * mount_hole_spacing_x_mm/2, y * mount_hole_spacing_y_mm/2, footplate_thickness_mm/2])
            cylinder(r=mount_hole_diameter_mm/2, h=footplate_thickness_mm + 2*connect_overlap_mm, center=true);
    }
  }

  // Lamination stack
  color("Black") {
    translate([0, 0, footplate_thickness_mm + lamination_height_mm/2 - connect_overlap_mm])
      cube([width_mm * lamination_width_ratio, depth_mm * lamination_depth_ratio, lamination_height_mm], center=true);
  }

  // Bobbin/coil block
  color("Silver") {
    translate([0, 0, footplate_thickness_mm + lamination_height_mm - connect_overlap_mm + bobbin_height_mm/2 - connect_overlap_mm])
      cube([width_mm * bobbin_width_ratio, depth_mm * bobbin_depth_ratio, bobbin_height_mm], center=true);
  }

  // Terminal block
  color("Copper") {
    translate([0, 0, footplate_thickness_mm + lamination_height_mm + bobbin_height_mm - 2*connect_overlap_mm + terminal_height_mm/2 - connect_overlap_mm])
      cube([width_mm * terminal_width_ratio, depth_mm * terminal_depth_ratio, terminal_height_mm], center=true);
  }
}

// Assembly
module assembly() {
  transformer();
}

assembly();