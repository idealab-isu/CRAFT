// Heatshrink sleeving / tubing (single connected solid)

// Parameters
length = 15; //[8:30:1]
center = true; //[0:1:1]
forced_id = 0; //[0:10:1]
type_selector = 1; //[1:3:1]
default_id_t1 = 2.0; //[1.0:4.0:0.1]
default_od_t1 = 3.2; //[1.6:6.4:0.1]
default_id_t2 = 3.0; //[1.5:6.0:0.1]
default_od_t2 = 4.8; //[2.4:9.6:0.1]
default_id_t3 = 4.0; //[2.0:8.0:0.1]
default_od_t3 = 6.4; //[3.2:12.8:0.1]
eps_overlap = 1.0; //[0.5:2.0:0.1]

// Resolution
$fn = 96;

// Derived dimensions
id_sel = (forced_id > 0) ? forced_id :
         (type_selector==1 ? default_id_t1 :
          (type_selector==2 ? default_id_t2 : default_id_t3));

od_sel = (type_selector==1 ? default_od_t1 :
          (type_selector==2 ? default_od_t2 : default_od_t3));

inner_r = id_sel/2;
outer_r = od_sel/2;

// Ensure valid wall thickness
min_wall = 0.25;
outer_r_safe = max(outer_r, inner_r + min_wall);

// One connected solid: a hollow cylindrical sleeve (heatshrink tubing)
module heatshrink_sleeve() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(r=outer_r_safe, h=length, center=center);
    cylinder(r=inner_r, h=length + 2*eps_overlap, center=center);
  }
}

heatshrink_sleeve();