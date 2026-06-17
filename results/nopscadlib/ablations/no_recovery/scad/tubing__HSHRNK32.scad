// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = true; //[0:1:1]
default_id = 2.5; //[1.25:5:0.1]
default_od = 4; //[2:8:0.1]
eps_overlap = 1; //[0.5:2:0.1]
res_body_d = 6; //[3:12:0.1]
res_body_l = 12; //[6:24:0.1]
lead_d = 0.6; //[0.3:1.2:0.05]
lead_total_l = 30; //[15:60:1]
bare_lead_l = 5; //[2:15:1]
sleeving_id = 1.2; //[0.8:3:0.1]
sleeving_od = 2; //[1.2:4:0.1]

// Tubing - complete detailed geometry
module tubing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(h=length, r=((forced_id>0)?(default_od + forced_id - default_id):default_od)/2, center=center);
      translate([0, 0, -eps_overlap])
        cylinder(h=length + 2*eps_overlap, r=((forced_id>0)?forced_id:default_id)/2, center=center);
    }
  }
}

// Sleeved Resistor - complete detailed geometry
module sleeved_resistor() {
  color("DimGray") {
    // Resistor body
    rotate([0, 90, 0])
      cylinder(h=res_body_l, r=res_body_d/2, center=center);
    
    // Leads
    translate([-(res_body_l/2 + lead_total_l/2 - eps_overlap), 0, 0])
      rotate([0, 90, 0])
      cylinder(h=lead_total_l, r=lead_d/2, center=center);
    translate([(res_body_l/2 + lead_total_l/2 - eps_overlap), 0, 0])
      rotate([0, 90, 0])
      cylinder(h=lead_total_l, r=lead_d/2, center=center);
    
    // Sleeving
    color([0.85, 0.85, 0.8]) {
      difference() {
        translate([-(res_body_l/2 + (lead_total_l - bare_lead_l)/2 - eps_overlap), 0, 0])
          rotate([0, 90, 0])
          cylinder(h=(lead_total_l - bare_lead_l), r=sleeving_od/2, center=center);
        translate([-(res_body_l/2 + (lead_total_l - bare_lead_l)/2 - eps_overlap), 0, 0])
          rotate([0, 90, 0])
          cylinder(h=(lead_total_l - bare_lead_l) + 2*eps_overlap, r=sleeving_id/2, center=center);
      }
      difference() {
        translate([(res_body_l/2 + (lead_total_l - bare_lead_l)/2 - eps_overlap), 0, 0])
          rotate([0, 90, 0])
          cylinder(h=(lead_total_l - bare_lead_l), r=sleeving_od/2, center=center);
        translate([(res_body_l/2 + (lead_total_l - bare_lead_l)/2 - eps_overlap), 0, 0])
          rotate([0, 90, 0])
          cylinder(h=(lead_total_l - bare_lead_l) + 2*eps_overlap, r=sleeving_id/2, center=center);
      }
    }
  }
}

// Assembly
module assembly() {
  tubing();
  sleeved_resistor();
}

assembly();