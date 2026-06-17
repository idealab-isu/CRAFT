$fn = 96;

// 8.0mm through-hole LED, 9.2mm body height (approximate standard geometry)

d_body = 8.0;
h_body = 9.2;

d_lens = d_body;
h_lens = 2.2;                 // domed top height
h_cyl = h_body - h_lens;      // cylindrical portion

d_flange = 9.0;               // small rim at base
h_flange = 1.0;

d_lead = 0.6;
lead_pitch = 2.54;
lead_len = 25.0;
lead_exposed_below = 18.0;    // portion below base

module led_body() {
    // Body sits on z=0, leads extend downward (negative z)
    union() {
        // Base flange
        color([0.85,0.85,0.85,1.0])
            cylinder(d=d_flange, h=h_flange);

        // Cylindrical body
        color([0.95,0.1,0.1,0.35])
            translate([0,0,h_flange])
                cylinder(d=d_body, h=h_cyl - h_flange);

        // Domed lens top (spherical cap)
        color([0.95,0.1,0.1,0.35])
            translate([0,0,h_cyl])
                intersection() {
                    sphere(d=d_lens);
                    translate([-d_lens, -d_lens, 0])
                        cube([2*d_lens, 2*d_lens, h_lens]);
                }

        // Internal "cup" approximation
        color([0.9,0.9,0.9,1.0])
            translate([0,0,h_flange+0.6])
                cylinder(d=4.2, h=3.2);

        // Leads
        color([0.75,0.75,0.75,1.0]) {
            // Anode (longer)
            translate([-lead_pitch/2, 0, -lead_exposed_below])
                cylinder(d=d_lead, h=lead_len);

            // Cathode (shorter)
            translate([ lead_pitch/2, 0, -lead_exposed_below])
                cylinder(d=d_lead, h=lead_len - 2.0);
        }
    }
}

led_body();