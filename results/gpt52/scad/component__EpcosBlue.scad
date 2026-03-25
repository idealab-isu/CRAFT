$fn=64;

module lead(len=30, dia=0.5, bend=0, bend_len=6, spacing=2.54, side=1){
    x = side*spacing/2;
    union(){
        translate([x,0,-len/2]) cylinder(h=len, d=dia, center=true);
        if(bend>0){
            translate([x,0,len/2 - bend_len/2])
                rotate([0,side*90,0])
                    cylinder(h=bend_len, d=dia, center=true);
        }
    }
}

module epoxy_bead(d=3.2, t=2.2){
    hull(){
        translate([0,0,-t/2]) sphere(d=d*0.92);
        translate([0,0, t/2]) sphere(d=d);
    }
}

module thermistor_epcos_B57861S104F40(){
    lead_d = 0.5;
    lead_len = 32;
    lead_spacing = 2.54;

    bead_d = 3.2;
    bead_t = 2.2;

    union(){
        epoxy_bead(d=bead_d, t=bead_t);

        lead(len=lead_len, dia=lead_d, spacing=lead_spacing, side=1);
        lead(len=lead_len, dia=lead_d, spacing=lead_spacing, side=-1);

        translate([ lead_spacing/2,0, bead_t/2 - 0.6]) cylinder(h=1.2, d=0.9, center=true);
        translate([-lead_spacing/2,0, bead_t/2 - 0.6]) cylinder(h=1.2, d=0.9, center=true);
    }
}

thermistor_epcos_B57861S104F40();