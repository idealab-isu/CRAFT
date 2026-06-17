// Rigid light strip (ONE connected solid, non-zero thickness)

// Parameters
strip_length = 200;      // Length of the rigid strip
strip_width  = 10;       // Width
strip_height = 1.5;      // Base thickness

pcb_thickness = 0.6;     // PCB layer thickness (increased for clearer thickness)

led_spacing = 20;        // Spacing between LEDs
led_size = [3, 3, 1.2];  // LED package size (x,y,z) (slightly thicker)

pad_size = [1.5, 1.5, 0.4]; // Solder pad size (x,y,z) (slightly thicker)
marker_diameter = 1;        // Segment marker diameter
marker_height = 0.5;        // Segment marker height (slightly thicker)

// Small overlap to guarantee watertight union
overlap = 0.1;

// Main assembly (single connected solid)
module light_strip() {
    union() {
        rigid_strip_body();
        pcb_carrier();
        led_packages();
        solder_pads();
        segment_markers();
    }
}

// Rigid strip body (base)
module rigid_strip_body() {
    cube([strip_length, strip_width, strip_height], center=false);
}

// PCB carrier (layer on top of base, overlapping into base)
module pcb_carrier() {
    translate([0, 0, strip_height - overlap])
        cube([strip_length, strip_width, pcb_thickness + overlap], center=false);
}

// LED packages (sit on top of PCB, overlap into PCB)
module led_packages() {
    z0 = strip_height + pcb_thickness - overlap;
    for (i = [0 : led_spacing : strip_length - led_spacing]) {
        translate([
            i + led_spacing/2 - led_size[0]/2,
            strip_width/2 - led_size[1]/2,
            z0
        ])
            cube([led_size[0], led_size[1], led_size[2] + overlap], center=false);
    }
}

// Solder pads (on top of LEDs, overlap into LED)
module solder_pads() {
    z0 = strip_height + pcb_thickness + led_size[2] - overlap;
    for (i = [0 : led_spacing : strip_length - led_spacing]) {
        translate([
            i + led_spacing/2 - pad_size[0]/2,
            strip_width/2 - pad_size[1]/2,
            z0
        ])
            cube([pad_size[0], pad_size[1], pad_size[2] + overlap], center=false);
    }
}

// Segment markers (small cylinders on top of pads, overlap into pads)
module segment_markers() {
    z0 = strip_height + pcb_thickness + led_size[2] + pad_size[2] - overlap;
    for (i = [0 : led_spacing : strip_length - led_spacing]) {
        translate([i + led_spacing/2, strip_width/2, z0])
            cylinder(h=marker_height + overlap, d=marker_diameter, center=false, $fn=32);
    }
}

// Render
light_strip();