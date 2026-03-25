$fn=64;

module l_bracket(L=0.2, W=0.1, T=0.01, stepL=0.12, stepW=0.06) {
    difference() {
        translate([-L/2, -W/2, -T/2])
            cube([L, W, T], center=false);

        translate([L/2 - stepL, -W/2, -T/2 - 0.001])
            cube([stepL, stepW, T + 0.002], center=false);
    }
}

l_bracket(L=0.2, W=0.1, T=0.01, stepL=0.12, stepW=0.06);