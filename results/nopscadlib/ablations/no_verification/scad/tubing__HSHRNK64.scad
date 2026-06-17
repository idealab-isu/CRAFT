// Parameters
tubing_type = 1; //[1:3:1]
length = 15; //[8:40:1]
forced_id = 0; //[0:10:0.1]
center = 1; //[0:1:1]
hs_od_type1 = 2.4; //[1.2:4.8:0.1]
hs_id_type1 = 1.2; //[0.6:2.4:0.1]
hs_od_type2 = 4; //[2:8:0.1]
hs_id_type2 = 2; //[1:4:0.1]
hs_od_type3 = 6; //[3:12:0.1]
hs_id_type3 = 3; //[1.5:6:0.1]
resistor_body_length = 6.3; //[3:15:0.1]
resistor_body_diameter = 2.3; //[1:6:0.1]
lead_diameter = 0.6; //[0.3:1.2:0.05]
lead_total_length = 28; //[10:60:1]
bare_lead_each_side = 5; //[0:15:0.5]
overlap = 1; //[0.5:2:0.1]

$fn = 96;

// Helpers
function sel3(t, a, b, c) = (t==1)?a : (t==2)?b : c;

od = sel3(tubing_type, hs_od_type1, hs_od_type2, hs_od_type3);
id_nom = sel3(tubing_type, hs_id_type1, hs_id_type2, hs_id_type3);
id = (forced_id > 0) ? forced_id : id_nom;

// Ensure valid wall thickness and non-degenerate geometry
eps = 0.02;
id_safe = min(id, od - 2*eps);
od_safe = max(od, id_safe + 2*eps);

// Tubing: hollow cylindrical sleeve (single connected solid)
module tubing() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od_safe/2, center=true);
    cylinder(h=length + 2*overlap, r=id_safe/2, center=true);
  }
}

// Output: heatshrink sleeving only
translate([0, 0, (center==1) ? 0 : length/2])
  tubing();