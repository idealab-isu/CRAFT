// Parameters
length = 15; //[8:60:1]
tubing_od = 4; //[2:8:0.5]
tubing_id = 2; //[1:6:0.5]
forced_id = 0; //[0:6:0.5]
center = 1; //[0:1:1]
eps = 0.8; //[0.2:2:0.1]

$fn = 96;

// PTFE Tubing - complete geometry (single connected solid)
module tubing() {
  od = max(tubing_od, 0.01);
  id_req = (forced_id > 0) ? forced_id : tubing_id;
  id = min(max(id_req, 0), od - 0.01); // ensure wall thickness > 0
  z0 = (center == 1) ? 0 : length/2;

  color([0.85, 0.85, 0.8])  // Off-white for PTFE
  translate([0, 0, z0])
    difference() {
      cylinder(h=length, r=od/2, center=true);
      cylinder(h=length + 2*eps, r=id/2, center=true);
    }
}

module assembly() {
  tubing();
}

assembly();