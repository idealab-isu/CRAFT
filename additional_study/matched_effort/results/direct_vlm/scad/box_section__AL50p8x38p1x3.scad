$fn = 64;

// Aluminium rectangular box section: 50.8mm x 38.1mm x 3.0mm wall
outer_w = 50.8;   // X (mm)
outer_h = 38.1;   // Y (mm)
wall    = 3.0;    // wall thickness (mm)
length  = 100;    // Z (mm)

inner_w = outer_w - 2*wall;
inner_h = outer_h - 2*wall;

eps = 0.05;       // small overlap to guarantee clean boolean

// One connected solid: open-ended rectangular tube
difference() {
    cube([outer_w, outer_h, length], center=true);

    // Inner void: extend slightly beyond both ends so the tube is clearly hollow in top/bottom views
    cube([inner_w, inner_h, length + 2*eps], center=true);
}