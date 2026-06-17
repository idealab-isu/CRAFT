$fn=180;

// Threaded heat-set insert (simplified, renderable model)
// Specs: 18.0mm outer diameter, 16.0mm long, for 8.0mm screws (internal clearance hole)

outer_d = 18.0;
length  = 16.0;

// For 8mm screw: provide a reasonable internal clearance hole (not modeled as thread)
inner_d = 8.6;

// Heat-set inserts often have a lead-in chamfer and some external knurl/rings.
// We'll approximate with shallow circumferential grooves.
groove_depth = 0.6;
groove_pitch = 2.0;
groove_width = 0.9;

// Chamfers
chamfer_h = 1.0;

module insert_body() {
    difference() {
        // Outer body with chamfers
        union() {
            // Main cylinder
            translate([0,0,chamfer_h])
                cylinder(h=length-2*chamfer_h, d=outer_d);

            // Bottom chamfer
            cylinder(h=chamfer_h, d1=outer_d-2*chamfer_h, d2=outer_d);

            // Top chamfer
            translate([0,0,length-chamfer_h])
                cylinder(h=chamfer_h, d1=outer_d, d2=outer_d-2*chamfer_h);
        }

        // Internal hole
        translate([0,0,-0.2])
            cylinder(h=length+0.4, d=inner_d);

        // External grooves (subtractive rings)
        for (z = [chamfer_h + groove_pitch/2 : groove_pitch : length - chamfer_h - groove_pitch/2]) {
            translate([0,0,z - groove_width/2])
                cylinder(h=groove_width, d=outer_d + 0.2); // slightly oversize to ensure clean cut
            translate([0,0,z - groove_width/2])
                cylinder(h=groove_width, d=outer_d - 2*groove_depth);
        }
    }
}

// Groove subtraction implemented via difference of two cylinders per ring is awkward;
// instead, build grooves as a union of ring volumes and subtract them.
module grooved_insert() {
    difference() {
        // Outer body (no grooves)
        difference() {
            union() {
                translate([0,0,chamfer_h])
                    cylinder(h=length-2*chamfer_h, d=outer_d);
                cylinder(h=chamfer_h, d1=outer_d-2*chamfer_h, d2=outer_d);
                translate([0,0,length-chamfer_h])
                    cylinder(h=chamfer_h, d1=outer_d, d2=outer_d-2*chamfer_h);
            }
            translate([0,0,-0.2])
                cylinder(h=length+0.4, d=inner_d);
        }

        // Subtract grooves as shallow ring cuts
        union() {
            for (z = [chamfer_h + groove_pitch/2 : groove_pitch : length - chamfer_h - groove_pitch/2]) {
                translate([0,0,z - groove_width/2])
                    difference() {
                        cylinder(h=groove_width, d=outer_d + 0.4);
                        cylinder(h=groove_width, d=outer_d - 2*groove_depth);
                    }
            }
        }
    }
}

grooved_insert();