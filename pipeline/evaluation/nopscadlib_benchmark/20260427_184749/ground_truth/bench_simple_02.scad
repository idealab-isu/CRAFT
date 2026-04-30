// M8 Flat Washer
// OD=16mm, ID=8.4mm, H=1.6mm
washer_od = 16;
washer_id = 8.4;
washer_h = 1.6;

difference() {
    cylinder(d=washer_od, h=washer_h, center=true, $fn=64);
    cylinder(d=washer_id, h=washer_h+1, center=true, $fn=64);
}
