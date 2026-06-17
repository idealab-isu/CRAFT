// Parameters
width_mm = 97; //[48.5:194:0.5]
height_mm = 39.5; //[19.75:79:0.5]
thickness_mm = 14; //[7:28:0.5]
plane_thickness_mm = 0.8; //[0.2:2:0.1]
overlap_mm = 1; //[0.5:2:0.1]
include_mounting_holes = 0; //[0:1:1]
hole_diameter_mm = 3.2; //[1.6:6.4:0.1]
hole_edge_margin_x_mm = 3.5; //[1.5:7:0.1]
hole_edge_margin_y_mm = 3.5; //[1.5:7:0.1]
hole_boss_height_mm = 2; //[1:6:0.5]
include_viewing_aperture = 0; //[0:1:1]
aperture_width_mm = 76; //[38:152:0.5]
aperture_height_mm = 25; //[12.5:50:0.5]
aperture_inset_z_mm = 0.2; //[0:2:0.1]
display_inset_from_front_mm = 1.5; //[0.5:5:0.1]
display_thickness_mm = 6; //[2:12:0.5]
display_width_mm = 80; //[40:160:0.5]
display_height_mm = 28; //[14:56:0.5]

// Display module - complete geometry
module display() {
  color([0.0, 0.4, 0.2]) {
    // Display body
    translate([0, 0, thickness_mm/2 - display_inset_from_front_mm - display_thickness_mm/2])
      cube([display_width_mm, display_height_mm, display_thickness_mm], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color([0.85, 0.85, 0.8]) {
    // Main body
    cube([width_mm, height_mm, thickness_mm], center=true);
    
    // Front face plane
    translate([0, 0, thickness_mm/2 - plane_thickness_mm/2 + overlap_mm])
      cube([width_mm, height_mm, plane_thickness_mm], center=true);
    
    // Rear face plane
    translate([0, 0, -thickness_mm/2 + plane_thickness_mm/2 - overlap_mm])
      cube([width_mm, height_mm, plane_thickness_mm], center=true);
    
    // Optional mounting holes
    if (include_mounting_holes) {
      color("Silver") {
        translate([width_mm/2 - hole_edge_margin_x_mm, height_mm/2 - hole_edge_margin_y_mm, -thickness_mm/2 + hole_boss_height_mm/2 - overlap_mm])
          cylinder(r=hole_diameter_mm/2, h=hole_boss_height_mm, center=true);
        translate([-(width_mm/2 - hole_edge_margin_x_mm), height_mm/2 - hole_edge_margin_y_mm, -thickness_mm/2 + hole_boss_height_mm/2 - overlap_mm])
          cylinder(r=hole_diameter_mm/2, h=hole_boss_height_mm, center=true);
        translate([width_mm/2 - hole_edge_margin_x_mm, -(height_mm/2 - hole_edge_margin_y_mm), -thickness_mm/2 + hole_boss_height_mm/2 - overlap_mm])
          cylinder(r=hole_diameter_mm/2, h=hole_boss_height_mm, center=true);
        translate([-(width_mm/2 - hole_edge_margin_x_mm), -(height_mm/2 - hole_edge_margin_y_mm), -thickness_mm/2 + hole_boss_height_mm/2 - overlap_mm])
          cylinder(r=hole_diameter_mm/2, h=hole_boss_height_mm, center=true);
      }
    }
    
    // Optional viewing aperture
    if (include_viewing_aperture) {
      difference() {
        translate([0, 0, thickness_mm/2 - plane_thickness_mm/2 + overlap_mm])
          cube([width_mm, height_mm, plane_thickness_mm], center=true);
        translate([0, 0, thickness_mm/2 - plane_thickness_mm/2 + overlap_mm])
          cube([aperture_width_mm, aperture_height_mm, plane_thickness_mm + aperture_inset_z_mm + overlap_mm], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  display();
  mod();
}

assembly();