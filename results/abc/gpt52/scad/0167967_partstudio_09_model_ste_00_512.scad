$fn=128;

module tooth2d(r_root=0.045, r_tip=0.05, tooth_angle=6, gap_angle=6){
    polygon(points=[
        [r_root*cos(-gap_angle/2), r_root*sin(-gap_angle/2)],
        [r_tip*cos(0),            r_tip*sin(0)],
        [r_root*cos(gap_angle/2),  r_root*sin(gap_angle/2)]
    ]);
}

module rosette2d(r_root=0.045, r_tip=0.05, teeth=30){
    step = 360/teeth;
    gap = step*0.55;
    union(){
        circle(r=r_root);
        for(i=[0:teeth-1]){
            rotate(i*step) tooth2d(r_root=r_root, r_tip=r_tip, gap_angle=gap);
        }
    }
}

module rosette_plate(d=0.1, thickness=0.01, teeth=30){
    r_tip = d/2;
    r_root = r_tip*0.90;
    linear_extrude(height=thickness, center=true, convexity=10)
        rosette2d(r_root=r_root, r_tip=r_tip, teeth=teeth);
}

rosette_plate(d=0.1, thickness=0.01, teeth=30);