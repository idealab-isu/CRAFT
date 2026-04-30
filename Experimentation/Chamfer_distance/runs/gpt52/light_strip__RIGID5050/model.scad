$fn = 64;

module aluminum_channel(length=500, outer_w=14.4, outer_d=7, aperture_w=10.4, wall=0.9) {
    inner_w = outer_w - 2*wall;
    inner_d = outer_d - wall; // open top channel
    lip = (inner_w - aperture_w)/2;
    union() {
        // Outer block minus inner cavity and top opening to form U-channel with lips
        difference() {
            translate([-length/2, -outer_w/2, 0])
                cube([length, outer_w, outer_d], center=false);

            // Inner cavity (leaves bottom thickness = wall, side thickness = wall)
            translate([-length/2 + 0.01, -inner_w/2, wall])
                cube([length - 0.02, inner_w, inner_d], center=false);

            // Top opening (aperture), leaves lips on both sides with thickness = wall
            translate([-length/2 + 0.01, -aperture_w/2, wall])
                cube([length - 0.02, aperture_w, outer_d], center=false);
        }
    }
}

module pcb_strip(length=500, pcb_w=10.0, pcb_t=1.2, outer_d=7, wall=0.9) {
    // Place PCB on the bottom inside the channel
    translate([-length/2, -pcb_w/2, wall])
        cube([length, pcb_w, pcb_t], center=false);
}

module led_package(d=2.8, h=1.1) {
    cylinder(d=d, h=h, center=false);
}

module led_strip(length=500, n_leds=36, pcb_w=10.0, pcb_t=1.2, outer_d=7, wall=0.9) {
    // 12 segments of 3 LEDs across 500mm length
    segments = 12;
    pitch = length/segments;
    z0 = wall + pcb_t; // on top of PCB
    union() {
        for (s = [0:segments-1]) {
            x_center = -length/2 + (s + 0.5)*pitch;
            for (k = [-1, 0, 1]) {
                translate([x_center + k*(pitch*0.18), 0, z0])
                    led_package();
            }
        }
    }
}

module diffuser(length=500, aperture_w=10.4, outer_d=7, wall=0.9, diffuser_t=1.0, inset=0.2) {
    // Simple translucent insert spanning aperture, slightly inset below top
    z = outer_d - diffuser_t - inset;
    translate([-length/2, -aperture_w/2, z])
        cube([length, aperture_w, diffuser_t], center=false);
}

module rigid_led_channel_assembly() {
    length = 500;
    outer_w = 14.4;
    outer_d = 7;
    aperture_w = 10.4;
    wall = 0.9;
    pcb_t = 1.2;

    // Choose PCB width to fit within aperture
    pcb_w = min(10.0, aperture_w - 0.4);

    union() {
        // Aluminum channel
        aluminum_channel(length=length, outer_w=outer_w, outer_d=outer_d, aperture_w=aperture_w, wall=wall);

        // PCB
        color([0,0.6,0])
            pcb_strip(length=length, pcb_w=pcb_w, pcb_t=pcb_t, outer_d=outer_d, wall=wall);

        // LEDs
        color([1,0.9,0.3])
            led_strip(length=length, n_leds=36, pcb_w=pcb_w, pcb_t=pcb_t, outer_d=outer_d, wall=wall);

        // Diffuser cover
        color([1,1,1,0.35])
            diffuser(length=length, aperture_w=aperture_w, outer_d=outer_d, wall=wall, diffuser_t=1.0, inset=0.15);
    }
}

rigid_led_channel_assembly();