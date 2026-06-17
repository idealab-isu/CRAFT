$fn = 64;

// Target PCB dimensions (mm)
pcb_length    = 24.8;
pcb_width     = 14.6;
pcb_thickness = 1.0;

// One connected solid: simple rectangular PCB.
// Centered in X/Y, with bottom face on Z=0.
module pcb(len, wid, thk) {
    translate([0, 0, thk/2])
        cube([len, wid, thk], center=true);
}

color([0.0, 0.4, 0.2]) pcb(pcb_length, pcb_width, pcb_thickness);