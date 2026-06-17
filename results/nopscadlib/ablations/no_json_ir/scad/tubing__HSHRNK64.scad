$fn = 128;

// Heatshrink sleeving parameters
inner_diameter = 5;   // ID
outer_diameter = 7;   // OD
length         = 50;  // overall length

// Small overlap to avoid coincident faces in boolean ops
eps = 0.2;

// One connected solid: a hollow tube (sleeve)
module heatshrink_sleeve() {
    difference() {
        // Outer wall
        cylinder(h = length, d = outer_diameter, center = true);

        // Inner bore (slightly longer so it fully cuts through)
        cylinder(h = length + 2*eps, d = inner_diameter, center = true);
    }
}

heatshrink_sleeve();