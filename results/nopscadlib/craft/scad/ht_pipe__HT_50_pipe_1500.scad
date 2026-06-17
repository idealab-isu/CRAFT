// Parameters
length_mm = 1500; //[750:3000:10]
ht50_outer_diameter = 50; //[45:60:0.5]
ht50_wall_thickness = 1.8; //[1.2:3.6:0.1]
socket_outer_diameter = 56; //[52:70:0.5]
socket_length = 45; //[25:90:1]
socket_wall_extra = 1.2; //[0.5:3:0.1]
stop_ring_length = 6; //[3:15:0.5]
stop_ring_radial = 1.0; //[0.5:3.0:0.1]
chamfer_length = 3; //[1:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe segment
    difference() {
      cylinder(h=length_mm, r=ht50_outer_diameter/2, center=false);
      translate([0, 0, ht50_wall_thickness])
        cylinder(h=length_mm - ht50_wall_thickness, r=ht50_outer_diameter/2 - ht50_wall_thickness, center=false);
    }
    
    // End fitting geometry
    union() {
      // Socket outer
      translate([0, 0, length_mm - socket_length - overlap_mm])
        cylinder(h=socket_length, r=socket_outer_diameter/2, center=false);
      
      // Socket bore main
      difference() {
        translate([0, 0, length_mm - socket_length - overlap_mm])
          cylinder(h=socket_length - stop_ring_length, r=ht50_outer_diameter/2 - ht50_wall_thickness - socket_wall_extra, center=false);
        
        // Stop ring
        translate([0, 0, length_mm - stop_ring_length - overlap_mm])
          cylinder(h=stop_ring_length, r=ht50_outer_diameter/2 - ht50_wall_thickness - socket_wall_extra - stop_ring_radial, center=false);
        
        // Chamfer
        translate([0, 0, length_mm - socket_length - overlap_mm])
          cylinder(h=chamfer_length, r1=ht50_outer_diameter/2 - ht50_wall_thickness - socket_wall_extra, r2=ht50_outer_diameter/2 - ht50_wall_thickness - socket_wall_extra + chamfer_length, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();