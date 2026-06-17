// PTFE Tubing (hollow cylindrical tube)

// Parameters
length = 15; //[8:30:1]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[1:6:0.1]
forced_id = 0; //[0:6:0.1]
center = 1; //[0:1:1]
path_length = 0; //[0:200:1]
eps = 0.2; //[0.01:1:0.01]

// Smoothness (avoid polygonal/hex look)
$fn = 96;

function tube_h() = (path_length > 0) ? path_length : length;
function tube_id() = (forced_id > 0) ? forced_id : inner_diameter;

module tubing(h, od, id) {
  // Ensure valid, printable tube wall and non-degenerate inner void
  wall_min = max(eps, 0.01);
  od2 = max(od, 2*wall_min + wall_min);
  id2 = min(max(id, wall_min), od2 - 2*wall_min);

  color([0.85, 0.85, 0.8])  // off-white PTFE
  difference() {
    cylinder(h=h, d=od2, center=true);
    cylinder(h=h + 2*wall_min, d=id2, center=true);
  }
}

module assembly() {
  h = tube_h();
  od = outer_diameter;
  id = tube_id();

  if (center == 1) {
    tubing(h, od, id);
  } else {
    translate([0, 0, h/2]) tubing(h, od, id); // base at Z=0
  }
}

assembly();