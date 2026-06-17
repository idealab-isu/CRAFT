$fn=96;

// Thermistor: EPCOS/TDK B57560G104F (100k, 1%)
// Approximate geometric model (radial epoxy bead NTC with two leads)

module thermistor_epcos_B57560G104F(
    bead_d=3.2,          // epoxy bead diameter (approx)
    bead_h=2.6,          // epoxy bead thickness along lead axis (approx)
    lead_d=0.5,          // lead wire diameter (approx)
    lead_pitch=2.54,     // lead spacing (approx)
    lead_len=28,         // straight lead length below bead (approx)
    standoff=1.0,        // distance from bead bottom to PCB plane (approx)
    fillet_r=0.35        // small transition at bead exit (approx)
){
    // Coordinate system:
    // Z=0 is PCB plane. Leads extend downward to Z=0 and below if desired.
    // Bead centered above PCB with its bottom at Z=standoff.
    bead_z0 = standoff;
    bead_z1 = bead_z0 + bead_h;

    module lead(x){
        color([0.75,0.75,0.78])
        translate([x,0,0])
        union(){
            // main lead
            translate([0,0,0])
                cylinder(d=lead_d, h=bead_z0 + lead_len);

            // small flare/fillet near bead entry
            translate([0,0,bead_z0 - 0.01])
                cylinder(d1=lead_d, d2=lead_d + 2*fillet_r, h=fillet_r + 0.02);
        }
    }

    module bead(){
        // Epoxy bead with slight rounding
        color([0.08,0.08,0.09])
        translate([0,0,bead_z0])
        hull(){
            translate([0,0,0.25])
                sphere(d=bead_d);
            translate([0,0,bead_h-0.25])
                sphere(d=bead_d);
        }
    }

    // Leads positions
    x1 = -lead_pitch/2;
    x2 =  lead_pitch/2;

    // Build
    union(){
        // Leads
        lead(x1);
        lead(x2);

        // Bead body
        bead();

        // Internal lead embed (short segments inside bead for realism)
        color([0.65,0.65,0.68])
        for (x=[x1,x2]){
            translate([x,0,bead_z0])
                cylinder(d=lead_d*0.95, h=bead_h);
        }
    }
}

// Render the component
thermistor_epcos_B57560G104F();