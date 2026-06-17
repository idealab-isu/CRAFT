// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 75; //[40:150:1]
length_mm = 250; //[125:500:1]
end_fitting = 1; //[0:1:1]
wall_thickness = 2.5; //[1.2:5:0.1]
od = 75; //[40:150:1]
overlap = 1; //[0.5:2:0.1]
fitting_length = 35; //[15:70:1]
fitting_wall_extra = 1.5; //[0.5:4:0.1]
fitting_od_extra = 4; //[1:10:0.5]
socket_depth = 25; //[10:60:1]
socket_clearance = 0.6; //[0.2:1.5:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Outer pipe
    cylinder(h=length_mm, r=od/2, center=false);
    
    // Inner pipe (subtracted)
    translate([0, 0, -overlap])
      cylinder(h=length_mm + 2*overlap, r=od/2 - wall_thickness, center=false);
    
    // Fitting outer cylinder
    if (end_fitting) {
      translate([0, 0, length_mm - overlap])
        cylinder(h=fitting_length, r=od/2 + fitting_od_extra, center=false);
      
      // Fitting socket void (subtracted)
      translate([0, 0, length_mm + fitting_length - socket_depth - overlap])
        cylinder(h=socket_depth + overlap, r=od/2 + socket_clearance, center=false);
      
      // Fitting through void (subtracted)
      translate([0, 0, length_mm - overlap])
        cylinder(h=fitting_length + 2*overlap, r=od/2 - wall_thickness, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();