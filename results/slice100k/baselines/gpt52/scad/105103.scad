$fn=96;

W = 24.4;
L = 99.3;
T = 3.0;

plate_len = 26.0;
bar_len = L - plate_len;

bar_w = 12.0;

tip_len = 10.0;

tooth_pitch = 3.0;
tooth_depth = 2.2;
tooth_count = floor((bar_len - tip_len - 2.0)/tooth_pitch);

hole_d = 4.2;
hole_offset_y = 7.5;

star_r_outer = 5.2;
star_r_inner = 2.6;
star_points = 8;

module star2d(points=8, r1=5, r2=2.5, rot=0){
    polygon(points=[
        for(i=[0:2*points-1])
            let(a = rot + i*180/points)
            [ (i%2==0 ? r1 : r2)*cos(a), (i%2==0 ? r1 : r2)*sin(a) ]
    ]);
}

module mounting_plate_2d(){
    union(){
        polygon(points=[
            [0, -W/2],
            [plate_len*0.62, -W/2],
            [plate_len, 0],
            [plate_len*0.62, W/2],
            [0, W/2]
        ]);
        translate([plate_len*0.18, 0])
            square([plate_len*0.18, W*0.78], center=true);
    }
}

module bar_body_2d(){
    union(){
        translate([plate_len, -bar_w/2])
            square([bar_len - tip_len, bar_w], center=false);
        polygon(points=[
            [plate_len + (bar_len - tip_len), -bar_w/2],
            [plate_len + bar_len, 0],
            [plate_len + (bar_len - tip_len), bar_w/2]
        ]);
    }
}

module serrations_2d(){
    union(){
        for(i=[0:tooth_count-1]){
            x0 = plate_len + i*tooth_pitch;
            polygon(points=[
                [x0, -bar_w/2],
                [x0 + tooth_pitch, -bar_w/2],
                [x0 + tooth_pitch/2, -bar_w/2 - tooth_depth]
            ]);
        }
    }
}

module profile_2d(){
    difference(){
        union(){
            mounting_plate_2d();
            bar_body_2d();
        }
        serrations_2d();
        translate([plate_len*0.45, -hole_offset_y]) circle(d=hole_d);
        translate([plate_len*0.45,  hole_offset_y]) circle(d=hole_d);
        translate([plate_len*0.62, 0]) star2d(points=star_points, r1=star_r_outer, r2=star_r_inner, rot=22.5);
    }
}

translate([-L/2, 0, -T/2])
    linear_extrude(height=T)
        profile_2d();