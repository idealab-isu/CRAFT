$fn=64;

// Thermistor: EPCOS/TDK B57861S104F40 (NTC 100k, 1%)
// Approximate 3D representation (radial epoxy bead with two leads)

module thermistor_epcos_B57861S104F40(
    bead_d=3.2,          // epoxy bead diameter (approx)
    bead_t=2.2,          // epoxy bead thickness along lead axis (approx)
    lead_d=0.5,          // lead wire diameter (approx)
    lead_pitch=2.5,      // center-to-center lead spacing (approx)
    lead_len=28,         // straight lead length below bead (approx)
    standoff=1.0,        // distance from bead bottom to PCB plane (approx)
    fillet_r=0.35        // small transition radius at bead exit (approx)
){
    // Coordinate system:
    // Z up. PCB plane at Z=0. Leads extend downward to Z=0.
    // Bead centered above PCB.

    bead_center_z = standoff + bead_t/2;

    // Leads
    for (sx = [-1, 1]) {
        x = sx * lead_pitch/2;

        // Lead segment from bead exit down to PCB
        translate([x, 0, 0])
            cylinder(d=lead_d, h=standoff + bead_t, center=false);

        // Lead segment below bead down to PCB (extra length)
        // Ensure total visible lead length is lead_len from bead bottom to end
        extra = max(0, lead_len - standoff);
        translate([x, 0, -extra])
            cylinder(d=lead_d, h=extra, center=false);

        // Small fillet at bead exit
        translate([x, 0, standoff + bead_t - fillet_r])
            cylinder(d1=lead_d, d2=lead_d + 2*fillet_r, h=fillet_r, center=false);
    }

    // Bead body (epoxy disc-like bead)
    // Slightly rounded edges via minkowski with a small sphere
    translate([0, 0, bead_center_z])
    minkowski() {
        cylinder(d=bead_d - 0.6, h=bead_t - 0.6, center=true);
        sphere(d=0.6);
    }

    // Optional subtle flat on one side (common on some beads) - very slight
    // Comment out if undesired
    difference() {
        // no-op wrapper to keep model renderable if user edits
        union() {}
        // (intentionally empty)
    }
}

// Render
thermistor_epcos_B57861S104F40();