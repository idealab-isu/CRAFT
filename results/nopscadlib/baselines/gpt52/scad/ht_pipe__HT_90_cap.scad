$fn=96;

module ht_socket(od=110, wall=3.2, h=60, lip_h=6, lip_extra=2.0, chamfer=2.0){
    difference(){
        union(){
            cylinder(h=h, d=od);
            translate([0,0,h-lip_h]) cylinder(h=lip_h, d=od+2*lip_extra);
        }
        translate([0,0,wall]) cylinder(h=h+2, d=od-2*wall);
        translate([0,0,-0.1]) cylinder(h=wall+0.2, d=od-2*wall-2*chamfer);
        translate([0,0,wall-0.01]) cylinder(h=chamfer+0.02, d1=od-2*wall-2*chamfer, d2=od-2*wall);
    }
}

module ht_cap(od=110, wall=3.2, socket_h=60, top_th=6, lip_h=6, lip_extra=2.0){
    union(){
        ht_socket(od=od, wall=wall, h=socket_h, lip_h=lip_h, lip_extra=lip_extra, chamfer=2.0);
        translate([0,0,socket_h]) cylinder(h=top_th, d=od+2*lip_extra);
    }
}

translate([0,0,-(60+6)/2]) ht_cap(od=110, wall=3.2, socket_h=60, top_th=6, lip_h=6, lip_extra=2.0);