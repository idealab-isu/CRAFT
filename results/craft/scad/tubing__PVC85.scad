// Parameters
length = 15; //[8:30:1]
inner_diameter = 6; //[3:12:0.5]
outer_diameter = 8; //[4:16:0.5]
center = 1; //[0:1:1]
wall_min = 0.5; //[0.2:2:0.1]
eps = 0.8; //[0.2:2:0.1]

// Smoothness (PVC tubing should look round)
$fa = 3;
$fs = 0.25;

// Derived radii with safety to avoid invalid/blank geometry
outer_r = max(outer_diameter/2, wall_min + 0.01);
inner_r = min(inner_diameter/2, outer_r - wall_min);
inner_r = max(inner_r, 0.01);

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    difference() {
      cylinder(r=outer_r, h=length, center=true);
      cylinder(r=inner_r, h=length + 2*eps, center=true);
    }
  }
}

// Assembly
module assembly() {
  z0 = (center == 1) ? 0 : length/2;
  translate([0, 0, z0]) tubing();
}

assembly();