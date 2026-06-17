$fn=180;

// Threaded heat-set insert (simplified, renderable model)
// Outer diameter: 30.0 mm
// Length: 25.0 mm
// For 16.0 mm screws (modeled as internal clearance hole)

outer_d = 30.0;
length  = 25.0;

screw_d = 16.0;          // nominal screw diameter
clearance = 0.8;         // extra clearance for internal hole
inner_d = screw_d + clearance;

chamfer_h = 1.2;         // lead-in chamfer height
knurl_depth = 0.8;       // radial depth of knurl cuts
knurl_count = 48;        // number of knurl flutes around circumference
knurl_twist = 18;        // degrees of twist over full length (helical knurl impression)

module insert_body() {
    difference() {
        // Outer body with slight end chamfers
        union() {
            cylinder(h=length, d=outer_d);
            // top chamfer (subtract later via difference with cones)
        }

        // Internal clearance hole
        translate([0,0,-0.2])
            cylinder(h=length+0.4, d=inner_d);

        // End chamfers (remove material)
        // Bottom chamfer
        translate([0,0,-0.01])
            cylinder(h=chamfer_h+0.02, d1=outer_d+2.0, d2=outer_d-0.6);
        // Top chamfer
        translate([0,0,length-chamfer_h-0.01])
            cylinder(h=chamfer_h+0.02, d1=outer_d-0.6, d2=outer_d+2.0);

        // Knurl/flutes: helical rectangular cuts around the outside
        for (i = [0:knurl_count-1]) {
            rotate([0,0, i*360/knurl_count])
                translate([outer_d/2 - knurl_depth/2, 0, 0])
                    linear_extrude(height=length, twist=knurl_twist, slices=120, convexity=10)
                        square([knurl_depth, 1.2], center=true);
        }
    }
}

insert_body();