// Parameters for Arduino Nano dimensions
nano_length = 45; // Length of the Arduino Nano
nano_width = 18;  // Width of the Arduino Nano
nano_height = 5;  // Height of the Arduino Nano
usb_cutout_width = 12; // Width of the USB port cutout
usb_cutout_height = 4; // Height of the USB port cutout
usb_cutout_depth = 2;  // Depth of the USB port cutout
wall_thickness = 2;    // Thickness of the case walls
snap_fit_height = 2;   // Height of the snap fit feature

// Main case
module nano_case() {
    difference() {
        // Outer case
        cube([nano_length + 2 * wall_thickness, nano_width + 2 * wall_thickness, nano_height + wall_thickness], center=true);
        
        // Inner cavity for Arduino Nano
        translate([0, 0, wall_thickness / 2])
            cube([nano_length, nano_width, nano_height], center=true);
        
        // USB port cutout
        translate([nano_length / 2 - usb_cutout_depth, 0, nano_height / 2 - usb_cutout_height / 2])
            cube([usb_cutout_depth, usb_cutout_width, usb_cutout_height], center=true);
    }
}

// Snap fit feature
module snap_fit() {
    translate([0, 0, -nano_height / 2 - snap_fit_height / 2])
        cube([nano_length, wall_thickness, snap_fit_height], center=true);
}

// Assemble the Arduino Nano holder
union() {
    nano_case();
    translate([0, nano_width / 2 + wall_thickness / 2, 0])
        snap_fit();
    translate([0, -(nano_width / 2 + wall_thickness / 2), 0])
        snap_fit();
}