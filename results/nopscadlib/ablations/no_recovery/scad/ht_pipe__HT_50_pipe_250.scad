// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 50; //[25:100:1]
length_mm = 250; //[125:500:1]
end_fitting = 1; //[0:1:1]
pipe_od_mm = 50; //[25:100:1]
pipe_wall_mm = 2.4; //[1.2:4.8:0.1]
fit_length_mm = 35; //[18:70:1]
fit_wall_extra_mm = 1.6; //[0.8:3.2:0.1]
fit_clearance_mm = 0.4; //[0.2:1.0:0.1]
connect_overlap_mm = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe outer cylinder
    cylinder(h=length_mm - end_fitting * fit_length_mm, r=pipe_od_mm / 2, center=false);
    
    // Pipe inner void
    translate([0, 0, 0])
      cylinder(h=length_mm - end_fitting * fit_length_mm, r=pipe_od_mm / 2 - pipe_wall_mm, center=false);
    
    // Fitting outer cylinder
    translate([0, 0, length_mm - end_fitting * fit_length_mm - connect_overlap_mm])
      cylinder(h=end_fitting * fit_length_mm, r=pipe_od_mm / 2 + end_fitting * fit_wall_extra_mm, center=false);
    
    // Fitting inner void
    translate([0, 0, length_mm - end_fitting * fit_length_mm - connect_overlap_mm])
      cylinder(h=end_fitting * fit_length_mm + connect_overlap_mm, r=pipe_od_mm / 2 + end_fitting * fit_clearance_mm, center=false);
  }
}

// Module for the complete assembly
module assembly() {
  difference() {
    // HT Pipe Tube
    difference() {
      // Outer pipe
      cylinder(h=length_mm - end_fitting * fit_length_mm, r=pipe_od_mm / 2, center=false);
      // Inner void
      translate([0, 0, 0])
        cylinder(h=length_mm - end_fitting * fit_length_mm, r=pipe_od_mm / 2 - pipe_wall_mm, center=false);
    }
    // Integrated end fitting
    difference() {
      // Outer fitting
      translate([0, 0, length_mm - end_fitting * fit_length_mm - connect_overlap_mm])
        cylinder(h=end_fitting * fit_length_mm, r=pipe_od_mm / 2 + end_fitting * fit_wall_extra_mm, center=false);
      // Inner void
      translate([0, 0, length_mm - end_fitting * fit_length_mm - connect_overlap_mm])
        cylinder(h=end_fitting * fit_length_mm + connect_overlap_mm, r=pipe_od_mm / 2 + end_fitting * fit_clearance_mm, center=false);
    }
  }
}

// Call the assembly
assembly();