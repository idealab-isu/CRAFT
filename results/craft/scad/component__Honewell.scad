// Honeywell 135-104LAC-J01 style radial bead thermistor (approximate geometry)
// One connected solid; all placements derived from dimensions (no arbitrary offsets)

$fn = 64;

// Parameters (mm)
bead_d = 2.2;                 //[1.1:4.4:0.1]
bead_t = 1.6;                 //[0.8:3.2:0.1]  // bead thickness (disc-like)
neck_d = 1.2;                 //[0.6:2.4:0.05] // epoxy neck around lead exits
neck_len = 1.0;               //[0.5:2.5:0.1]

lead_d = 0.5;                 //[0.25:1.0:0.05]
lead_len = 25.0;              //[12.5:50.0:0.5]
lead_pitch = 2.54;            //[1.27:5.08:0.01]

tinning_len = 3.0;            //[1.5:6.0:0.5]
tinning_d_factor = 1.15;      //[1.0:1.4:0.05]

overlap = 0.25;               //[0.1:1.0:0.05] // small overlap to guarantee manifold union

// Derived
bead_r = bead_d/2;
neck_r = neck_d/2;
lead_r = lead_d/2;

z_bead_top = bead_t/2;
z_bead_bot = -bead_t/2;

z_neck_top = z_bead_bot + overlap;                 // neck starts slightly inside bead
z_neck_bot = z_neck_top - neck_len;

z_lead_top = z_neck_bot + overlap;                 // lead starts slightly inside neck
z_lead_bot = z_lead_top - lead_len;

z_tin_top = z_lead_bot + tinning_len;              // tinning at lead tip
z_tin_center = z_lead_bot + tinning_len/2;

// Geometry
module bead_disc() {
  // Disc-like bead with slight rounding using hull of two thin cylinders
  color([0.85, 0.85, 0.8])
  hull() {
    translate([0,0, z_bead_top - 0.15])
      cylinder(r=bead_r*0.98, h=0.3, center=true);
    translate([0,0, z_bead_bot + 0.15])
      cylinder(r=bead_r*0.98, h=0.3, center=true);
  }
}

module neck_and_exit() {
  // Epoxy neck that blends from bead to lead exits (two lobes + center)
  color([0.85, 0.85, 0.8])
  hull() {
    // inside bead
    translate([0,0, z_bead_bot + overlap])
      cylinder(r=bead_r*0.75, h=overlap*2, center=true);

    // neck bottom
    translate([0,0, z_neck_bot])
      cylinder(r=neck_r, h=overlap*2, center=true);

    // lobe around each lead at neck bottom
    for (sx = [-1, 1])
      translate([sx*lead_pitch/2, 0, z_neck_bot])
        cylinder(r=max(neck_r*0.75, lead_r*1.6), h=overlap*2, center=true);
  }
}

module lead_pair() {
  color([0.2, 0.2, 0.2])
  for (sx = [-1, 1]) {
    translate([sx*lead_pitch/2, 0, (z_lead_top + z_lead_bot)/2])
      cylinder(r=lead_r, h=(z_lead_top - z_lead_bot) + overlap, center=true);
  }
}

module tinning() {
  color([0.72, 0.45, 0.2])
  for (sx = [-1, 1]) {
    translate([sx*lead_pitch/2, 0, z_tin_center])
      cylinder(r=lead_r*tinning_d_factor, h=tinning_len + overlap, center=true);
  }
}

// Final connected solid
union() {
  bead_disc();
  neck_and_exit();
  lead_pair();
  tinning();
}