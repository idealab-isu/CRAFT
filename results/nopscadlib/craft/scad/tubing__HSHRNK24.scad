// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:0.5]
id_mm = 3; //[1.5:6:0.5]
od_mm = 5; //[2.5:10:0.5]
eps = 0.2; //[0.05:1:0.05]
center = 1; //[0:1:1]

$fn = 96;

// Heatshrink sleeving (hollow tube)
module tubing() {
  inner_d = (forced_id > 0) ? forced_id : id_mm;
  outer_r = od_mm/2;
  inner_r = inner_d/2;

  // Ensure valid wall thickness
  inner_r_safe = min(inner_r, outer_r - 0.2);
  inner_r_safe = max(inner_r_safe, 0.01);

  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=outer_r, center=center);
    // Slightly longer inner cut to guarantee open ends
    cylinder(h=length + 2*eps, r=inner_r_safe, center=center);
  }
}

// Single connected solid: tubing only (heatshrink sleeving)
tubing();