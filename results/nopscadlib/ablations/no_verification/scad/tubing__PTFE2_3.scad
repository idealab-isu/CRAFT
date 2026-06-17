// PTFE Tubing (round tube with circular bore)

// Parameters
length = 15;          //[8:30:1]
forced_id = 0;        //[0:10:0.1]
center = 1;           //[0:1:1]
nominal_od = 4;       //[2:8:0.1]
nominal_id = 2;       //[1:6:0.1]
overlap = 1;          //[0.5:2:0.1]

// Smoothness
$fn = 96;

// Effective inner and outer diameters
id = (forced_id > 0) ? forced_id : nominal_id;
od = nominal_od + id - nominal_id;

// Safety clamps to ensure valid tube
id_eff = max(0.01, id);
od_eff = max(id_eff + 0.2, od);   // ensure wall thickness > 0

module tubing(h, od_d, id_d, centered=true) {
  color([0.85, 0.85, 0.8])  // Off-white PTFE
  difference() {
    cylinder(h=h, d=od_d, center=centered);
    // Ensure the bore fully cuts through regardless of centering
    cylinder(h=h + 2*overlap, d=id_d, center=centered);
  }
}

module assembly() {
  // If not centered, place tube on Z=0..length (not half-floating)
  zoff = (center == 1) ? 0 : length/2;
  translate([0, 0, zoff])
    tubing(length, od_eff, id_eff, centered=true);
}

assembly();