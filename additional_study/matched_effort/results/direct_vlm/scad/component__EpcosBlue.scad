$fn = 64;

// Thermistor: EPCOS/TDK B57861S104F40 (NTC 100k 1%)
// One connected solid: small epoxy bead/disc with two radial leads exiting one side,
// then bent downward (typical radial-leaded bead thermistor form).

module thermistor_epcos_B57861S104F40(
    bead_d=2.2,            // bead diameter (mm)
    bead_l=3.0,            // bead length along X (mm)
    lead_d=0.45,           // lead diameter (mm)
    lead_pitch=2.5,        // lead center-to-center spacing (mm)
    lead_out=2.0,          // straight length out of bead before bend (mm)
    lead_drop=25,          // vertical drop after bend (mm)
    embed=0.45,            // how far leads embed into bead for guaranteed union (mm)
    fillet=0.25,           // bead end rounding control (mm)
    bend_r=0.6,            // bend radius (mm)
    overlap=0.25           // overlap to ensure manifold union
){
    // Robust cylinder between two points (handles any direction)
    module segment(a, b, d){
        v = [b[0]-a[0], b[1]-a[1], b[2]-a[2]];
        len = norm(v);
        if (len > 1e-9){
            translate(a)
                rotate(a=acos(v[2]/len), v=[-v[1], v[0], 0])
                    cylinder(d=d, h=len, center=false);
        }
    }

    // Rounded capsule bead, centered at origin, axis along X
    module bead(){
        hull(){
            translate([-(bead_l/2 - fillet), 0, 0]) sphere(d=bead_d);
            translate([ (bead_l/2 - fillet), 0, 0]) sphere(d=bead_d);
        }
    }

    // One lead: exits from +X face, then bends down
    module lead(side=1){
        y = side * (lead_pitch/2);

        // +X face of bead
        x_face = bead_l/2;

        // Start inside bead to guarantee connection
        p0 = [x_face - embed, y, 0];

        // Straight section out of bead
        p1 = [x_face + lead_out, y, 0];

        // Straight segment from bead into free space (overlap into bead)
        segment(p0, [p1[0] + overlap, p1[1], p1[2]], lead_d);

        // Bend arc center (quarter turn from +X to -Z)
        c = [x_face + lead_out, y, -bend_r];

        // Arc from angle 0 to -90 degrees
        steps = 10;
        for (i = [0:steps-1]){
            a0 = -i*(90/steps);
            a1 = -(i+1)*(90/steps);

            q0 = [c[0] + bend_r*cos(a0), y, c[2] + bend_r*sin(a0)];
            q1 = [c[0] + bend_r*cos(a1), y, c[2] + bend_r*sin(a1)];

            // Ensure first arc segment overlaps the straight section
            if (i == 0)
                segment([q0[0] - overlap, q0[1], q0[2]], q1, lead_d);
            else
                segment(q0, q1, lead_d);
        }

        // End of arc at -90 deg
        p2 = [c[0], y, c[2] - bend_r];

        // Vertical drop (overlap into arc)
        p3 = [p2[0], y, p2[2] - lead_drop];
        segment([p2[0], p2[1], p2[2] + overlap], p3, lead_d);
    }

    union(){
        bead();
        lead(+1);
        lead(-1);
    }
}

// Render
thermistor_epcos_B57861S104F40();