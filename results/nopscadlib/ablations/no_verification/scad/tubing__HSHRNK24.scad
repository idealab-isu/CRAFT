// Heatshrink sleeving / tubing (single connected solid)

// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:0.1]
center = true; //[0:1:1]
nominal_id = 2.0; //[1.0:6.0:0.1]
nominal_od = 3.2; //[1.6:6.4:0.1]
wall_min = 0.4; //[0.2:1.2:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
bore_eps = 0.2; //[0.05:0.5:0.05]

// Resistor params kept but not used for this part
res_body_length = 6; //[3:15:1]
res_body_diameter = 2.2; //[1.2:5:0.1]
lead_diameter = 0.6; //[0.3:1.2:0.05]
lead_length_each_side = 12; //[6:30:1]
bare_lead = 5; //[2:12:1]
sleeving_length = 7; //[3:20:1]

$fn = 96;

function id_eff() = (forced_id > 0 ? forced_id : nominal_id);
function od_eff() = max(nominal_od + (id_eff() - nominal_id), id_eff() + 2*wall_min);

module heatshrink_sleeve(len=length, id=id_eff(), od=od_eff(), ctr=center) {
  // Ensure a visible wall even if parameters are inconsistent
  wall = max(wall_min, (od - id)/2);
  od2 = id + 2*wall;

  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=len, r=od2/2, center=ctr);
    cylinder(h=len + bore_eps, r=id/2, center=ctr);
  }
}

// Output: one connected solid (the sleeve itself)
heatshrink_sleeve();