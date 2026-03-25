$fn=64;

module pcb(size_x=21.0, size_y=18.0, thickness=1.2) {
    cube([size_x, size_y, thickness], center=true);
}

pcb();