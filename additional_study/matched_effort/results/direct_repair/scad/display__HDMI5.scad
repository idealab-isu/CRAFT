$fn=64;

// HDMI display 5"
// Overall: 121 x 76 x 2.85
// PCB offset: [0,0,1.9]
// Aperture: [[-54, -30.225], [54, 34.575, 0.5]]
// Touch screen: [[-58.7, -34], [58.7, 36.25, 1]]
// Thread length: 2
// Clearance for TS ribbon: [[-2.5, -39], [10.5, -33]]

module hdmi_display_5in(
    size = [121, 76, 2.85],
    pcb_offset = [0,0,1.9],
    aperture = [[-54, -30.225], [54, 34.575, 0.5]],
    touch = [[-58.7, -34], [58.7, 36.25, 1]],
    ribbon_clear = [[-2.5, -39], [10.5, -33]],
    thread_len = 2
){
    // Base PCB slab
    color([0.05,0.35,0.12])
    translate([-size[0]/2, -size[1]/2, pcb_offset[2]])
        cube(size, center=false);

    // Touchscreen glass (slightly above PCB)
    touch_min = touch[0];
    touch_max = touch[1];
    touch_th  = touch[1][2];

    color([0.2,0.2,0.2,0.35])
    translate([touch_min[0], touch_min[1], pcb_offset[2] + size[2]])
        cube([touch_max[0]-touch_min[0], touch_max[1]-touch_min[1], touch_th], center=false);

    // Display aperture (visual cutout region on top surface)
    ap_min = aperture[0];
    ap_max = aperture[1];
    ap_th  = aperture[1][2];

    color([0,0,0])
    translate([ap_min[0], ap_min[1], pcb_offset[2] + size[2] + 0.01])
        cube([ap_max[0]-ap_min[0], ap_max[1]-ap_min[1], ap_th], center=false);

    // Ribbon clearance volume (shown as translucent block below PCB edge)
    rc_min = ribbon_clear[0];
    rc_max = ribbon_clear[1];
    color([1,0,0,0.25])
    translate([rc_min[0], rc_min[1], pcb_offset[2] - thread_len])
        cube([rc_max[0]-rc_min[0], rc_max[1]-rc_min[1], thread_len], center=false);
}

hdmi_display_5in();