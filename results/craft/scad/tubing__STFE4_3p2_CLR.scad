// PTFE heatshrink sleeving (simple hollow cylindrical tube)

// Parameters
length = 15;                 //[8:60:1]
center = 1;                  //[0:1:1]
forced_id = 0;               //[0:10:0.1]
type_id_default = 2;         //[0.5:6:0.1]
type_od_default = 3.2;       //[1:10:0.1]
wall_min = 0.3;              //[0.1:1.5:0.05]
overlap = 1;                 //[0.5:2:0.1]

$fn = 96;

// Derived dimensions
id = (forced_id > 0) ? forced_id : type_id_default;
od = max(type_od_default, id + 2*wall_min);

// Single connected solid: one hollow tube
module ptfe_heatshrink_sleeve() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od/2, center=(center==1));
    cylinder(h=length + 2*overlap, r=id/2, center=(center==1));
  }
}

ptfe_heatshrink_sleeve();