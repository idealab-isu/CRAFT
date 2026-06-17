// Parameters
nominal_diameter_mm = 75; //[40:160:1]
length_mm = 500; //[250:1000:1]
ht75_outer_diameter_mm = 75; //[60:90:0.5]
wall_thickness_mm = 2.2; //[1.2:4.4:0.1]
fitting_length_mm = 45; //[25:90:1]
fitting_wall_extra_mm = 1.8; //[0.8:4:0.1]
fitting_od_extra_mm = 6; //[2:14:0.5]
socket_depth_mm = 35; //[15:70:1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=ht75_outer_diameter_mm/2, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=ht75_outer_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    difference() {
      union() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=ht75_outer_diameter_mm/2 + fitting_od_extra_mm/2, center=false);
        cylinder(h=length_mm, r=ht75_outer_diameter_mm/2, center=false);
      }
      translate([0, 0, length_mm - overlap_mm/2])
        cylinder(h=socket_depth_mm + overlap_mm, r=ht75_outer_diameter_mm/2 + socket_clearance_mm, center=false);
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fitting_length_mm + overlap_mm, r=ht75_outer_diameter_mm/2 - wall_thickness_mm, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=ht75_outer_diameter_mm/2 - wall_thickness_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();