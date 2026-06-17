// Relay module PCB: 50.0mm x 26.0mm x 1.6mm (one connected solid)

length = 50.0;     // mm
width  = 26.0;     // mm
thickness = 1.6;   // mm

module relay_module_pcb() {
    // Centered geometry improves visibility in many render pipelines
    color([0.0, 0.4, 0.2])
        cube([length, width, thickness], center=true);
}

relay_module_pcb();