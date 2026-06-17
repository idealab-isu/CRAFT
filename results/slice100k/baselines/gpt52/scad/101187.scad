$fn=96;

plate_L = 114.0;
plate_W = 59.5;
plate_T = 0.8;

slot_len = 22.0;
slot_wid = 8.0;

edge_x = 10.0;
edge_y = 8.0;

module obround2d(len, wid){
    r = wid/2;
    hull(){
        translate([-(len/2 - r), 0]) circle(r=r);
        translate([ (len/2 - r), 0]) circle(r=r);
    }
}

module plate_with_slot(){
    difference(){
        translate([0,0,0]) cube([plate_L, plate_W, plate_T], center=true);
        translate([-(plate_L/2 - edge_x - slot_len/2), (plate_W/2 - edge_y - slot_wid/2), 0])
            linear_extrude(height=plate_T+2, center=true)
                obround2d(slot_len, slot_wid);
    }
}

plate_with_slot();