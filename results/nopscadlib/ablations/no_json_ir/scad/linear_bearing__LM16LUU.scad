// Parameters
inner_diameter = 16.0; // Through bore diameter
outer_diameter = 28.0; // Outer diameter of the bearing
length = 70.0;         // Overall length of the bearing

// Linear bearing body
module linear_bearing_body() {
    cylinder(d=outer_diameter, h=length, center=true);
}

// Through bore
module through_bore() {
    cylinder(d=inner_diameter, h=length + 2, center=true);
}

// Linear bearing assembly
module linear_bearing() {
    difference() {
        linear_bearing_body();
        through_bore();
    }
}

// Render the linear bearing
linear_bearing();