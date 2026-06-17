$fn = 64;

// Thermistor: EPCOS B57861S104F40 (radial NTC bead/disc with 2 leads)
// ONE connected solid (single union). No extra prongs. No floating parts.

// -------- Parameters (mm) --------
body_d = 3.2;                  // epoxy bead/disc diameter
body_t = 2.0;                  // epoxy thickness

body_lead_exit_spacing = 2.0;  // lead spacing at body exit (center-to-center)

lead_d = 0.5;                  // lead wire diameter
lead_len = 25.0;               // lead length below body bottom
lead_pitch = 5.0;              // final lead pitch (center-to-center)

splay_len = 6.0;               // length over which leads splay from exit spacing to pitch
lead_straight_from_body = 6.0; // straight section before splay

overlap = 0.6;                 // overlap to ensure watertight unions

marking_d = 0.8;
marking_h = 0.2;

// -------- Helpers --------
module segment(p0, p1, r) {
    v = [p1[0]-p0[0], p1[1]-p0[1], p1[2]-p0[2]];
    L = norm(v);
    if (L > 0) {
        translate(p0)
            rotate(a = acos(v[2]/L), v = [-v[1], v[0], 0])
                cylinder(r=r, h=L + overlap, center=false);
    }
    translate(p0) sphere(r=r);
}

module lead_polyline(points, r) {
    for (i = [0 : len(points)-2]) segment(points[i], points[i+1], r);
    translate(points[len(points)-1]) sphere(r=r);
}

// Epoxy body: slightly rounded disc
module thermistor_body() {
    hull() {
        translate([0,0,-body_t/2 + 0.25]) cylinder(r=body_d/2, h=0.5, center=true);
        translate([0,0, body_t/2 - 0.25]) cylinder(r=body_d/2, h=0.5, center=true);
    }
}

// Small dot marking on face
module body_marking() {
    translate([body_d*0.22, 0, body_t/2 - marking_h/2 + 0.01])
        cylinder(r=marking_d/2, h=marking_h, center=true);
}

// -------- Complete Model (ONE connected solid) --------
module thermistor_complete_model() {

    // Body centered at z=0; leads go downward (negative Z)
    z_body_bottom = -body_t/2;

    // Start leads slightly inside body to guarantee connection
    z0 = z_body_bottom + overlap;                  // inside body
    z1 = z_body_bottom - lead_straight_from_body;  // straight down
    z2 = z1 - splay_len;                           // end of splay
    z3 = z_body_bottom - lead_len;                 // lead end

    x_exit  = body_lead_exit_spacing/2;
    x_pitch = lead_pitch/2;

    // Smooth-ish splay with a midpoint
    x_mid = x_exit + (x_pitch - x_exit) * 0.5;
    z_mid = (z1 + z2) / 2;

    union() {
        // Body + marking (kept as geometry; no text)
        thermistor_body();
        body_marking();

        // Two leads only
        lead_polyline(
            [
                [ x_exit, 0, z0],
                [ x_exit, 0, z1],
                [ x_mid,  0, z_mid],
                [ x_pitch,0, z2],
                [ x_pitch,0, z3]
            ],
            lead_d/2
        );

        lead_polyline(
            [
                [-x_exit, 0, z0],
                [-x_exit, 0, z1],
                [-x_mid,  0, z_mid],
                [-x_pitch,0, z2],
                [-x_pitch,0, z3]
            ],
            lead_d/2
        );
    }
}

thermistor_complete_model();