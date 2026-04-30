$fn = 64;

// Parameters
length = 500;
outer_width = 14.4;
outer_depth = 7;
aperture_width = 10.4;
channel_thickness = 0.9;
pcb_thickness = 1.2;

// Main channel
module aluminium_channel() {
    difference() {
        // Outer channel
        cube([outer_width, length, outer_depth], center = true);
        
        // Inner cutout
        translate([0, 0, channel_thickness])
            cube([outer_width - 2 * channel_thickness, length, outer_depth - channel_thickness], center = true);
        
        // Aperture cutout
        translate([0, 0, outer_depth / 2])
            cube([aperture_width, length, outer_depth], center = true);
    }
}

// PCB
module pcb() {
    translate([0, 0, -outer_depth / 2 + pcb_thickness / 2])
        cube([aperture_width, length, pcb_thickness], center = true);
}

// Assemble the LED light strip
module led_light_strip() {
    union() {
        aluminium_channel();
        pcb();
    }
}

// Render the LED light strip
led_light_strip();