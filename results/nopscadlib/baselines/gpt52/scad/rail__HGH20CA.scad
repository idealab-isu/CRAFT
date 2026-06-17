$fn=64;

rail_w = 20.0;
rail_h = 17.5;
rail_l = 100.0;

base_h = 10.0;
top_h = rail_h - base_h;

top_w = 12.0;
chamfer = 2.0;

hole_d = 4.2;
csk_d = 7.5;
csk_h = 2.0;

hole_count = 5;
end_margin = 10.0;

module rail_profile(len=rail_l){
    union(){
        translate([0,0,-rail_h/2 + base_h/2])
            cube([rail_w, len, base_h], center=true);

        translate([0,0,-rail_h/2 + base_h + top_h/2])
            linear_extrude(height=len, center=true, convexity=10)
                polygon(points=[
                    [-top_w/2, 0],
                    [ top_w/2, 0],
                    [ top_w/2 + chamfer, top_h],
                    [-top_w/2 - chamfer, top_h]
                ]);
    }
}

module mounting_holes(){
    for(i=[0:hole_count-1]){
        y = -rail_l/2 + end_margin + i*((rail_l - 2*end_margin)/(hole_count-1));
        translate([0,y,-rail_h/2])
            cylinder(d=hole_d, h=rail_h+0.4, center=false);

        translate([0,y,rail_h/2 - csk_h])
            cylinder(d1=csk_d, d2=hole_d, h=csk_h+0.2, center=false);
    }
}

difference(){
    rail_profile(rail_l);
    mounting_holes();
}