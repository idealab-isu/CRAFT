$fn=96;

thread_pitch = 0.8;
thread_major_d = 5.0;
thread_minor_d = 4.2;
thread_len = 18.0;

shank_d = 6.0;
shank_len = 6.0;

head_len = 12.0;
head_od = 12.0;

ball_od = 8.0;
ball_bore_d = 5.0;

race_wall = 1.2;
race_id = ball_od + 0.4;
race_od = race_id + 2*race_wall;

wrench_flat = 10.0;
wrench_thk = 4.0;

module hex_prism(flat=10, h=4){
    r = flat/(2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module external_thread(d_major=5, d_minor=4.2, pitch=0.8, len=18){
    turns = len/pitch;
    depth = (d_major - d_minor)/2;
    r0 = d_minor/2;
    linear_extrude(height=len, twist=360*turns, slices=max(ceil(turns*48), 48), convexity=10)
        translate([r0,0,0])
            polygon(points=[
                [0, -pitch*0.30],
                [depth, 0],
                [0, pitch*0.30]
            ]);
}

module rod_end_body(){
    union(){
        translate([0,0,-(thread_len+shank_len)])
            cylinder(h=thread_len, d=thread_major_d);

        translate([0,0,-shank_len])
            cylinder(h=shank_len, d=shank_d);

        translate([0,0,0])
            cylinder(h=head_len, d=head_od);

        translate([0,0,head_len*0.35])
            hex_prism(flat=wrench_flat, h=wrench_thk);
    }
}

module rod_end_eye(){
    difference(){
        translate([0,0,head_len*0.55])
            rotate([90,0,0])
                cylinder(h=head_od*0.92, d=race_od, center=true);

        translate([0,0,head_len*0.55])
            rotate([90,0,0])
                cylinder(h=head_od*1.2, d=race_id, center=true);

        translate([0,0,head_len*0.55])
            rotate([90,0,0])
                cylinder(h=head_od*1.4, d=ball_bore_d, center=true);
    }
}

module ball(){
    difference(){
        translate([0,0,head_len*0.55])
            sphere(d=ball_od);
        translate([0,0,head_len*0.55])
            rotate([90,0,0])
                cylinder(h=ball_od*1.6, d=ball_bore_d, center=true);
    }
}

module rod_end(){
    difference(){
        union(){
            rod_end_body();
            rod_end_eye();
            ball();
        }

        translate([0,0,-(thread_len+shank_len)])
            external_thread(d_major=thread_major_d, d_minor=thread_minor_d, pitch=thread_pitch, len=thread_len);

        translate([0,0,-(thread_len+shank_len)-0.2])
            cylinder(h=thread_len+0.4, d=thread_minor_d);
    }
}

translate([0,0,(thread_len+shank_len)/2 - head_len*0.25])
    rod_end();