$fn=64;

rail_w = 5.0;
rail_h = 3.6;
rail_l = 100.0;

module rail_profile(w, h){
    // Simple miniature guide rail profile: rectangular base with two top chamfers
    chamfer = min(0.6, w/4, h/3);
    linear_extrude(height=1, center=true, convexity=10)
        polygon(points=[
            [-w/2, 0],
            [ w/2, 0],
            [ w/2, h-chamfer],
            [ w/2-chamfer, h],
            [-w/2+chamfer, h],
            [-w/2, h-chamfer]
        ]);
}

module rail_body(w, h, l){
    translate([0,0,0])
        rotate([90,0,0])
            scale([1,1,l])
                rail_profile(w,h);
}

module mounting_holes(l){
    hole_d = 2.0;
    head_d = 3.6;
    head_h = 1.2;
    pitch = 25.0;
    n = floor(l/pitch) + 1;
    for(i=[0:n-1]){
        y = -l/2 + i*pitch;
        if (y <= l/2 + 0.001)
            translate([0, y, 0]){
                cylinder(d=hole_d, h=rail_h+2, center=true);
                translate([0,0,rail_h/2 - head_h/2])
                    cylinder(d=head_d, h=head_h+0.2, center=true);
            }
    }
}

difference(){
    rail_body(rail_w, rail_h, rail_l);
    mounting_holes(rail_l);
}