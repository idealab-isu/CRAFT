// Parameters
length_mm = 1000; //[500:2000:10]
ht125_outer_diameter = 125; //[100:250:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 2.5; //[1:6:0.1]
socket_od_extra = 6; //[2:15:0.5]
stop_ring_length = 8; //[3:20:0.5]
stop_ring_radial = 2; //[0.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=ht125_outer_diameter/2, center=false);
        translate([0, 0, -overlap_mm])
          cylinder(h=length_mm + 2*overlap_mm, r=ht125_outer_diameter/2 - wall_thickness, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=socket_length, r=ht125_outer_diameter/2 + socket_od_extra/2, center=false);
        translate([0, 0, length_mm - overlap_mm - overlap_mm])
          cylinder(h=socket_length + 2*overlap_mm, r=ht125_outer_diameter/2 - wall_thickness, center=false);
        translate([0, 0, length_mm + socket_length - stop_ring_length - overlap_mm - overlap_mm])
          cylinder(h=stop_ring_length + 2*overlap_mm, r=ht125_outer_diameter/2 - wall_thickness - stop_ring_radial, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();