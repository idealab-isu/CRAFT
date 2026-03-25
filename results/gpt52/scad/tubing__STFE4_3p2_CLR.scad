$fn=96;

module tube(od=6, id=4, h=50, center=true){
    difference(){
        cylinder(d=od, h=h, center=center);
        cylinder(d=id, h=h+0.2, center=center);
    }
}

module heatshrink_sleeve(len=60, od=6, wall=0.5, flare_len=6, flare_extra=0.6){
    id = od - 2*wall;
    union(){
        tube(od=od, id=id, h=len-2*flare_len, center=true);
        translate([0,0,(len-2*flare_len)/2])
            cylinder(h=flare_len, d1=od, d2=od+flare_extra, center=false);
        translate([0,0,-(len-2*flare_len)/2 - flare_len])
            cylinder(h=flare_len, d1=od+flare_extra, d2=od, center=false);
        difference(){
            translate([0,0,(len-2*flare_len)/2])
                cylinder(h=flare_len, d1=id, d2=id+flare_extra, center=false);
            translate([0,0,(len-2*flare_len)/2])
                cylinder(h=flare_len+0.2, d1=id-0.01, d2=id+flare_extra-0.01, center=false);
        }
        difference(){
            translate([0,0,-(len-2*flare_len)/2 - flare_len])
                cylinder(h=flare_len, d1=id+flare_extra, d2=id, center=false);
            translate([0,0,-(len-2*flare_len)/2 - flare_len])
                cylinder(h=flare_len+0.2, d1=id+flare_extra-0.01, d2=id-0.01, center=false);
        }
    }
}

heatshrink_sleeve(len=80, od=6, wall=0.5, flare_len=8, flare_extra=0.8);