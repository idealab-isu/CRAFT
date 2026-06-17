$fn = 128;

module ht_pipe_body(diameter, length) {
    cylinder(d=diameter, h=length, center=true);
}

module end_fitting_geometry(diameter, h=20, flare=10) {
    cylinder(d=diameter + flare, h=h, center=true);
}

module ht_pipe(diameter, length) {
    fitting_h = 20;
    flare = 10;
    overlap = 1; // ensures positive overlap with body

    // Ensure the main body length is the requested 1500mm (overall length will be longer due to fittings)
    union() {
        ht_pipe_body(diameter, length);

        translate([0, 0, length/2 + fitting_h/2 - overlap])
            end_fitting_geometry(diameter, h=fitting_h, flare=flare);

        translate([0, 0, -length/2 - fitting_h/2 + overlap])
            end_fitting_geometry(diameter, h=fitting_h, flare=flare);
    }
}

// Rotate so the 1500mm length lies along X for visible front/back/left/right orthographic views
rotate([0, 90, 0])
    ht_pipe(75, 1500);