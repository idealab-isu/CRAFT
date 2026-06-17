$fn=180;

// Radial encoder magnet (ring magnet with alternating N/S poles around the circumference)
// Model: a thin ring with shallow radial grooves to visually indicate pole segments.
// Dimensions are parametric and suitable for rendering/printing a representative encoder magnet.

outer_d = 12;        // mm
inner_d = 6;         // mm (shaft hole)
thickness = 2.5;     // mm
segments = 12;       // number of pole pairs/segments around the ring
groove_depth = 0.35; // mm (visual pole segmentation)
groove_width = 0.7;  // mm (tangential width at mid-radius)

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2);
    }
}

module radial_grooves(od, id, h, n, depth, w){
    r_mid = (od + id)/4; // mid radius
    for(i=[0:n-1]){
        a = 360/n * i;
        rotate([0,0,a])
            translate([r_mid,0,h - depth])
                cube([ (od-id)/2 + 1, w, depth + 0.2 ], center=false);
    }
}

difference(){
    ring(outer_d, inner_d, thickness);

    // Cut shallow grooves on the top face to indicate alternating poles
    radial_grooves(outer_d, inner_d, thickness, segments, groove_depth, groove_width);

    // Optional: slight chamfer-like relief on bottom face (very subtle)
    translate([0,0,0])
        radial_grooves(outer_d, inner_d, 0.001, segments, groove_depth*0.6, groove_width*0.9);
}