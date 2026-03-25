$fn=64;

module lead_wire(len=30, dia=0.5) {
    cylinder(h=len, d=dia, center=false);
}

module epoxy_bead(d=2.2, t=1.6) {
    scale([1,1,t/d]) sphere(d=d);
}

module thermistor_epcos_B57560G104F() {
    // Approximate dimensions for a small epoxy bead NTC with radial leads
    bead_d = 2.2;
    bead_t = 1.6;
    lead_d = 0.5;
    lead_pitch = 2.54;
    lead_len = 30;

    union() {
        // Bead body centered at origin
        epoxy_bead(d=bead_d, t=bead_t);

        // Leads (downwards in -Z), positioned symmetrically in X
        translate([-lead_pitch/2, 0, -bead_t/2])
            lead_wire(len=lead_len, dia=lead_d);

        translate([ lead_pitch/2, 0, -bead_t/2])
            lead_wire(len=lead_len, dia=lead_d);
    }
}

thermistor_epcos_B57560G104F();