// Parameters
length_mm = 500; //[250:1000:1]
ht50_outer_diameter_mm = 50; //[40:70:0.5]
ht50_wall_thickness_mm = 1.8; //[1:3.6:0.1]
fitting_length_mm = 35; //[20:70:1]
fitting_outer_diameter_mm = 56; //[50:80:0.5]
fitting_wall_thickness_mm = 2.5; //[1.5:5:0.1]
socket_depth_mm = 25; //[10:50:1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
chamfer_height_mm = 2; //[0.5:6:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe body
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht50_outer_diameter_mm/2, center=false);
      
      // Inner void of the pipe
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=ht50_outer_diameter_mm/2 - ht50_wall_thickness_mm, center=false);
    }
    
    // End fitting
    difference() {
      // Outer fitting
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fitting_length_mm, r=fitting_outer_diameter_mm/2, center=false);
      
      // Inner through void
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fitting_length_mm + overlap_mm, r=ht50_outer_diameter_mm/2 - ht50_wall_thickness_mm, center=false);
      
      // Socket void
      translate([0, 0, length_mm + fitting_length_mm - socket_depth_mm])
        cylinder(h=socket_depth_mm, r=ht50_outer_diameter_mm/2 + socket_clearance_mm, center=false);
      
      // Chamfer void
      translate([0, 0, length_mm + fitting_length_mm - chamfer_height_mm])
        cylinder(h=chamfer_height_mm, r1=ht50_outer_diameter_mm/2 + socket_clearance_mm + chamfer_height_mm, r2=ht50_outer_diameter_mm/2 + socket_clearance_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();