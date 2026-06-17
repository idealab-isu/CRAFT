$fn=128;

bore_d = 5.0;
od_d = 9.0;
width = 2.5;

ring_th = 0.6;
race_depth = 0.55;

inner_od = bore_d + 2*ring_th;
outer_id = od_d - 2*ring_th;

ball_d = 0.8;
ball_count = 8;

module ring(od, id, w){
  difference(){
    cylinder(d=od, h=w, center=true);
    cylinder(d=id, h=w+0.2, center=true);
  }
}

module race_groove(d_center, groove_d, w){
  rotate_extrude(convexity=10)
    translate([d_center/2, 0, 0])
      circle(d=groove_d);
}

module balls(d_center, bd, n, w){
  for(i=[0:n-1]){
    rotate([0,0,360*i/n])
      translate([d_center/2,0,0])
        sphere(d=bd);
  }
}

module bearing(){
  difference(){
    union(){
      ring(inner_od, bore_d, width);
      ring(od_d, outer_id, width);
      balls((inner_od+outer_id)/2, ball_d, ball_count, width);
    }
    race_groove(inner_od, race_depth*2, width);
    race_groove(outer_id, race_depth*2, width);
  }
}

bearing();