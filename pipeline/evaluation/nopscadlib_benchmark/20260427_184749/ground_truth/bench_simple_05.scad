// LM8UU Linear Bearing Holder
// LM8UU: OD=15mm, ID=8mm, L=24mm
bearing_od = 15;
bearing_id = 8;
bearing_length = 24;
wall = 3;

difference() {
    // Outer body
    cube([bearing_od + wall*2, bearing_od + wall*2, bearing_length], center=true);

    // Bearing pocket
    cylinder(d=bearing_od, h=bearing_length+1, center=true, $fn=64);

    // Through hole for shaft
    cylinder(d=bearing_id, h=bearing_length+10, center=true, $fn=64);

    // Clamping slot
    translate([0, bearing_od/2 + wall/2, 0])
        cube([2, wall+1, bearing_length+1], center=true);
}
