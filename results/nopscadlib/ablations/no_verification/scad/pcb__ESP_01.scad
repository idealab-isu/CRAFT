// PCB: 24.8mm x 14.6mm x 1.0mm
// One connected solid (single slab). Uses non-centered placement to avoid any viewer/camera issues.

pcb_length    = 24.8;
pcb_width     = 14.6;
pcb_thickness = 1.0;

color([0.0, 0.4, 0.2])
    cube([pcb_length, pcb_width, pcb_thickness], center=false);