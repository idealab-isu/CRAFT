// GT2 20T Timing Pulley
// 20 teeth, 2mm pitch, 5mm bore
teeth = 20;
pitch = 2;
bore = 5;
belt_width = 6;
pulley_od = teeth * pitch / 3.14159;
flange_od = pulley_od + 2;

difference() {
    union() {
        // Main pulley body
        cylinder(d=pulley_od, h=belt_width+2, center=true, $fn=64);
        // Top flange
        translate([0, 0, (belt_width+2)/2 - 1])
            cylinder(d=flange_od, h=1, $fn=64);
        // Bottom flange
        translate([0, 0, -(belt_width+2)/2])
            cylinder(d=flange_od, h=1, $fn=64);
    }
    // Center bore
    cylinder(d=bore, h=belt_width+10, center=true, $fn=32);
    // Teeth profile (simplified)
    for (i = [0:teeth-1]) {
        rotate([0, 0, i * 360/teeth])
            translate([pulley_od/2, 0, 0])
                cylinder(d=1, h=belt_width+3, center=true, $fn=16);
    }
}
