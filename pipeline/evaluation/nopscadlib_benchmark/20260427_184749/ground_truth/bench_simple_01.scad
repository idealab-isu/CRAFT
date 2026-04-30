// 608 Ball Bearing (skateboard bearing)
// OD=22mm, ID=8mm, H=7mm
bearing_od = 22;
bearing_id = 8;
bearing_h = 7;

difference() {
    // Outer race
    cylinder(d=bearing_od, h=bearing_h, center=true, $fn=64);
    // Inner bore
    cylinder(d=bearing_id, h=bearing_h+1, center=true, $fn=64);
}
