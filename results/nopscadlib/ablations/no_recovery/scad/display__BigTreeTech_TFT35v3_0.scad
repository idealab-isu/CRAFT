// Parameters
width_mm = 84.5; //[42.25:169:0.1]
height_mm = 54.5; //[27.25:109:0.1]
thickness_mm = 10; //[5:20:0.1]
bezel_thickness_mm = 2.5; //[1:6:0.1]
bezel_frame_mm = 4; //[2:10:0.1]
aperture_width_mm = 76.5; //[38.25:153:0.1]
aperture_height_mm = 46.5; //[23.25:93:0.1]
aperture_offset_x_mm = 0; //[-10:10:0.1]
aperture_offset_y_mm = 0; //[-10:10:0.1]
pcb_thickness_mm = 1.6; //[0.8:3.2:0.1]
pcb_margin_mm = 2; //[0:6:0.1]
mount_hole_diameter_mm = 3.2; //[2:6.5:0.1]
mount_hole_edge_offset_x_mm = 6; //[3:15:0.1]
mount_hole_edge_offset_y_mm = 6; //[3:15:0.1]
mount_hole_placeholder_height_mm = 2.5; //[1:6:0.1]
mount_hole_boss_diameter_mm = 7; //[5:14:0.1]
display_glass_thickness_mm = 1.2; //[0.5:3:0.1]
display_recess_mm = 0.8; //[0:3:0.1]
mod_width_mm = 30; //[15:60:0.1]
mod_height_mm = 18; //[9:36:0.1]
mod_thickness_mm = 8; //[4:16:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Display module - complete geometry
module display() {
  color([0.0, 0.4, 0.2]) { // PCB green
    // Display module body
    cube([width_mm, height_mm, thickness_mm], center=true);
    
    // Front bezel face
    difference() {
      cube([width_mm, height_mm, bezel_thickness_mm], center=true);
      translate([aperture_offset_x_mm, aperture_offset_y_mm, 0])
        cube([aperture_width_mm, aperture_height_mm, bezel_thickness_mm + overlap_mm*2], center=true);
    }
    
    // Rear PCB plate
    translate([0, 0, -thickness_mm/2 - pcb_thickness_mm/2 + overlap_mm])
      cube([width_mm - 2*pcb_margin_mm, height_mm - 2*pcb_margin_mm, pcb_thickness_mm], center=true);
    
    // Mounting hole bosses
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (width_mm/2 - mount_hole_edge_offset_x_mm), y * (height_mm/2 - mount_hole_edge_offset_y_mm), -thickness_mm/2 - mount_hole_placeholder_height_mm/2 + overlap_mm])
        cylinder(r=mount_hole_boss_diameter_mm/2, h=mount_hole_placeholder_height_mm, center=true);
    }
    
    // Display glass
    translate([aperture_offset_x_mm, aperture_offset_y_mm, thickness_mm/2 + bezel_thickness_mm - display_recess_mm - display_glass_thickness_mm/2])
      cube([aperture_width_mm - 2*overlap_mm, aperture_height_mm - 2*overlap_mm, display_glass_thickness_mm], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color([0.1, 0.1, 0.6]) { // Blue
    translate([width_mm/2 + mod_width_mm/2 - overlap_mm, 0, -thickness_mm/2 + mod_thickness_mm/2])
      cube([mod_width_mm, mod_height_mm, mod_thickness_mm], center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    union() {
      display();
      mod();
    }
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (width_mm/2 - mount_hole_edge_offset_x_mm), y * (height_mm/2 - mount_hole_edge_offset_y_mm), 0])
        cylinder(r=mount_hole_diameter_mm/2, h=thickness_mm + bezel_thickness_mm + pcb_thickness_mm + mount_hole_placeholder_height_mm + overlap_mm*4, center=true);
    }
  }
}

assembly();