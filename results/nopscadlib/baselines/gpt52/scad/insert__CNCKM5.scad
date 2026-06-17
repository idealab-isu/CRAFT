$fn=96;

od = 5.8;
len = 7.1;

bore_d = 5.0;
bore_clear = 0.25;
bore = bore_d + bore_clear;

knurl_depth = 0.25;
knurl_pitch = 0.9;
knurl_twist = 22;

chamfer_h = 0.6;
chamfer_d = 1.0;

module knurled_shell(od, len, depth, pitch, twist_deg){
    intersection(){
        cylinder(d=od, h=len, center=true);
        union(){
            for(z=[-len/2 : pitch : len/2]){
                translate([0,0,z])
                    rotate([0,0,twist_deg*(z/len)*360])
                        cylinder(d=od-2*depth, h=pitch*1.2, center=true, $fn=96);
            }
        }
    }
}

module insert_body(){
    difference(){
        union(){
            knurled_shell(od=od, len=len, depth=knurl_depth, pitch=knurl_pitch, twist_deg=knurl_twist);
            translate([0,0,len/2 - chamfer_h/2])
                cylinder(d1=od, d2=od-chamfer_d, h=chamfer_h, center=true);
            translate([0,0,-len/2 + chamfer_h/2])
                cylinder(d1=od-chamfer_d, d2=od, h=chamfer_h, center=true);
        }
        cylinder(d=bore, h=len+2, center=true, $fn=96);
    }
}

insert_body();