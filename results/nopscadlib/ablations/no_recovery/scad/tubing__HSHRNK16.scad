// Parameters
tubing_type = 0; //[0:3:1]
length = 15; //[7.5:30:0.5]
forced_id = 0; //[0:10:0.1]
center = 1; //[0:1:1]
eps = 0.8; //[0.5:2:0.1]
preset_id_0 = 1.6; //[0.8:3.2:0.1]
preset_od_0 = 2.4; //[1.2:4.8:0.1]
preset_id_1 = 2.4; //[1.2:4.8:0.1]
preset_od_1 = 3.2; //[1.6:6.4:0.1]
preset_id_2 = 3.2; //[1.6:6.4:0.1]
preset_od_2 = 4.8; //[2.4:9.6:0.1]
preset_id_3 = 4.8; //[2.4:9.6:0.1]
preset_od_3 = 6.4; //[3.2:12.8:0.1]

// Tubing module
module tubing() {
  // Calculate diameters based on tubing type and forced ID
  original_id = (forced_id > 0) ? forced_id : 
                (tubing_type == 0 ? preset_id_0 : 
                (tubing_type == 1 ? preset_id_1 : 
                (tubing_type == 2 ? preset_id_2 : preset_id_3)));
  original_od = (tubing_type == 0 ? preset_od_0 : 
                (tubing_type == 1 ? preset_od_1 : 
                (tubing_type == 2 ? preset_od_2 : preset_od_3)));
  id = original_id;
  od = original_od + (id - original_id);

  // Outer tubing
  color([0.85, 0.85, 0.8]) {
    difference() {
      translate([0, 0, (center == 1 ? 0 : length / 2)]) 
        cylinder(h=length, r=od / 2, center=true);
      // Inner tubing
      translate([0, 0, (center == 1 ? 0 : length / 2)]) 
        cylinder(h=length + 2 * eps, r=id / 2, center=true);
    }
  }
}

// Sleeved Resistor module
module sleeved_resistor() {
  bare_length = 5;
  resistor_diameter = 2;

  color([0.2, 0.2, 0.2]) {
    translate([0, 0, (center == 1 ? 0 : bare_length / 2)]) 
      cylinder(h=bare_length, r=resistor_diameter / 2, center=true);
  }
}

// Assembly module
module assembly() {
  tubing();
  translate([0, 0, length / 2 + 2.5]) sleeved_resistor();
}

// Call the assembly
assembly();