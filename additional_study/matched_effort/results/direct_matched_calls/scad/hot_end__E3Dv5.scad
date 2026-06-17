$fn = 96;

// Parameters
total_len = 70.0;          // mm
barrel_d = 3.7;            // mm
filament_d = 1.75;         // mm

// Simple hotend proportions (approximate, printable representation)
nozzle_len = 12.0;
heater_len = 12.0;
heatsink_len = 18.0;
barrel_len = total_len - (nozzle_len + heater_len + heatsink_len);

heater_w = 16.0;
heater_h = 16.0;

heatsink_od = 22.0;
fin_count = 8;
fin_th = 1.2;
fin_gap = (heatsink_len - fin_count * fin_th) / (fin_count - 1);

module hotend() {
  difference() {
    union() {
      // Barrel (heatbreak)
      translate([0,0,nozzle_len + heater_len])
        cylinder(h=barrel_len, d=barrel_d);

      // Heater block
      translate([-heater_w/2, -heater_h/2, nozzle_len])
        cube([heater_w, heater_h, heater_len]);

      // Heatsink core
      translate([0,0,nozzle_len + heater_len + barrel_len])
        cylinder(h=heatsink_len, d=heatsink_od * 0.55);

      // Heatsink fins
      for (i = [0:fin_count-1]) {
        z = nozzle_len + heater_len + barrel_len + i*(fin_th + fin_gap);
        translate([0,0,z])
          cylinder(h=fin_th, d=heatsink_od);
      }

      // Nozzle (simple cone + short tip)
      // Main cone
      cylinder(h=nozzle_len*0.85, d1=7.0, d2=1.2);
      // Tip
      translate([0,0,nozzle_len*0.85])
        cylinder(h=nozzle_len*0.15, d=1.2);
    }

    // Filament path through entire hotend
    translate([0,0,-0.5])
      cylinder(h=total_len + 1.0, d=filament_d);

    // Heater cartridge hole (6mm) through heater block
    translate([0, 0, nozzle_len + heater_len*0.55])
      rotate([0,90,0])
        cylinder(h=heater_w + 2.0, d=6.0, center=true);

    // Thermistor hole (3mm) through heater block
    translate([0, -heater_h*0.25, nozzle_len + heater_len*0.25])
      rotate([0,90,0])
        cylinder(h=heater_w + 2.0, d=3.0, center=true);

    // Mounting screw holes (M3 clearance) through heater block
    for (y = [-heater_h*0.25, heater_h*0.25]) {
      translate([heater_w*0.25, y, nozzle_len + heater_len*0.5])
        rotate([0,90,0])
          cylinder(h=heater_w + 2.0, d=3.4, center=true);
    }
  }
}

hotend();