// Parameters
nominal_size = 160; //[80:320:1]
length_mm = 1500; //[750:3000:10]
od_mm = 160; //[120:240:1]
wall_mm = 4.0; //[2.0:8.0:0.1]
fit_len_mm = 70; //[40:140:1]
fit_od_mm = 175; //[160:220:1]
fit_wall_mm = 5.0; //[2.5:10.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
clearance_mm = 0.5; //[0.2:1.5:0.1]

// HT Pipe Segment - Complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe segment
      difference() {
        cylinder(h=length_mm, r=od_mm/2, center=false);
        translate([0, 0, wall_mm])
          cylinder(h=length_mm, r=od_mm/2 - wall_mm, center=false);
      }
      // Integrated end fitting
      translate([0, 0, length_mm - overlap_mm])
        difference() {
          cylinder(h=fit_len_mm, r=fit_od_mm/2, center=false);
          cylinder(h=fit_len_mm, r=od_mm/2 + clearance_mm, center=false);
        }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();