// Heatshrink sleeving / tubing (single connected solid)

// Parameters (kept from original where relevant)
length = 15; //[8:30:1]
center = true; //[0:1:1]

id = 3; //[1.5:6:0.5]
od = 5; //[2.5:10:0.5]
wall_min = 0.6; //[0.3:1.5:0.1]
bore_clearance = 0.2; //[0:0.6:0.1]
overlap = 1; //[0.5:2:0.1]

// Smoothness
$fn = 96;

// Derived dimensions
outer_r = max(od/2, id/2 + wall_min);
inner_r = id/2 + bore_clearance;

// One connected solid: a hollow tube (heatshrink)
module heatshrink_tube() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=outer_r, center=center);
    cylinder(h=length + 2*overlap, r=inner_r, center=center);
  }
}

heatshrink_tube();