$fn=128;

outer_r = 20;
band_w = 6;
inner_r = outer_r - band_w;

thk = 3;

gap_deg = 55;
start_deg = gap_deg/2;
end_deg = 360 - gap_deg/2;

end_round_r = band_w/2;
bulb_r = band_w*0.75;

module ring_band_2d(){
    difference(){
        circle(r=outer_r);
        circle(r=inner_r);
    }
}

module sector_mask_2d(a1, a2, r){
    polygon(points=concat([[0,0]],
        [for (a=[a1:1:a2]) [r*cos(a), r*sin(a)]],
        [[r*cos(a2), r*sin(a2)]]
    ));
}

module c_clip_2d(){
    union(){
        intersection(){
            ring_band_2d();
            sector_mask_2d(start_deg, end_deg, outer_r+band_w*2);
        }
        for (a=[start_deg, end_deg]){
            translate([ (outer_r - band_w/2)*cos(a), (outer_r - band_w/2)*sin(a) ])
                circle(r=end_round_r);
        }
        translate([ (outer_r - band_w/2)*cos(start_deg), (outer_r - band_w/2)*sin(start_deg) ])
            circle(r=bulb_r);
    }
}

linear_extrude(height=thk, center=true, convexity=10)
    c_clip_2d();