$fn = 64;

// Leadscrew nut housing block (X width, Y length, Z height)
block_W = 8.0;     // X
block_L = 12.75;   // Y
block_H = 19.0;    // Z

// Simple, recognizable "leadscrew nut housing" features
clearance = 0.25;          // small clearance for fit
overlap   = 1.0;           // overlap for robust boolean ops

// Through bore for leadscrew (runs along Z)
screw_d = 4.0 + clearance; // generic leadscrew clearance

// Pocket to hold a cylindrical nut insert (counterbore from top)
nut_od  = 7.0 + clearance; // must fit within 8mm width
nut_h   = 8.0;             // depth of nut pocket from top

// Two mounting holes (through Z), spaced along Y
mount_d = 2.2 + clearance;
mount_y_spacing = 8.0;     // keep within 12.75mm length

module model() {
    // Single connected solid: one block with subtracted bores/pockets
    difference() {
        // Main rectangular housing block (matches 8.0 x 12.75 x 19.0)
        cube([block_W, block_L, block_H], center=true);

        // Central leadscrew through-hole (Z axis)
        cylinder(d=screw_d, h=block_H + 2*overlap, center=true);

        // Nut pocket (counterbore) from the top face down
        // Top face at +block_H/2; pocket extends downward by nut_h
        translate([0, 0, (block_H/2) - (nut_h/2) + (overlap/2)])
            cylinder(d=nut_od, h=nut_h + overlap, center=true);

        // Mounting holes (through Z), symmetric along Y
        for (y = [-mount_y_spacing/2, mount_y_spacing/2]) {
            translate([0, y, 0])
                cylinder(d=mount_d, h=block_H + 2*overlap, center=true);
        }
    }
}

model();