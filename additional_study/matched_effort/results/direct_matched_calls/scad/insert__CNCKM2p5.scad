$fn=120;

// Heat-set insert (approximation)
// Outer diameter: 4.0 mm
// Length: 4.6 mm
// For M2.5 screw (internal thread approximated as smooth bore)

od = 4.0;
len = 4.6;

// Typical M2.5 internal thread minor diameter ~2.05-2.15 mm; use 2.1 mm bore
id = 2.1;

// Simple heat-set insert knurl approximation
knurl_rib_count = 24;
knurl_depth = 0.25;          // radial depth of knurl ribs
knurl_rib_width = 0.35;      // tangential width (approx via cylinder)
lead_in = 0.35;              // chamfer height at both ends

module chamfered_cylinder(h, r, chamfer_h){
    // Chamfer both ends by subtracting cones
    difference(){
        cylinder(h=h, r=r);
        // bottom chamfer
        translate([0,0,-0.01])
            cylinder(h=chamfer_h+0.02, r1=r+0.01, r2=max(r-chamfer_h, 0.01));
        // top chamfer
        translate([0,0,h-chamfer_h-0.01])
            cylinder(h=chamfer_h+0.02, r1=max(r-chamfer_h, 0.01), r2=r+0.01);
    }
}

module knurled_shell(h, r_outer, rib_count, rib_depth, rib_width){
    // Base cylinder plus outward ribs, then trimmed to OD
    intersection(){
        union(){
            cylinder(h=h, r=r_outer - rib_depth);
            for(i=[0:rib_count-1]){
                rotate([0,0,360*i/rib_count])
                    translate([r_outer - rib_depth/2, 0, 0])
                        cylinder(h=h, r=rib_width/2);
            }
        }
        cylinder(h=h, r=r_outer);
    }
}

difference(){
    // Outer body with knurl and chamfers
    union(){
        // knurled midsection
        translate([0,0,lead_in])
            knurled_shell(len-2*lead_in, od/2, knurl_rib_count, knurl_depth, knurl_rib_width);

        // end sections (smooth) with chamfers
        chamfered_cylinder(lead_in, od/2, lead_in);
        translate([0,0,len-lead_in])
            chamfered_cylinder(lead_in, od/2, lead_in);
    }

    // Internal bore (thread not modeled)
    translate([0,0,-0.2])
        cylinder(h=len+0.4, r=id/2);
}