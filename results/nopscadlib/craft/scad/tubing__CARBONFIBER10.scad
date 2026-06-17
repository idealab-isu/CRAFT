// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:30:0.5]
type_od = 10; //[5:20:0.5]
type_id = 8; //[3:18:0.5]
id_effective = (forced_id > 0 ? forced_id : type_id); //[3:18:0.5]
eps_overlap = 0.8; //[0.2:2:0.1]
use_path_sweep = 0; //[0:1:1]

// Tubing - complete geometry
module tubing() {
  color([0.2, 0.2, 0.2]) {
    difference() {
      // Outer cylinder
      cylinder(r=type_od/2, h=length, center=true);
      // Inner bore
      cylinder(r=id_effective/2, h=length + 2*eps_overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, (center == 1 ? 0 : length/2)]) tubing();
}

assembly();