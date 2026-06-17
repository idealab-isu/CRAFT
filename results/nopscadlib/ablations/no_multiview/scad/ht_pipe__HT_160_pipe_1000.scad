// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 160; //[80:320:1]
length_mm = 1000; //[500:2000:10]
od_mm = 160; //[120:200:1]
wall_thickness_mm = 4.0; //[2.0:8.0:0.5]
interface_length_mm = 35; //[15:80:1]
interface_radial_add_mm = 2.0; //[0.5:6.0:0.5]
connect_overlap_mm = 1.0; //[0.5:2.0:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe
      cylinder(h=length_mm, r=od_mm/2, center=true, $fn=64);
      // Hollow bore
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*connect_overlap_mm, r=od_mm/2 - wall_thickness_mm, center=true, $fn=64);
    }
    // End fitting interface
    translate([0, 0, length_mm/2 - interface_length_mm/2 + connect_overlap_mm])
      cylinder(h=interface_length_mm, r=od_mm/2 + interface_radial_add_mm, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();