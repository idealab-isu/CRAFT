$fn=180;

// Threaded heat-set insert (simplified, renderable model)
// Specs: 10.0mm outer diameter, 8.0mm long, for 4.0mm screws

outer_d = 10.0;
length  = 8.0;

// Typical M4 internal thread minor diameter ~3.3mm; model as clearance/minor bore
inner_d = 3.3;

// Add a small lead-in chamfer on both ends
chamfer = 0.6;

// Optional shallow knurl-like rings to suggest heat-set insert texture
ring_pitch = 1.0;
ring_depth = 0.35;
ring_width = 0.45;

module insert_body() {
    difference() {
        // Outer body with end chamfers
        union() {
            // Main cylinder
            cylinder(d=outer_d, h=length - 2*chamfer);

            // Bottom chamfer
            cylinder(d1=outer_d, d2=outer_d - 2*chamfer, h=chamfer);

            // Top chamfer
            translate([0,0,length - chamfer])
                cylinder(d1=outer_d - 2*chamfer, d2=outer_d, h=chamfer);
        }

        // Through bore
        translate([0,0,-0.5])
            cylinder(d=inner_d, h=length + 1.0);

        // Ring grooves (subtractive) to mimic heat-set insert ribs
        for (z = [chamfer + ring_pitch/2 : ring_pitch : length - chamfer - ring_pitch/2]) {
            translate([0,0,z - ring_width/2])
                cylinder(d=outer_d + 0.2, h=ring_width);
            translate([0,0,z - ring_width/2])
                cylinder(d=outer_d - 2*ring_depth, h=ring_width + 0.01);
        }
    }
}

insert_body();