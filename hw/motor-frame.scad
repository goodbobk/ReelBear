motor_d = 35;
wall_t = 2;
wall_h = 18;
base_h = 5;
base_d= 1.2 * sqrt(2) * motor_d;

sucker_neck_d = 9;
sucker_slot_d = 8;
sucker_neck_h = 3.2;
sucker_head_d = 15;

sucker_pos = 8;
e = 0.1;
e2 = 2*e;

module oval_hole(z_off, h,d,s) {
                translate([0,0,z_off + h/2]) {
                hull() {
                    cylinder(d=d, center=true, h=h);
                    translate([ d, d, 0]) {
                        cylinder(d=d, center=true, h=h);
                    }
                }
               
            }

        }
module sucker_hole() {
    // translate to sucker vertical axis
    offset = base_d/2 - sucker_pos;
    translate([offset,offset,0]) {
        union() {
            // space for the sucker head
            oval_hole(sucker_neck_h, base_h - sucker_neck_h + e, sucker_head_d, sucker_head_d);
            // sucker neck hole & slot
            translate([0,0,-e]) {
                // hole
                cylinder(d=sucker_neck_d, h=sucker_neck_h+e2, center=false);
                // slot
                rotate(a=45) {
                    translate([0,-sucker_slot_d/2,0]) {
                        cube(size=[100,sucker_slot_d,sucker_neck_h+e2]);
                    }
                }
            }
        }
    }
}

module base() {
    difference() {
        translate([0,0,base_h/2]) {
            cube(center = true, 
                size=[base_d, base_d,base_h]);
        }
        for(x=[0:90:270]) {
            rotate (a=x) {
                sucker_hole();
            }
        }
    }
}

module walls() {
    wall_size = motor_d + 2*wall_t;

    translate([0,0,wall_h/2]) {
        cube(center = true, 
             size=[wall_size, wall_size, wall_h]);
    }    
}

module motor_hole() {
    translate([0,0,wall_h/2]) {
        cube(center = true, 
             size=[motor_d, motor_d, wall_h+e2]);
    }        
}

difference() {
    union() {
        walls();
        rotate(a=45) {
            base();
        }
        
    }
    motor_hole();
}
    

