$fn=64;

// Approximate 3D model of Honeywell 135-104LAC-J01 NTC thermistor (100K, 1%)
// Radial epoxy bead with two leads.
// Dimensions are reasonable approximations for visualization/fit-checking.

module thermistor_135_104LAC_J01(
    bead_d=3.2,          // epoxy bead diameter
    bead_h=2.6,          // epoxy bead thickness along lead axis
    lead_d=0.5,          // lead wire diameter
    lead_pitch=2.54,     // center-to-center spacing of leads at body exit
    lead_len=28,         // straight lead length from body exit downward
    standoff=1.0,        // distance from bead bottom to PCB plane (lead bend start)
    fillet_r=0.35        // small fillet at lead exit
){
    // Coordinate system:
    // Bead centered at origin, leads go in -Z direction.
    // PCB plane would be at z = -(bead_h/2 + standoff + lead_len)

    bead_z0 = -bead_h/2;
    bead_z1 =  bead_h/2;

    module lead(x){
        // Lead exits bead at z = bead_z0 (bottom face), then continues down.
        // Add a small "neck" fillet region for nicer look.
        translate([x,0,bead_z0])
        union(){
            // Fillet/neck
            hull(){
                translate([0,0,0])
                    cylinder(d=lead_d, h=0.01);
                translate([0,0,-fillet_r])
                    cylinder(d=lead_d*1.15, h=0.01);
            }
            // Straight lead
            translate([0,0,-(standoff+lead_len)])
                cylinder(d=lead_d, h=standoff+lead_len);
        }
    }

    // Body (epoxy bead)
    color([0.08,0.08,0.10])
    union(){
        // Slightly rounded bead using hull of two spheres
        hull(){
            translate([0,0,bead_z0+0.35]) sphere(d=bead_d);
            translate([0,0,bead_z1-0.35]) sphere(d=bead_d);
        }

        // Small flattened faces (top/bottom) to resemble molded bead
        intersection(){
            hull(){
                translate([0,0,bead_z0+0.35]) sphere(d=bead_d);
                translate([0,0,bead_z1-0.35]) sphere(d=bead_d);
            }
            translate([0,0,0])
                cube([bead_d*1.2, bead_d*1.2, bead_h], center=true);
        }
    }

    // Leads
    color([0.75,0.75,0.78])
    union(){
        lead(-lead_pitch/2);
        lead( lead_pitch/2);
    }
}

// Render
thermistor_135_104LAC_J01();