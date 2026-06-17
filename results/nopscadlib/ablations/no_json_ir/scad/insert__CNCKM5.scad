$fn = 140;

// Target dimensions
od  = 5.8;   // outer diameter
len = 7.1;   // overall length

// Internal thread/bore for 5.0mm screw (modeled as a clearance bore)
bore_d = 5.0;

// Lead-in chamfers
chamfer_h = 0.6;

// External knurl/barbs (approximated as repeated ribs)
knurl_count = 24;
knurl_depth = 0.35;                 // radial protrusion beyond OD/2
knurl_z0 = chamfer_h;               // keep ends clean for chamfers
knurl_z1 = len - chamfer_h;
knurl_h  = knurl_z1 - knurl_z0;

// Small overlap to ensure watertight unions/differences
eps = 0.02;

module outer_body_with_knurl() {
    union() {
        // Base cylinder at nominal OD
        cylinder(d=od, h=len, center=false);

        // Knurl ribs: use 3D wedges (not 2D polygons) to avoid empty/degenerate geometry
        for (i = [0:knurl_count-1]) {
            rotate([0,0,i*360/knurl_count])
                translate([0,0,knurl_z0])
                    linear_extrude(height=knurl_h, center=false, convexity=10)
                        polygon(points=[
                            [od/2 - eps, -0.35],
                            [od/2 - eps,  0.35],
                            [od/2 + knurl_depth, 0]
                        ]);
        }
    }
}

module internal_bore_with_chamfers() {
    union() {
        // Through bore
        translate([0,0,-eps])
            cylinder(d=bore_d, h=len + 2*eps, center=false);

        // Top lead-in chamfer (bore -> outer)
        translate([0,0,len - chamfer_h])
            cylinder(d1=bore_d, d2=od, h=chamfer_h + eps, center=false);

        // Bottom lead-in chamfer (outer -> bore)
        translate([0,0,-eps])
            cylinder(d1=od, d2=bore_d, h=chamfer_h + eps, center=false);
    }
}

module threaded_insert() {
    difference() {
        outer_body_with_knurl();
        internal_bore_with_chamfers();
    }
}

threaded_insert();