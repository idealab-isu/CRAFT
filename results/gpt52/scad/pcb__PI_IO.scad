$fn=64;

module pcb(length=35.56, width=25.4, thickness=1.6) {
    cube([length, width, thickness], center=true);
}

pcb();