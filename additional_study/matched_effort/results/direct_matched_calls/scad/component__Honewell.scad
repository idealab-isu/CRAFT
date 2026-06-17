$fn=64;

// Thermistor: Honeywell 135-104LAC-J01 (approximate visual model)
// Radial epoxy bead NTC with two leads

// ---------- Parameters ----------
lead_d = 0.5;          // lead wire diameter (mm)
lead_pitch = 2.54;     // lead spacing (mm)
lead_len = 28;         // straight lead length below body (mm)
lead_above = 2.0;      // lead length above body (mm)

body_d = 3.2;          // bead diameter (mm)
body_t = 2.2;          // bead thickness (mm)
body_color = [0.08,0.08,0.08];
lead_color = [0.75,0.75,0.78];

// small meniscus where leads enter body
neck_d = 0.9;
neck_h = 0.6;

// ---------- Helpers ----------
module lead_wire(x=0){
    color(lead_color)
    translate([x,0,-lead_len])
        cylinder(d=lead_d, h=lead_len + body_t + lead_above);
}

module bead_body(){
    color(body_color)
    translate([0,0,0])
    hull(){
        translate([0,0,0.15]) cylinder(d=body_d, h=body_t-0.3);
        translate([0,0,body_t/2]) sphere(d=body_d*0.98);
    }
}

module lead_necks(){
    color(body_color)
    for (sx=[-1,1]){
        translate([sx*lead_pitch/2,0,0])
            cylinder(d1=neck_d*1.05, d2=neck_d, h=neck_h);
    }
}

// ---------- Assembly ----------
module thermistor_135_104LAC_J01(){
    // Leads
    lead_wire(-lead_pitch/2);
    lead_wire( lead_pitch/2);

    // Body with lead entry holes (visual)
    difference(){
        union(){
            bead_body();
            lead_necks();
        }
        // lead holes
        for (sx=[-1,1]){
            translate([sx*lead_pitch/2,0,-0.5])
                cylinder(d=lead_d*1.15, h=body_t+2);
        }
    }
}

thermistor_135_104LAC_J01();