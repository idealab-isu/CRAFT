$fn=128;

magnet_od = 20;
magnet_id = 6;
magnet_h  = 3;

pole_count = 8;
pole_depth = 0.6;
pole_margin = 0.4;

hub_od = magnet_id + 2.0;
hub_h  = magnet_h;

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module pole_wedge(od, id, h, depth, ang){
    r_outer = od/2 - pole_margin;
    r_inner = max(id/2 + pole_margin, r_outer - depth);
    rotate([0,0,-ang/2])
    linear_extrude(height=h, center=true, convexity=10)
        polygon(points=[
            [r_inner, 0],
            [r_outer, 0],
            [r_outer*cos(ang), r_outer*sin(ang)],
            [r_inner*cos(ang), r_inner*sin(ang)]
        ]);
}

module radial_encoder_magnet(od, id, h, poles, depth){
    base = ring(od, id, h);
    difference(){
        union(){
            base;
            cylinder(d=hub_od, h=hub_h, center=true);
        }
        for(i=[0:poles-1]){
            if (i % 2 == 0)
                rotate([0,0, i*360/poles])
                    pole_wedge(od, id, h+0.4, depth, 360/poles*0.92);
        }
    }
}

radial_encoder_magnet(magnet_od, magnet_id, magnet_h, pole_count, pole_depth);