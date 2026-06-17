// Dimension-calibrated (target: 0.13 x 0.20 x 0.03 mm)
scale([1.020000, 0.976923, 0.833333])
{
// Prismatic L-shaped bracket-like plate with stepped recess (no holes)
// Units: mm

// Overall size (very thin plate-like solid)
L = 0.20;   // X length
W = 0.13;   // Y width
T = 0.03;   // Z thickness (non-zero)

// Stepped recess (open rectangular cutout from one corner)
notch_L = 0.12;  // X size of recess
notch_W = 0.07;  // Y size of recess

// Boolean robustness
eps = 0.001;
z_overshoot = T + 2*eps;

module base_plate() {
  cube([L, W, T], center=true);
}

// Corner recess: removes material from the (-X, +Y) corner
// This yields the L-shaped outline in plan while keeping constant thickness.
module corner_recess() {
  translate([
    -L/2 + notch_L/2,   // anchored to -X edge
     W/2 - notch_W/2,   // anchored to +Y edge
     0
  ])
    cube([notch_L, notch_W, z_overshoot], center=true);
}

difference() {
  base_plate();
  corner_recess();
}
}
