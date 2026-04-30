// Arduino Nano Holder
// Nano: 45mm x 18mm x ~5mm
nano_length = 45;
nano_width = 18;
nano_height = 7;  // Including components
wall = 2;
usb_width = 8;
usb_height = 4;

difference() {
    // Outer shell
    cube([nano_length + wall*2, nano_width + wall*2, nano_height + wall], center=true);

    // Nano pocket
    translate([0, 0, wall/2])
        cube([nano_length, nano_width, nano_height + 1], center=true);

    // USB port cutout
    translate([-(nano_length/2 + wall/2), 0, 0])
        cube([wall*2, usb_width, usb_height], center=true);

    // Snap-fit slots
    for (y = [-1, 1]) {
        translate([0, y * (nano_width/2 + wall/2), 0])
            cube([nano_length - 10, wall+1, nano_height/2], center=true);
    }
}

// Snap clips
for (y = [-1, 1]) {
    translate([0, y * (nano_width/2 + wall - 0.5), nano_height/4])
        cube([8, 1, 2], center=true);
}
