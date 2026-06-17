// Parameters
pcb_length = 65.0;
pcb_width = 30.6;
pcb_thickness = 1.6;
hole_diameter = 3.0;
corner_radius = 3.0;

// Main PCB body
module pcb_main_body() {
    difference() {
        // Rounded rectangle for PCB
        offset(r=corner_radius) {
            square([pcb_length - 2*corner_radius, pcb_width - 2*corner_radius], center=true);
        }
        // Mounting holes
        for (x = [-pcb_length/2 + 5, pcb_length/2 - 5])
            for (y = [-pcb_width/2 + 5, pcb_width/2 - 5])
                translate([x, y, 0])
                    cylinder(h=pcb_thickness + 1, d=hole_diameter, center=true);
    }
}

// Silkscreen markings (simple example)
module silkscreen_markings() {
    translate([0, 0, pcb_thickness + 0.01])
        text("Sensor PCB", size=5, valign="center", halign="center");
}

// Component placeholders (simple example)
module component_placeholders() {
    translate([-15, 0, pcb_thickness])
        cube([10, 5, 3], center=true);
    translate([15, 0, pcb_thickness])
        cube([10, 5, 3], center=true);
}

// Edge connectors (simple example)
module edge_connectors() {
    translate([0, pcb_width/2, pcb_thickness/2])
        cube([20, 2, pcb_thickness], center=true);
}

// Assemble the PCB
module sensor_pcb() {
    pcb_main_body();
    silkscreen_markings();
    component_placeholders();
    edge_connectors();
}

// Render the PCB
sensor_pcb();