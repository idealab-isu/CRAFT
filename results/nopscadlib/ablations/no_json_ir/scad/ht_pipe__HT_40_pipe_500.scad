// Connectivity-fixed HT pipe model (all parts unioned + slight overlaps)

module ht_pipe_body(diameter, length) {
    cylinder(d=diameter, h=length, center=true);
}

module pipe_end_fitting_geometry(diameter, h=20) {
    // Ring/cap-like sleeve (hollow)
    difference() {
        cylinder(d=diameter + 10, h=h, center=true);
        translate([0, 0, -1])
            cylinder(d=diameter, h=h + 2, center=true);
    }
}

module ht_pipe(type, length) {
    if (type == "HT 40") {
        diameter = 40;

        fitting_h = 20;
        overlap   = 2;   // 1–2mm overlap to guarantee connection

        union() {
            // Main pipe centered at origin
            ht_pipe_body(diameter, length);

            // Attach fittings to both ends with overlap into the pipe
            // Pipe spans z = [-length/2, +length/2]
            // Each fitting spans z = [center - fitting_h/2, center + fitting_h/2]
            // Place so inner face penetrates pipe by 'overlap'
            translate([0, 0,  (length/2) + (fitting_h/2) - overlap])
                pipe_end_fitting_geometry(diameter, fitting_h);

            translate([0, 0, -(length/2) - (fitting_h/2) + overlap])
                pipe_end_fitting_geometry(diameter, fitting_h);
        }
    }
}

ht_pipe("HT 40", 500);