// Raspberry Pi 4 Case with GPIO Slot, Ventilation, and Port Cutouts

$fn=64;

// Main enclosure dimensions
case_length = 90;
case_width = 60;
case_height = 30;
wall_thickness = 2;

// GPIO slot dimensions
gpio_slot_length = 50;
gpio_slot_width = 5;
gpio_slot_offset = 10;

// Ventilation hole dimensions
vent_diameter = 3;
vent_spacing = 10;

// Port cutout dimensions
usb_cutout_length = 15;
usb_cutout_width = 10;
usb_cutout_height = 10;
hdmi_cutout_length = 15;
hdmi_cutout_width = 5;
hdmi_cutout_height = 10;

// Create the main case
module main_case() {
    difference() {
        // Outer shell
        cube([case_length, case_width, case_height], center=true);
        
        // Inner cavity
        translate([0, 0, wall_thickness])
            cube([case_length - 2*wall_thickness, case_width - 2*wall_thickness, case_height - wall_thickness], center=true);
    }
}

// Create GPIO slot
module gpio_slot() {
    translate([0, case_width/2 - gpio_slot_width/2 - gpio_slot_offset, case_height/2 - wall_thickness])
        cube([gpio_slot_length, gpio_slot_width, wall_thickness], center=true);
}

// Create ventilation holes
module ventilation() {
    for (x = [-case_length/2 + vent_spacing/2 : vent_spacing : case_length/2 - vent_spacing/2])
        for (y = [-case_width/2 + vent_spacing/2 : vent_spacing : case_width/2 - vent_spacing/2])
            translate([x, y, case_height/2 - wall_thickness/2])
                cylinder(h=wall_thickness, d=vent_diameter, center=true);
}

// Create port cutouts
module port_cutouts() {
    translate([case_length/2 - wall_thickness, -case_width/4, case_height/2 - usb_cutout_height/2])
        cube([wall_thickness, usb_cutout_width, usb_cutout_height], center=true);
    
    translate([case_length/2 - wall_thickness, case_width/4, case_height/2 - hdmi_cutout_height/2])
        cube([wall_thickness, hdmi_cutout_width, hdmi_cutout_height], center=true);
}

// Assemble the case
union() {
    main_case();
    gpio_slot();
    ventilation();
    port_cutouts();
}