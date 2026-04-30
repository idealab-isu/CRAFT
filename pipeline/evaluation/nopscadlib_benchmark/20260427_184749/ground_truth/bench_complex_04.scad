// ESP32 DevKit Enclosure with OLED Display
// ESP32: ~55mm x 28mm, OLED: 27mm x 27mm
esp_length = 55;
esp_width = 28;
oled_size = 27;
oled_view = 22;  // Visible area
box_height = 20;
wall = 2;

// Main enclosure
difference() {
    // Outer box
    cube([esp_length + 20, esp_width + oled_size + 10, box_height], center=true);

    // Inner cavity
    translate([0, 0, wall])
        cube([esp_length + 16, esp_width + oled_size + 6, box_height], center=true);

    // USB port cutout
    translate([-(esp_length/2 + 10), -((esp_width + oled_size)/2 - esp_width/2), 0])
        cube([wall*3, 10, 5], center=true);

    // OLED display window
    translate([0, (esp_width + oled_size)/2 - oled_size/2 - 2, box_height/2 - wall/2])
        cube([oled_view, oled_view, wall*2], center=true);

    // Ventilation slots
    for (i = [0:3]) {
        translate([i * 10 - 15, -((esp_width + oled_size)/2), 0])
            cube([6, wall*2, 8], center=true);
    }

    // Button holes (2x)
    for (x = [-1, 1]) {
        translate([x * 20, (esp_width + oled_size)/2, 0])
            rotate([90, 0, 0])
                cylinder(d=6, h=wall*3, center=true, $fn=32);
    }
}

// ESP32 mounting rails
for (y = [-1, 1]) {
    translate([0, y * (esp_width/2 - 5) - (oled_size/2 - 5), -box_height/2 + wall + 2])
        cube([esp_length - 5, 2, 4], center=true);
}
