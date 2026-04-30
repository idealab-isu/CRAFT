// Raspberry Pi 4 Case
// Pi 4: 85mm x 56mm x ~17mm
pi_length = 85;
pi_width = 56;
pi_height = 17;
wall = 2;
vent_slots = 5;

// Bottom case
difference() {
    // Outer shell
    cube([pi_length + wall*2, pi_width + wall*2, pi_height/2 + wall], center=true);

    // Pi pocket
    translate([0, 0, wall])
        cube([pi_length, pi_width, pi_height], center=true);

    // USB-C power cutout (rear)
    translate([pi_length/2, -pi_width/4, 0])
        cube([wall*3, 9, 4], center=true);

    // Micro HDMI cutouts (2x)
    for (y = [0, 14]) {
        translate([pi_length/2, y - pi_width/4 + 15, 0])
            cube([wall*3, 7, 4], center=true);
    }

    // USB-A cutouts (2x)
    translate([-pi_length/2, pi_width/4 - 5, 0])
        cube([wall*3, 15, 8], center=true);
    translate([-pi_length/2, pi_width/4 - 22, 0])
        cube([wall*3, 15, 8], center=true);

    // Ethernet cutout
    translate([-pi_length/2, -pi_width/4 + 5, 0])
        cube([wall*3, 16, 14], center=true);

    // Ventilation slots (bottom)
    for (i = [0:vent_slots-1]) {
        translate([i * 12 - 24, 0, -pi_height/4])
            cube([8, pi_width - 10, wall + 1], center=true);
    }

    // Mounting posts holes
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * 29, y * 24.5, -pi_height/4])
                cylinder(d=2.7, h=10, center=true, $fn=32);
        }
    }
}

// Mounting posts
for (x = [-1, 1]) {
    for (y = [-1, 1]) {
        translate([x * 29, y * 24.5, wall/2])
            difference() {
                cylinder(d=6, h=3, $fn=32);
                cylinder(d=2.5, h=4, $fn=32);
            }
    }
}
