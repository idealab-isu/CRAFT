// Parameters for the ESP32 DevKit enclosure
esp32_length = 58; // Length of the ESP32 DevKit
esp32_width = 25;  // Width of the ESP32 DevKit
esp32_height = 13; // Height of the ESP32 DevKit

// Parameters for the OLED display cutout
oled_length = 27;  // Length of the 0.96 inch OLED
oled_width = 15;   // Width of the 0.96 inch OLED
oled_depth = 2;    // Depth of the OLED cutout

// Wall thickness of the enclosure
wall_thickness = 2;

// Create the main enclosure
module enclosure() {
    difference() {
        // Outer box
        cube([esp32_length + 2 * wall_thickness, esp32_width + 2 * wall_thickness, esp32_height + wall_thickness], center=true);
        
        // Inner cavity for ESP32
        translate([0, 0, -wall_thickness/2])
            cube([esp32_length, esp32_width, esp32_height], center=true);
        
        // Cutout for OLED display
        translate([0, (esp32_width + oled_width) / 2, (esp32_height - oled_depth) / 2])
            cube([oled_length, oled_width, oled_depth], center=true);
    }
}

// Render the enclosure
enclosure();