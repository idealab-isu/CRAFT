$fn=64;

module pcb(size_x=24.8, size_y=14.6, thickness=1.0) {
    cube([size_x, size_y, thickness], center=true);
}

pcb();