// Parameters
pcb_length = 123.0;
pcb_width = 100.0;
pcb_thickness = 1.6;
corner_radius = 5.0;
hole_diameter = 3.0;
hole_offset = 10.0;

// Main PCB body with corner fillets
module pcb_main_body() {
    difference() {
        offset(r=corner_radius) {
            square([pcb_length - 2*corner_radius, pcb_width - 2*corner_radius], center=true);
        }
        translate([-pcb_length/2, -pcb_width/2, -pcb_thickness/2])
            cube([pcb_length, pcb_width, pcb_thickness]);
    }
}

// Mounting holes
module mounting_holes() {
    for (x = [-pcb_length/2 + hole_offset, pcb_length/2 - hole_offset])
        for (y = [-pcb_width/2 + hole_offset, pcb_width/2 - hole_offset])
            translate([x, y, 0])
                cylinder(h=pcb_thickness + 1, d=hole_diameter, center=true);
}

// Silkscreen markings (simple representation)
module silkscreen_markings() {
    translate([0, 0, pcb_thickness + 0.1])
        text("PCB", size=10, valign="center", halign="center");
}

// Connectors and components (simple representation)
module connectors_and_components() {
    translate([-30, 0, pcb_thickness/2])
        cube([10, 5, 5], center=true);
    translate([30, 0, pcb_thickness/2])
        cube([10, 5, 5], center=true);
}

// Assemble the PCB
module pcb() {
    pcb_main_body();
    mounting_holes();
    silkscreen_markings();
    connectors_and_components();
}

// Render the PCB
pcb();