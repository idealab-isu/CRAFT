$fn = 64;

// Exact target dimensions (mm)
pcb_length    = 40.0;
pcb_width     = 16.0;
pcb_thickness = 1.6;

// Small epsilon to avoid coplanar artifacts while keeping one connected solid
eps = 0.02;

// PCB as ONE connected solid with slightly rounded corners (still exact overall size)
module pcb_plate() {
    color([0.0, 0.4, 0.2])
    linear_extrude(height = pcb_thickness, center = true, convexity = 10)
        offset(r = 0.6)
            square([pcb_length - 2*0.6, pcb_width - 2*0.6], center = true);
}

// Final output
pcb_plate();