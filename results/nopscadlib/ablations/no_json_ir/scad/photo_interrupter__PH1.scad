$fn = 64;

// Parameters (mm)
interrupter_width     = 20;   // X
interrupter_height    = 30;   // Z
interrupter_thickness = 5;    // Y (depth)

gap_width = 10;               // X opening
gap_depth = 15;               // Z depth of slot from top

mounting_hole_diameter = 3;

pcb_width     = 25;           // X
pcb_length    = 40;           // Y
pcb_thickness = 1.6;          // Z

base_plate_thickness = 2;     // Z

// Small overlap to guarantee watertight unions
overlap = 0.6;

// Interrupter Body (U-shaped slot)
module interrupter_body() {
    difference() {
        // Solid block first, then cut the U-slot out of it
        cube([interrupter_width, interrupter_thickness, interrupter_height], center=false);

        // Slot cutout (opens at the TOP, goes down by gap_depth)
        translate([(interrupter_width - gap_width)/2, -overlap, interrupter_height - gap_depth])
            cube([gap_width, interrupter_thickness + 2*overlap, gap_depth + overlap], center=false);
    }
}

// Mounting holes as SUBTRACTIONS (through Y)
module mounting_holes_cut() {
    // Place holes in the two "arms" (left and right of the slot)
    // Keep them centered in Y and within the arm thickness in X.
    arm_w = (interrupter_width - gap_width)/2;
    hole_x_offset = arm_w/2; // center of each arm

    for (x = [hole_x_offset, interrupter_width - hole_x_offset]) {
        translate([x, interrupter_thickness/2, interrupter_height - gap_depth/2])
            rotate([90, 0, 0])
                cylinder(h = interrupter_thickness + 2*overlap,
                         d = mounting_hole_diameter,
                         center=true);
    }
}

// PCB block (connected to body with calculated placement + overlap)
module pcb_block() {
    // Attach to the BACK face (positive Y) of the interrupter body
    translate([
        interrupter_width/2 - pcb_width/2,
        interrupter_thickness - overlap,
        -pcb_thickness
    ])
        cube([pcb_width, pcb_length, pcb_thickness], center=false);
}

// Base plate block (connected to PCB with overlap)
module base_plate_block() {
    translate([
        interrupter_width/2 - pcb_width/2,
        interrupter_thickness - overlap,
        -pcb_thickness - base_plate_thickness + overlap
    ])
        cube([pcb_width, pcb_length, base_plate_thickness], center=false);
}

// Photo Interrupter Assembly (ONE connected solid)
module photo_interrupter() {
    difference() {
        union() {
            interrupter_body();
            pcb_block();
            base_plate_block();
        }
        mounting_holes_cut();
    }
}

photo_interrupter();