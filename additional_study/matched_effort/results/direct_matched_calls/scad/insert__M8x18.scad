$fn=180;

// Threaded heat-set insert (simplified, renderable model)
// Specs: 18.0mm outer diameter, 16.0mm long, for 8.0mm screws

od = 18.0;
len = 16.0;

// For M8 screw: typical clearance ~8.4-8.6; typical tap drill ~6.8.
// Heat-set inserts usually have internal thread; model as a straight bore near tap-drill size.
id = 6.8;

// Add slight lead-in chamfers
ch = 0.8;

// Optional knurl-like ribs (visual + grip approximation)
rib_count = 24;
rib_depth = 0.6;
rib_width = 0.9;

module insert_body() {
    difference() {
        union() {
            // Main cylinder
            cylinder(d=od, h=len);

            // External ribs (approximation of knurl)
            for (i = [0 : rib_count-1]) {
                rotate([0,0, i*360/rib_count])
                    translate([od/2 - rib_depth/2, 0, 0])
                        cube([rib_depth, rib_width, len], center=false);
            }
        }

        // Internal bore
        translate([0,0,-0.01])
            cylinder(d=id, h=len+0.02);

        // Chamfer both ends (subtract cones)
        translate([0,0,-0.01])
            cylinder(d1=id+2*ch, d2=id, h=ch+0.02);

        translate([0,0,len-ch-0.01])
            cylinder(d1=id, d2=id+2*ch, h=ch+0.02);
    }
}

insert_body();