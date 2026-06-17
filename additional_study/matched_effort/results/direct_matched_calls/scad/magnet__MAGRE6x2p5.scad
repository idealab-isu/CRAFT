$fn=180;

// Radial encoder magnet (ring magnet with alternating N/S poles around the circumference)
// Model: a simple ring with visual pole segmentation (geometry only; magnetization not modeled).

// Parameters (mm)
outer_d = 20;
inner_d = 8;
thickness = 3;
pole_count = 12;          // number of alternating poles around the ring
pole_gap_deg = 1.0;       // small gap between pole segments for visual separation
chamfer = 0.3;            // edge chamfer size

module ring_basic(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module chamfered_ring(od, id, h, c){
    // Approximate chamfer by subtracting cones at top/bottom edges
    difference(){
        ring_basic(od, id, h);
        // Outer top chamfer
        translate([0,0,h/2])
            cylinder(d1=od+0.01, d2=od-2*c, h=c+0.01, center=false);
        // Outer bottom chamfer
        translate([0,0,-h/2 - (c+0.01)])
            cylinder(d1=od-2*c, d2=od+0.01, h=c+0.01, center=false);

        // Inner top chamfer
        translate([0,0,h/2])
            cylinder(d1=id-0.01, d2=id+2*c, h=c+0.01, center=false);
        // Inner bottom chamfer
        translate([0,0,-h/2 - (c+0.01)])
            cylinder(d1=id+2*c, d2=id-0.01, h=c+0.01, center=false);
    }
}

module pole_segment(od, id, h, a0, a1){
    // Create a ring sector by intersecting ring with an angular wedge
    intersection(){
        chamfered_ring(od, id, h, chamfer);
        rotate([0,0,a0])
            linear_extrude(height=h+0.2, center=true)
                polygon(points=[
                    [0,0],
                    [od/2+1, 0],
                    [(od/2+1)*cos(a1-a0), (od/2+1)*sin(a1-a0)]
                ]);
    }
}

module radial_encoder_magnet(){
    // Build alternating pole segments (visual)
    seg = 360/pole_count;
    for(i=[0:pole_count-1]){
        a0 = i*seg + pole_gap_deg/2;
        a1 = (i+1)*seg - pole_gap_deg/2;
        // Alternate slight height emboss to distinguish poles
        h_i = thickness + (i%2==0 ? 0.15 : -0.15);
        color(i%2==0 ? [0.15,0.15,0.15] : [0.25,0.25,0.25])
            pole_segment(outer_d, inner_d, h_i, a0, a1);
    }
}

radial_encoder_magnet();