$fn = 64;

// Motor driver module overall: 35.0mm x 32.0mm, 1.6mm thick
// Keep everything as ONE connected solid (no holes/cutouts).

module motor_driver_module() {
    // PCB
    pcb_x = 35.0;
    pcb_y = 32.0;
    pcb_z = 1.6;

    // Small overlap to guarantee watertight unions
    ov = 0.25;

    // Top components (simple, connected)
    chip_x = 12.0;
    chip_y = 12.0;
    chip_z = 2.2;

    cap_r = 3.0;
    cap_z = 6.0;

    term_x = 12.0;
    term_y = 8.0;
    term_z = 9.0;

    header_x = 28.0;
    header_y = 4.0;
    header_z = 5.5;

    // Bottom feature (to match bottom-view "center tab")
    tab_x = 14.0;
    tab_y = 10.0;
    tab_z = 1.2;

    // Side "ears"/flanges (to match top/bottom views showing wider ends)
    ear_x = 6.0;
    ear_y = pcb_y;
    ear_z = 0.9;

    pcb_top = pcb_z;

    union() {
        // PCB base
        cube([pcb_x, pcb_y, pcb_z], center=false);

        // Side ears (extend slightly beyond PCB in X, but overlap into PCB)
        translate([-ear_x + ov, 0, 0])
            cube([ear_x, ear_y, ear_z], center=false);

        translate([pcb_x - ov, 0, 0])
            cube([ear_x, ear_y, ear_z], center=false);

        // Bottom center tab (extends below PCB, overlaps into PCB)
        translate([(pcb_x - tab_x)/2, (pcb_y - tab_y)/2, -tab_z + ov])
            cube([tab_x, tab_y, tab_z], center=false);

        // Main driver IC (centered on board)
        translate([(pcb_x - chip_x)/2, (pcb_y - chip_y)/2, pcb_top - ov])
            cube([chip_x, chip_y, chip_z], center=false);

        // Electrolytic capacitor near a corner (connected to PCB)
        translate([cap_r + 2.0, pcb_y - (cap_r + 2.0), pcb_top - ov])
            cylinder(r=cap_r, h=cap_z, center=false);

        // Screw terminal block along one short edge (y=0)
        translate([(pcb_x - term_x)/2, 0, pcb_top - ov])
            cube([term_x, term_y, term_z], center=false);

        // Pin header along opposite short edge (y=pcb_y - header_y)
        translate([(pcb_x - header_x)/2, pcb_y - header_y, pcb_top - ov])
            cube([header_x, header_y, header_z], center=false);
    }
}

motor_driver_module();