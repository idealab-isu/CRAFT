$fn=180;

// Threaded heat-set insert (simplified, renderable model)
// Specs: 18.0mm outer diameter, 16.0mm long, for 8.0mm screws (M8 clearance/tap-like bore)

od = 18.0;
len = 16.0;

// Internal bore sized for M8 screw (approx. tap drill / minor diameter region)
id = 6.8;          // typical M8x1.25 tap drill ~6.8mm
lead_in = 1.2;     // chamfer height
chamfer = 0.8;     // chamfer radial amount

// External knurl-like ribs (heat-set inserts often have barbs/knurls)
rib_count = 36;
rib_depth = 0.6;   // radial protrusion
rib_width = 0.9;   // tangential width (approx)
rib_len = len - 2.0; // leave small margins at ends

module insert_body() {
    difference() {
        union() {
            // Base cylinder
            cylinder(d=od, h=len);

            // Ribs
            for (i = [0 : rib_count-1]) {
                rotate([0,0, i*360/rib_count])
                    translate([od/2 - rib_depth/2, 0, (len - rib_len)/2])
                        cube([rib_depth, rib_width, rib_len], center=true);
            }
        }

        // Internal bore
        translate([0,0,-0.1])
            cylinder(d=id, h=len+0.2);

        // Lead-in chamfers (both ends)
        // Top
        translate([0,0,len-lead_in])
            cylinder(h=lead_in+0.1, d1=id+2*chamfer, d2=id);
        // Bottom
        translate([0,0,-0.1])
            cylinder(h=lead_in+0.1, d1=id, d2=id+2*chamfer);
    }
}

insert_body();