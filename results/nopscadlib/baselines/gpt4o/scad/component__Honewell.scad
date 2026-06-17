module thermistor_honeywell() {
    // Main body of the thermistor
    cylinder(h=5, d=2.5, $fn=64);

    // Leads of the thermistor
    translate([0, 0, -10])
        cylinder(h=10, d=0.5, $fn=32);

    translate([0, 0, 5])
        cylinder(h=10, d=0.5, $fn=32);
}

thermistor_honeywell();