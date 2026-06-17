// Parameters
length = 15; //[7.5:30:0.5]
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 6; //[3:18:0.5]
forced_id = 0; //[0:18:0.5]
center = 1; //[0:1:1]
eps_overlap = 0.8; //[0.5:2:0.1]

$fn = 96;

// Tubing - single connected solid (hollow cylinder)
module tubing() {
  od = outer_diameter;
  id_req = (forced_id > 0) ? forced_id : inner_diameter;

  // Ensure valid wall thickness
  min_wall = 0.2;
  id_max = max(0, od - 2*min_wall);
  id = min(max(0, id_req), id_max);

  // Positioning: centered or sitting on Z=0
  zc = (center == 1) ? 0 : length/2;

  color([0.2, 0.2, 0.2])  // Neoprene color
  translate([0, 0, zc])
    difference() {
      cylinder(d=od, h=length, center=true);
      cylinder(d=id, h=length + 2*eps_overlap, center=true);
    }
}

module assembly() {
  tubing();
}

assembly();