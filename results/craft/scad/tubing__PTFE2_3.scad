// PTFE Tubing (cylindrical hollow tube)

// Parameters
od = 4;            //[2:8:0.1]  Outer diameter
id = 2;            //[1:6:0.1]  Inner diameter
length = 15;       //[7.5:30:0.5]
center = 1;        //[0:1:1]    1=centered on Z, 0=rests on Z=0
forced_id = 0;     //[0:6:0.1]  Override inner diameter if > 0
eps = 0.2;         //[0.01:1:0.01] Small overlap to ensure clean boolean

$fn = 96; // ensure circular cross-section

module tubing() {
    inner_d = (forced_id > 0) ? forced_id : id;
    inner_d_clamped = min(inner_d, od - 0.01); // prevent invalid/negative wall thickness

    zc = (center == 1) ? 0 : length/2;

    color([0.85, 0.85, 0.8])  // Off-white for PTFE
    translate([0, 0, zc])
    difference() {
        cylinder(d=od, h=length, center=true);
        cylinder(d=inner_d_clamped, h=length + 2*eps, center=true);
    }
}

tubing();