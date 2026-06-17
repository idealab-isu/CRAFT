$fn=96;

// Generic "component": a small mounting block with rounded corners,
// two countersunk through-holes, and a central cable/slot cutout.

module rounded_block(size=[60,30,12], r=4){
    x=size[0]; y=size[1]; z=size[2];
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=z, r=r);
    }
}

module countersunk_hole(th=12, d_through=4.2, d_head=8.5, head_depth=3){
    // Through hole
    cylinder(h=th+0.2, d=d_through, center=false);
    // Countersink (simple conical)
    translate([0,0,th-head_depth])
        cylinder(h=head_depth+0.2, d1=d_head, d2=d_through);
}

module component(){
    base=[60,30,12];
    r=4;

    difference(){
        // Body
        rounded_block(base, r);

        // Two countersunk mounting holes
        for (xpos=[-18, 18]){
            translate([xpos, 0, 0])
                countersunk_hole(th=base[2], d_through=4.2, d_head=9.0, head_depth=3.2);
        }

        // Central slot cutout
        translate([0,0,base[2]/2])
            cube([22,10,base[2]+0.4], center=true);

        // Small side relief notch
        translate([base[0]/2-6, 0, base[2]/2])
            cube([12,14,6], center=true);
    }
}

component();