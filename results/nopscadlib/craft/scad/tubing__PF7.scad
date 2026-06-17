// PTFE Tubing (hollow, smooth circular cross-section)

// Parameters
length  = 15;   //[8:30:1]
od      = 4;    //[2:8:0.1]
id      = 2;    //[1:6:0.1]
center  = 1;    //[0:1:1]
overlap = 1;    //[0.5:2:0.1]

// Smoothness (avoid faceted/polygonal look)
$fn = 128;

module tubing() {
  // Ensure valid annulus with a minimum wall thickness
  min_wall = 0.2;
  inner_d  = min(id, od - 2*min_wall);
  inner_r  = max(0.01, inner_d/2);
  outer_r  = od/2;

  // Centering control
  z0 = (center==1) ? 0 : length/2;

  color([0.85, 0.85, 0.8])  // Off-white for PTFE
  difference() {
    translate([0,0,z0])
      cylinder(r=outer_r, h=length, center=(center==1));

    // Inner bore: extend beyond both ends to guarantee a clean through-hole
    translate([0,0,z0])
      cylinder(r=inner_r, h=length + 2*overlap, center=(center==1));
  }
}

tubing();