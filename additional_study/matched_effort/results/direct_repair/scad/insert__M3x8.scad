$fn = 120;

// Heat-set insert (simplified model)
// Specs: 8.0mm OD, 6.0mm long, for 3.0mm screws (M3 clearance-ish core)

od = 8.0;
len = 6.0;

// Typical M3 internal thread minor diameter is ~2.5mm; for a simple model use ~2.6mm bore
bore_d = 2.6;

// Add slight lead-in chamfers
chamfer = 0.5;

// Knurl approximation: shallow circumferential grooves
groove_depth = 0.35;
groove_pitch = 0.8;
groove_count = floor((len - 2*chamfer) / groove_pitch);

module insert_body() {
    difference() {
        // Outer body with chamfers
        union() {
            // main cylinder
            translate([0,0,chamfer])
                cylinder(d=od, h=len-2*chamfer);

            // bottom chamfer
            cylinder(d1=od-2*chamfer, d2=od, h=chamfer);

            // top chamfer
            translate([0,0,len-chamfer])
                cylinder(d1=od, d2=od-2*chamfer, h=chamfer);
        }

        // Bore through
        translate([0,0,-0.2])
            cylinder(d=bore_d, h=len+0.4);

        // Grooves (ring cuts)
        for (i = [0:groove_count-1]) {
            z0 = chamfer + (i + 0.5) * groove_pitch;
            translate([0,0,z0])
                rotate_extrude()
                    translate([od/2 - groove_depth, 0, 0])
                        square([groove_depth+0.01, 0.35], center=false);
        }
    }
}

insert_body();