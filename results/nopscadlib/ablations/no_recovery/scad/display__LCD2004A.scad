// Parameters
module_type = 2004; //[1000:4000:1]
width_mm = 97; //[48.5:194:0.1]
height_mm = 39.5; //[19.75:79:0.1]
thickness_mm = 14; //[7:28:0.1]
include_mounting_holes = 1; //[0:1:1]
include_aperture = 1; //[0:1:1]
include_pcb_volume = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
body_corner_radius_mm = 0.5; //[0:3:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_mm = 0; //[0:3:0.1]
aperture_width_mm = 76; //[38:152:0.1]
aperture_height_mm = 25; //[12.5:50:0.1]
aperture_depth_mm = 2; //[1:6:0.1]
aperture_inset_from_front_mm = 0.5; //[0:3:0.1]
glass_width_mm = 70; //[35:140:0.1]
glass_height_mm = 20; //[10:40:0.1]
glass_thickness_mm = 3; //[1.5:8:0.1]
mount_hole_diameter_mm = 3.2; //[2:6.4:0.1]
mount_hole_edge_offset_x_mm = 3.5; //[2:10:0.1]
mount_hole_edge_offset_y_mm = 3.5; //[2:10:0.1]
mount_hole_height_mm = 6; //[3:20:0.1]

// Display module body
module display_module_body() {
  color([0.0, 0.4, 0.2]) // PCB green
  cube([width_mm, height_mm, thickness_mm], center=true);
}

// PCB thickness volume
module pcb_thickness_volume() {
  color([0.1, 0.1, 0.6]) // PCB blue
  translate([0, 0, -thickness_mm/2 + pcb_thickness_mm/2 + overlap_mm])
    cube([width_mm - 2*pcb_margin_mm, height_mm - 2*pcb_margin_mm, pcb_thickness_mm], center=true);
}

// Display aperture window
module display_aperture_window() {
  color("White")
  translate([0, 0, thickness_mm/2 - aperture_inset_from_front_mm - aperture_depth_mm/2 - overlap_mm])
    cube([aperture_width_mm, aperture_height_mm, aperture_depth_mm], center=true);
}

// Display glass
module display() {
  color("Black")
  translate([0, 0, thickness_mm/2 - aperture_inset_from_front_mm - glass_thickness_mm/2 - overlap_mm])
    cube([glass_width_mm, glass_height_mm, glass_thickness_mm], center=true);
}

// Mounting holes
module mounting_hole_pattern() {
  color("Silver")
  union() {
    translate([-width_mm/2 + mount_hole_edge_offset_x_mm, -height_mm/2 + mount_hole_edge_offset_y_mm, -thickness_mm/2 + mount_hole_height_mm/2 + overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=mount_hole_height_mm, center=true);
    translate([width_mm/2 - mount_hole_edge_offset_x_mm, -height_mm/2 + mount_hole_edge_offset_y_mm, -thickness_mm/2 + mount_hole_height_mm/2 + overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=mount_hole_height_mm, center=true);
    translate([-width_mm/2 + mount_hole_edge_offset_x_mm, height_mm/2 - mount_hole_edge_offset_y_mm, -thickness_mm/2 + mount_hole_height_mm/2 + overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=mount_hole_height_mm, center=true);
    translate([width_mm/2 - mount_hole_edge_offset_x_mm, height_mm/2 - mount_hole_edge_offset_y_mm, -thickness_mm/2 + mount_hole_height_mm/2 + overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=mount_hole_height_mm, center=true);
  }
}

// Complete module assembly
module mod() {
  union() {
    display_module_body();
    if (include_pcb_volume) pcb_thickness_volume();
    if (include_aperture) display_aperture_window();
    display();
    if (include_mounting_holes) mounting_hole_pattern();
  }
}

// Final assembly
module assembly() {
  mod();
}

assembly();