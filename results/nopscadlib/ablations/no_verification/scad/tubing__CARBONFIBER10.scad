// Parameters
length = 15; //[8:30:1]
outer_diameter = 10; //[5:20:0.5]
inner_diameter_original = 8; //[4:18:0.5]
forced_id = 0; //[0:18:0.5]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.5]
id_effective = (forced_id > 0 ? forced_id : inner_diameter_original); //[4:18:0.5]

// Smoothness
$fn = 128;

// Ensure valid wall thickness and non-zero wall
min_wall = 0.2;
id_safe = min(id_effective, outer_diameter - 2*min_wall);

// Tubing - complete geometry
module tubing() {
  color([0.1, 0.1, 0.1]) { // Carbon fiber color
    difference() {
      // Outer tube
      cylinder(h=length, r=outer_diameter/2, center=(center==1));

      // Inner bore: always centered so it fully cuts through regardless of center mode
      cylinder(h=length + 2*overlap, r=id_safe/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();