// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]
type_od = 4; //[2:8:0.1]
type_id = 2; //[1:6:0.1]
id = 2; //[1:6:0.1]
od = 4; //[2:10:0.1]
wall_min = 0.5; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer cylinder
      cylinder(h=length, r=max(od/2, (id/2 + wall_min)), center=true);
      // Inner cutter cylinder
      cylinder(h=length + overlap*2, r=id/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, center*(0) + (1-center)*(length/2)]) tubing();
}

assembly();