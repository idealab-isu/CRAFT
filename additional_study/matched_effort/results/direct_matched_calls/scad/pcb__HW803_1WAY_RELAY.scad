$fn = 64;

length = 50.0;
width  = 26.0;
thick  = 1.6;

module relay_module_pcb(l=length, w=width, t=thick, corner_r=1.5) {
    color([0.05, 0.35, 0.12])
    linear_extrude(height=t)
        offset(r=corner_r)
            square([l - 2*corner_r, w - 2*corner_r], center=true);
}

relay_module_pcb();