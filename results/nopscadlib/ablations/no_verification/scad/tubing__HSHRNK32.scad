// Heatshrink sleeving (simple hollow round tube) - one connected solid

// Parameters
length = 15; //[8:60:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:20:1]
tubing_type_id = 1; //[1:3:1]
hs_id_type1 = 1.6; //[0.8:3.2:0.1]
hs_od_type1 = 3.2; //[1.6:6.4:0.1]
hs_id_type2 = 3.2; //[1.6:6.4:0.1]
hs_od_type2 = 6.4; //[3.2:12.8:0.1]
hs_id_type3 = 6.4; //[3.2:12.8:0.1]
hs_od_type3 = 12.7; //[6.4:25.4:0.1]
overlap = 1; //[0.5:2:0.1]

// Smoothness (prevents faceted/hex look)
$fn = 96;

// Select dimensions
od = (tubing_type_id == 1) ? hs_od_type1 :
     (tubing_type_id == 2) ? hs_od_type2 : hs_od_type3;

id_nom = (tubing_type_id == 1) ? hs_id_type1 :
         (tubing_type_id == 2) ? hs_id_type2 : hs_id_type3;

id = (forced_id > 0) ? forced_id : id_nom;

// Radii with safety clamps
outer_radius = max(od/2, 0.01);
inner_radius = max(min(id/2, outer_radius - 0.2), 0.01); // ensure wall thickness

// Z placement (centered or sitting on Z=0)
z0 = (center == 1) ? 0 : length/2;

module heatshrink_tube() {
  color([0.85, 0.85, 0.8])
  translate([0, 0, z0])
  difference() {
    cylinder(h=length, r=outer_radius, center=true);
    cylinder(h=length + 2*overlap, r=inner_radius, center=true);
  }
}

// One connected solid: only the tube
heatshrink_tube();