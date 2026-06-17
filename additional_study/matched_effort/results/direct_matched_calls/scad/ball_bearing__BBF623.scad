$fn = 128;

// Flanged ball bearing (approximate geometry)
// Bore: 3.0 mm
// Outer diameter: 10.0 mm
// Width: 4.0 mm
// Flange diameter: 11.5 mm

bore_d = 3.0;
od_d   = 10.0;
w      = 4.0;

flange_d = 11.5;
flange_t = 0.8;          // typical small flange thickness (approx)
flange_z = 0.0;          // flange on one face (bottom)

ring_wall = 1.0;         // radial thickness of inner ring (approx)
inner_od_d = bore_d + 2*ring_wall;

seal_recess = 0.25;      // shallow recess on faces (approx)
seal_band   = 0.6;       // radial band width for recess (approx)

module flanged_bearing() {
    difference() {
        union() {
            // Main outer ring body
            cylinder(d=od_d, h=w);

            // Flange on one side
            translate([0,0,flange_z])
                cylinder(d=flange_d, h=flange_t);
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(d=bore_d, h=w+flange_t+1.0);

        // Inner ring clearance (to suggest separate inner ring)
        // Leaves an inner ring of thickness ring_wall
        translate([0,0,-0.5])
            cylinder(d=inner_od_d, h=w+flange_t+1.0);

        // Face recesses to suggest shields/seals
        // Top face recess
        translate([0,0,w-seal_recess])
            difference() {
                cylinder(d=od_d-0.2, h=seal_recess+0.01);
                cylinder(d=od_d-2*seal_band, h=seal_recess+0.02);
            }

        // Bottom face recess (excluding flange thickness region)
        translate([0,0,0])
            difference() {
                cylinder(d=od_d-0.2, h=seal_recess+0.01);
                cylinder(d=od_d-2*seal_band, h=seal_recess+0.02);
            }
    }

    // Add inner ring as a separate solid (visual only)
    color([0.75,0.75,0.75])
    difference() {
        cylinder(d=inner_od_d, h=w);
        translate([0,0,-0.5])
            cylinder(d=bore_d, h=w+1.0);
    }
}

flanged_bearing();