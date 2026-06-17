$fn=64;

module lead(len=28, dia=0.8) {
    translate([0,0,-len/2])
        cylinder(h=len, d=dia, center=true);
}

module body(len=18, dia=7.5) {
    union() {
        cylinder(h=len, d=dia, center=true);
        translate([0,0,len/2])
            cylinder(h=1.2, d1=dia, d2=dia*0.92, center=false);
        translate([0,0,-len/2-1.2])
            cylinder(h=1.2, d1=dia*0.92, d2=dia, center=false);
    }
}

module band(z=0, w=1.2, d=7.55) {
    translate([0,0,z])
        cylinder(h=w, d=d, center=true);
}

module resistor_6R8_3W() {
    body_len = 18;
    body_dia = 7.5;
    lead_len = 30;
    lead_dia = 0.8;
    total_len = body_len + 2*lead_len;

    union() {
        translate([0,0,0]) body(body_len, body_dia);

        translate([0,0, body_len/2 + lead_len/2])
            lead(lead_len, lead_dia);

        translate([0,0,-body_len/2 - lead_len/2])
            lead(lead_len, lead_dia);

        color([0.95,0.95,0.95])
            translate([0,0,0])
                cylinder(h=body_len-0.6, d=body_dia*0.985, center=true);

        color([0.1,0.1,0.1]) band(z=-4.5, w=1.2, d=body_dia*1.01);
        color([0.1,0.1,0.1]) band(z=-2.2, w=1.2, d=body_dia*1.01);
        color([0.1,0.1,0.1]) band(z= 0.1, w=1.2, d=body_dia*1.01);
        color([0.1,0.1,0.1]) band(z= 2.4, w=1.2, d=body_dia*1.01);
    }
}

rotate([90,0,0]) resistor_6R8_3W();