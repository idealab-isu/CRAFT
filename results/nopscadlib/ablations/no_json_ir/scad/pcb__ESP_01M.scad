// 18mm x 18mm PCB, 0.8mm thick — single connected solid
$fn = 64;

// Parameters
pcb_size      = 18.0;
pcb_thickness = 0.8;

// Optional mounting holes (set to 0 to disable)
hole_diameter = 1.0;
hole_offset   = 2.0;

// Main PCB solid (perfect square outline)
module pcb_solid() {
    difference() {
        // Board body: exact 18 x 18 x 0.8
        translate([0, 0, pcb_thickness/2])
            cube([pcb_size, pcb_size, pcb_thickness], center=true);

        // Mounting holes: through-holes, fully cut
        if (hole_diameter > 0) {
            for (x = [-1, 1], y = [-1, 1]) {
                translate([x*(pcb_size/2 - hole_offset),
                           y*(pcb_size/2 - hole_offset),
                           pcb_thickness/2])
                    cylinder(h=pcb_thickness + 0.2, d=hole_diameter, center=true);
            }
        }
    }
}

pcb_solid();