$fn=96;

od = 19.0;
len = 25.0;

bore1_d = 6.0;
bore2_d = 8.0;

split_z = len/2;

clamp_screw_d = 3.0;
clamp_screw_head_d = 6.0;
clamp_screw_head_h = 2.2;

slit_w = 0.8;
slit_depth = od*0.55;

helical_slot_w = 1.2;
helical_slot_depth = 2.2;
helical_turns = 3;
helical_slices = 180;

module body(){
  cylinder(d=od, h=len, center=true);
}

module stepped_bore(){
  union(){
    translate([0,0,-len/4]) cylinder(d=bore1_d, h=len/2 + 0.2, center=true);
    translate([0,0, len/4]) cylinder(d=bore2_d, h=len/2 + 0.2, center=true);
  }
}

module center_stop(){
  cylinder(d=od*0.35, h=1.2, center=true);
}

module clamp_slit(zc){
  translate([0,0,zc])
    translate([od/2 - slit_depth/2, 0, 0])
      cube([slit_depth, slit_w, len/2 + 0.6], center=true);
}

module clamp_screw(zc){
  translate([0,0,zc]){
    rotate([0,90,0]){
      cylinder(d=clamp_screw_d, h=od+2, center=true);
      translate([0,0, od/2 - clamp_screw_head_h/2])
        cylinder(d=clamp_screw_head_d, h=clamp_screw_head_h+0.2, center=true);
      translate([0,0,-od/2 + clamp_screw_head_h/2])
        cylinder(d=clamp_screw_head_d, h=clamp_screw_head_h+0.2, center=true);
    }
  }
}

module helical_slots(){
  for(i=[0:helical_slices-1]){
    t = i/(helical_slices-1);
    ang = 360*helical_turns*t;
    zpos = -len/2 + len*t;
    rotate([0,0,ang])
      translate([od/2 - helical_slot_depth/2, 0, zpos])
        cube([helical_slot_depth, helical_slot_w, len/helical_slices*1.6], center=true);
  }
  for(i=[0:helical_slices-1]){
    t = i/(helical_slices-1);
    ang = 360*helical_turns*t + 180;
    zpos = -len/2 + len*t;
    rotate([0,0,ang])
      translate([od/2 - helical_slot_depth/2, 0, zpos])
        cube([helical_slot_depth, helical_slot_w, len/helical_slices*1.6], center=true);
  }
}

difference(){
  body();
  stepped_bore();
  center_stop();
  helical_slots();
  clamp_slit(-len/4);
  clamp_slit( len/4);
  clamp_screw(-len/4);
  clamp_screw( len/4);
}