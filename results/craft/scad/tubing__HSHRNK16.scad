// Heatshrink sleeving tubing (single connected solid)

// Parameters
type = 1; //[1:5:1]
length = 15; //[8:40:1]
forced_id = 0; //[0:10:1]
center = 1; //[0:1:1]
path_enabled = 0; //[0:1:1]
nominal_id = 2.0; //[1.0:6.0:0.1]
nominal_od = 3.2; //[1.6:12.0:0.1]
eps_overlap = 0.8; //[0.5:2.0:0.1]
tube_id = 2.0; //[1.0:6.0:0.1]
tube_od = 3.2; //[1.6:12.0:0.1]

// Derived / safety
$fn = 96;
eps = 0.02;

// Use forced_id if provided (>0), else tube_id
id = (forced_id > 0) ? forced_id : tube_id;
od = tube_od;

// Ensure valid wall thickness
id_safe = min(id, od - 2*eps);
od_safe = max(od, id_safe + 2*eps);

// Heatshrink tube: hollow cylinder segment (one connected solid)
module heatshrink_tube(len, id_d, od_d, centered=true) {
  difference() {
    cylinder(d=od_d, h=len, center=centered);
    // Inner void slightly longer to guarantee clean subtraction
    cylinder(d=id_d, h=len + 2*eps_overlap, center=centered);
  }
}

// Placement: if center==1 -> centered at origin; if center==0 -> base at z=0
zpos = (center == 1) ? 0 : length/2;

translate([0, 0, zpos])
  heatshrink_tube(length, id_safe, od_safe, centered=true);