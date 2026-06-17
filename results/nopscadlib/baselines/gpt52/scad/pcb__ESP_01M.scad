$fn=64;

module pcb(size_x=18.0, size_y=18.0, thickness=0.8) {
    cube([size_x, size_y, thickness], center=true);
}

pcb();