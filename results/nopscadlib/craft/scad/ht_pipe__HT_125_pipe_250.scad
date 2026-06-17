// Parameters
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 250; //[125:500:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fit_length_mm = 45; //[25:90:1]
fit_wall_extra_mm = 2.0; //[0.8:5.0:0.1]
fit_od_extra_mm = 6.0; //[2.0:15.0:0.5]
socket_clearance_mm = 1.0; //[0.2:2.5:0.1]
stop_ring_thickness_mm = 2.0; //[0.8:5.0:0.1]
stop_ring_depth_mm = 3.0; //[1.0:8.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=true);
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*overlap_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=true);
    }
    
    // End fitting detail
    difference() {
      union() {
        translate([0, 0, length_mm/2 - fit_length_mm/2 + overlap_mm])
          cylinder(h=fit_length_mm, r=nominal_diameter_mm/2 + fit_od_extra_mm/2, center=true);
        translate([0, 0, 0])
          cylinder(h=length_mm, r=nominal_diameter_mm/2, center=true);
      }
      translate([0, 0, length_mm/2 - fit_length_mm/2 + overlap_mm])
        cylinder(h=fit_length_mm + 2*overlap_mm, r=nominal_diameter_mm/2 + socket_clearance_mm, center=true);
      translate([0, 0, length_mm/2 - fit_length_mm + stop_ring_thickness_mm/2])
        cylinder(h=stop_ring_thickness_mm + 2*overlap_mm, r=nominal_diameter_mm/2 + socket_clearance_mm - stop_ring_depth_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();