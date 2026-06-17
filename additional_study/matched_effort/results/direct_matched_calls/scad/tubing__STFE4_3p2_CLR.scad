$fn = 128;

// PTFE heatshrink sleeving (tubing)
// Units: mm

// Parameters
length = 60;          // overall length
id = 4.0;             // inner diameter
wall = 0.6;           // wall thickness
od = id + 2*wall;     // outer diameter

// Subtle surface ribbing to suggest sleeving texture
rib_pitch = 3.0;      // distance between ribs along length
rib_height = 0.12;    // radial height of ribs
rib_width = 0.9;      // rib width along length

module tube(L, ID, OD) {
    difference() {
        cylinder(h=L, d=OD, center=false);
        translate([0,0,-0.2]) cylinder(h=L+0.4, d=ID, center=false);
    }
}

module ribbed_sleeve(L, ID, OD) {
    union() {
        // Base tube
        tube(L, ID, OD);

        // Ribs on outer surface
        for (z = [0 : rib_pitch : L - rib_width]) {
            translate([0,0,z])
                difference() {
                    cylinder(h=rib_width, d=OD + 2*rib_height, center=false);
                    translate([0,0,-0.2]) cylinder(h=rib_width+0.4, d=OD, center=false);
                }
        }

        // Slightly chamfered ends (visual cue)
        for (z0 = [0, L-1.2]) {
            translate([0,0,z0])
                difference() {
                    cylinder(h=1.2, d1=OD + 0.6, d2=OD, center=false);
                    translate([0,0,-0.2]) cylinder(h=1.6, d=ID, center=false);
                }
        }
    }
}

ribbed_sleeve(length, id, od);