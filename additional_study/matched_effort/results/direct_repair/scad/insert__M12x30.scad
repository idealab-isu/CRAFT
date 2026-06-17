$fn = 180;

// Threaded heat-set insert (simplified, renderable model)
// Outer diameter: 30.0 mm
// Length: 22.0 mm
// For 12.0 mm screws (internal clearance hole modeled)

outer_d = 30.0;
length  = 22.0;

screw_d = 12.0;
inner_clearance_d = screw_d + 0.6;   // simple clearance

// Heat-set style features (approximation)
lead_in = 2.0;        // chamfer height each end
knurl_depth = 0.8;    // radial depth of knurl grooves
knurl_count = 48;     // number of grooves around
knurl_width = 0.9;    // groove angular width effect via cylinder radius
knurl_z0 = 2.0;       // start of knurl band
knurl_z1 = length - 2.0;

module insert_body() {
    difference() {
        // Outer body with end chamfers
        union() {
            // main cylinder
            cylinder(d=outer_d, h=length);

            // subtractive chamfers will be applied in difference below
        }

        // Chamfer top
        translate([0,0,length-lead_in])
            cylinder(d1=outer_d, d2=outer_d-2*lead_in, h=lead_in+0.01);

        // Chamfer bottom
        translate([0,0,-0.01])
            cylinder(d1=outer_d-2*lead_in, d2=outer_d, h=lead_in+0.02);

        // Internal clearance hole
        translate([0,0,-0.5])
            cylinder(d=inner_clearance_d, h=length+1.0);

        // Knurl grooves (axial flutes)
        for (i = [0:knurl_count-1]) {
            rotate([0,0, i*360/knurl_count])
                translate([outer_d/2 - knurl_depth/2, 0, knurl_z0])
                    cylinder(d=knurl_depth, h=knurl_z1-knurl_z0);
        }
    }
}

insert_body();