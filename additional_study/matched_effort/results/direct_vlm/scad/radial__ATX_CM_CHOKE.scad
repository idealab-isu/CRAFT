$fn = 256;

radii   = [17.4, 11.4, 9, 0.5];   // outer -> inner
step_h  = 1;                      // height per step
overlap = 0.05;                   // ensures one connected solid

module radial_steps(rs, h=1, ov=0.05) {
    // Stepped "wedding-cake" profile along Z, centered about Z=0
    // Each smaller radius sits on top of the previous, with slight overlap.
    union() {
        for (i = [0 : len(rs)-1]) {
            z0 = -((len(rs)*h) / 2) + i*h;          // base Z of this step (centered stack)
            translate([0, 0, z0 - (i==0 ? 0 : ov)]) // overlap into the step below
                cylinder(r=rs[i], h=h + (i==0 ? 0 : ov), center=false);
        }
    }
}

radial_steps(radii, h=step_h, ov=overlap);