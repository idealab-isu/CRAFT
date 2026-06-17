// Heatshrink sleeving (simple hollow tube segment) - single connected solid

// Parameters
length = 15;            //[8:30:1]  Tube length
center = 1;             //[0:1:1]   1=centered at origin, 0=sits on Z=0
forced_id = 0;          //[0:10:0.1] If >0, overrides nominal_id
nominal_id = 3;         //[1.5:6:0.1]
nominal_od = 5;         //[2.5:10:0.1]
id = 3;                 //[1.5:10:0.1] Inner diameter (used if forced_id==0)
od = 5;                 //[2.5:20:0.1] Outer diameter
eps_overlap = 1;        //[0.5:2:0.1] Extra cut length to ensure clean hollow

$fn = 96;

// Derived dimensions (ensure valid tube wall)
inner_d = (forced_id > 0) ? forced_id : id;
outer_d = od;

// Clamp to avoid empty/invalid geometry
min_wall = 0.4;
inner_d_clamped = min(inner_d, outer_d - 2*min_wall);
inner_d_final = max(0.01, inner_d_clamped);
outer_d_final = max(inner_d_final + 2*min_wall, outer_d);

z0 = (center == 1) ? 0 : (length/2);

module heatshrink_sleeving() {
  color([0.85, 0.85, 0.8])
  translate([0, 0, z0])
    difference() {
      cylinder(d=outer_d_final, h=length, center=true);
      cylinder(d=inner_d_final, h=length + 2*eps_overlap, center=true);
    }
}

heatshrink_sleeving();