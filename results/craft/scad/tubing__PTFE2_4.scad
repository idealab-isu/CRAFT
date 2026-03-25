// Parameters
length = 15; //[7.5:30:0.5]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[1:6:0.1]
center = 1; //[0:1:1]
eps_overlap = 0.8; //[0.2:2:0.1]

// Smoothness (avoid faceted prism look)
$fn = 96;

// PTFE tubing (hollow cylinder)
module tubing(len, od, id, centered=true, eps=0.2) {
  // Ensure valid wall thickness
  id2 = min(id, od - 0.01);

  color([0.85, 0.85, 0.8])  // Off-white for PTFE
  difference() {
    cylinder(h=len, d=od, center=centered);
    cylinder(h=len + 2*eps, d=id2, center=centered);
  }
}

// Assembly (single connected solid)
module assembly() {
  tubing(length, outer_diameter, inner_diameter, centered=(center==1), eps=eps_overlap);
}

assembly();