$fn=64;

sx=0.1;
sy=0.2;
sz=0.1;

module chamfered_block(size=[0.06,0.05,0.08], chamfer=0.004){
    x=size[0]; y=size[1]; z=size[2];
    c=max(0.0005, min(chamfer, min(x,y)/4));
    linear_extrude(height=z, center=true, convexity=10)
        offset(delta=-c)
            offset(delta=c)
                square([x,y], center=true);
}

module faceted_rod(len=0.2, r=0.012, twist=120, facets=10){
    linear_extrude(height=len, center=true, twist=twist, slices=60, convexity=10)
        polygon(points=[for(i=[0:facets-1]) [r*(0.85+0.25*sin(i*137)), r*(0.85+0.25*cos(i*91))] * [cos(360*i/facets), sin(360*i/facets)]]);
}

module faceted_knob(h=0.03, r=0.02, facets=8, twist=25){
    linear_extrude(height=h, center=true, twist=twist, slices=30, convexity=10)
        polygon(points=[for(i=[0:facets-1]) [r*(0.9+0.15*sin(i*73)), r*(0.9+0.15*cos(i*41))] * [cos(360*i/facets), sin(360*i/facets)]]);
}

module assembly(){
    union(){
        // Main rod along Y axis
        rotate([90,0,0]) faceted_rod(len=sy, r=0.012, twist=160, facets=11);

        // Block near one end
        translate([0, sy*0.33, 0])
            chamfered_block(size=[0.06,0.05,0.08], chamfer=0.004);

        // Knob closer to block
        translate([0.028, sy*0.10, 0.0])
            rotate([0,25,15])
                faceted_knob(h=0.03, r=0.02, facets=8, twist=35);

        // Knob farther away
        translate([-0.03, -sy*0.18, 0.01])
            rotate([10,-20,35])
                faceted_knob(h=0.028, r=0.018, facets=9, twist=-30);
    }
}

scale([1,1,1]) assembly();