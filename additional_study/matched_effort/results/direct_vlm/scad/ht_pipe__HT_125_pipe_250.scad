$fn = 128;

// HT pipe: DN 125, length 250 mm (approximate typical dimensions)
dn = 125;                 // nominal diameter (mm)
L  = 250;                 // length (mm)

// Typical HT (PP) pipe wall thickness for DN125 is ~3.2 mm (approx.)
t = 3.2;                  // wall thickness (mm)

OD = dn;                  // assume outer diameter equals nominal for this simplified model
ID = OD - 2*t;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.5])
            cylinder(h = len + 1.0, d = id);
    }
}

ht_pipe(OD, ID, L);