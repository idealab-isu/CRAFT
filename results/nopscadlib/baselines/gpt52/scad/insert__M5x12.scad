$fn=96;

od = 12.0;
len = 10.0;
screw_d = 5.0;

insert_id = 6.0;
insert_id_taper = 0.4;

knurl_depth = 0.6;
knurl_count = 36;

lead_in = 1.0;
lead_out = 0.8;

module knurl_cutouts(od, len, depth, count){
    for(i = [0:count-1]){
        rotate([0,0, i*360/count])
            translate([od/2 - depth/2, 0, 0])
                cube([depth, 1.2, len+0.4], center=true);
    }
}

module heat_set_insert(od, len, id, id_taper){
    difference(){
        union(){
            cylinder(d=od, h=len, center=true);
        }
        union(){
            cylinder(d1=id+id_taper, d2=id-id_taper, h=len+0.6, center=true);
            translate([0,0, len/2 - lead_in/2])
                cylinder(d1=id+1.2, d2=id, h=lead_in+0.2, center=true);
            translate([0,0, -len/2 + lead_out/2])
                cylinder(d1=id, d2=id+0.8, h=lead_out+0.2, center=true);
            knurl_cutouts(od=od, len=len, depth=knurl_depth, count=knurl_count);
        }
    }
}

heat_set_insert(od=od, len=len, id=insert_id, id_taper=insert_id_taper);