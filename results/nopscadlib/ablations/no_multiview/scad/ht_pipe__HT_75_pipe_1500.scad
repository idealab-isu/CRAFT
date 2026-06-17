// Parameters
length_mm = 1500; //[750:3000:10]
ht75_outer_diameter_mm = 75; //[60:90:1]
ht75_wall_thickness_mm = 2.7; //[1.5:5.4:0.1]
end_fitting_length_mm = 55; //[30:110:1]
end_fitting_od_scale = 1.08; //[1.02:1.2:0.01]
end_fitting_wall_scale = 1.2; //[1.0:2.0:0.05]
connection_overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=ht75_outer_diameter_mm/2, center=false);
      translate([0, 0, ht75_wall_thickness_mm])
        cylinder(h=length_mm, r=ht75_outer_diameter_mm/2 - ht75_wall_thickness_mm, center=false);
    }
    
    // End fitting
    difference() {
      translate([0, 0, length_mm - connection_overlap_mm])
        cylinder(h=end_fitting_length_mm, r=(ht75_outer_diameter_mm * end_fitting_od_scale) / 2, center=false);
      translate([0, 0, length_mm - connection_overlap_mm + (ht75_wall_thickness_mm * end_fitting_wall_scale)])
        cylinder(h=end_fitting_length_mm, r=(ht75_outer_diameter_mm * end_fitting_od_scale) / 2 - (ht75_wall_thickness_mm * end_fitting_wall_scale), center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();