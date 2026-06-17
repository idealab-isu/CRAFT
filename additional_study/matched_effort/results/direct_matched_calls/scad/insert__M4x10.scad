$fn=128;

// Heat-set insert (simplified model)
// Outer diameter: 10.0 mm
// Length: 8.0 mm
// For 4.0 mm screws (modeled as M4 clearance through-hole)

od = 10.0;
len = 8.0;

// Typical M4 clearance ~4.3 mm; adjust if you want tighter/looser
id = 4.3;

// Small lead-in chamfers
chamfer = 0.6;

// Knurl approximation (ring grooves)
groove_depth = 0.35;
groove_pitch = 1.0;
groove_width = 0.45;

module insert_body() {
    difference() {
        // Outer body with chamfers
        union() {
            // Main cylinder
            translate([0,0,chamfer])
                cylinder(h=len-2*chamfer, d=od);

            // Bottom chamfer
            cylinder(h=chamfer, d1=od-2*chamfer, d2=od);

            // Top chamfer
            translate([0,0,len-chamfer])
                cylinder(h=chamfer, d1=od, d2=od-2*chamfer);
        }

        // Inner through-hole
        translate([0,0,-0.5])
            cylinder(h=len+1.0, d=id);

        // Ring grooves to suggest knurling
        for (z = [chamfer + groove_pitch/2 : groove_pitch : len - chamfer - groove_pitch/2]) {
            translate([0,0,z - groove_width/2])
                cylinder(h=groove_width, d=od + 0.02); // ensure clean subtraction
            translate([0,0,z - groove_width/2])
                cylinder(h=groove_width, d=od - 2*groove_depth);
        }
    }
}

// Groove subtraction helper: subtract thin rings by subtracting outer then adding inner back is messy.
// Instead, directly subtract a torus-like ring via difference of two cylinders.
module insert_with_grooves() {
    difference() {
        // Base outer shape (no grooves)
        union() {
            translate([0,0,chamfer])
                cylinder(h=len-2*chamfer, d=od);
            cylinder(h=chamfer, d1=od-2*chamfer, d2=od);
            translate([0,0,len-chamfer])
                cylinder(h=chamfer, d1=od, d2=od-2*chamfer);
        }

        // Inner through-hole
        translate([0,0,-0.5])
            cylinder(h=len+1.0, d=id);

        // Subtract ring grooves
        for (z = [chamfer + groove_pitch/2 : groove_pitch : len - chamfer - groove_pitch/2]) {
            translate([0,0,z - groove_width/2])
                difference() {
                    cylinder(h=groove_width, d=od + 0.02);
                    cylinder(h=groove_width, d=od - 2*groove_depth);
                }
        }
    }
}

insert_with_grooves();