/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/*
 *  ******************** GLOBAL STARTS HERE ***********************
 */
global {
	point exit_loc <- {50, 0};
	point guest_loc <- {15, 90};
	int guest_num <- 5;
	int balance <- 5000;
	int minCost <- 100;
	int maxCost <- 1000;
	
	init{
		
		create guest number: guest_num; 
		
		create exit number: 2 {
			location <- exit_loc;
		}
		
		create auctioneer number: 1 {
			location <- exit_loc;
		}
		
		create scene number: 1 {
			location <- guest_loc;
		}
	}
	
}
/*
 *  ******************** GLOBAL ENDS HERE ****************************
 */

/*
 *  ******************** SPECIES START HERE *************************
 */

species guest skills:[moving, fipa] {
	point target_point <- nil;
	int preferredPrice <- rnd(minCost, maxCost);
	int counter <- 100;
	bool interested <- flip(0.5);

	
	reflex do_wander when: (counter > 0) {
		do wander;
		counter <- counter - 1;
	}
	
	reflex go_to_scene when: (counter = 0) {
		do goto target: guest_loc;
	}
	
	reflex read_inform when: (!empty(informs)) {
		loop i over: informs {
			write name + string(i.contents);
		}
	}
	
	reflex read_cfp_1 when :(!empty(cfps)) {
		loop c over: cfps {
			write string(c.contents);
		}
	}
	
	reflex propose when:(interested) {
		do start_conversation with: [ to :: [auctioneer],  protocol :: 'fipa-propose',  performative :: 'propose',  contents :: [120] ]; 
	}
	
//	reflex reply_message when: (!empty(requests)) {
//		message requestFromAuctioneer <- (requests at 0);
//		if(preferredPrice > 500) {
//			do agree with: (message: requestFromAuctioneer, contents:[name + ' I will']);
//		}
//		else {
//			do failure with: (message: requestFromAuctioneer, contents: [name + ' I reject, sorry not sorry']);
//		}
//	}
	
	aspect base {
		draw pyramid(3) at: {location.x, location.y, 0} color: #darkred ;
		draw sphere(1) at: {location.x, location.y, 3} color: #darkred;
	}
}


species auctioneer skills:[fipa, moving]{

	bool at_scene <- false;
	
	reflex auction_starting when: (time = 99) {
		//write "Auction starts in 10 minutes";
	}
	
	reflex go_to_scene when:(time >= 109) {
		do goto target: guest_loc + {18, -18};
		if(location  = guest_loc + {18, -18}){
			at_scene <- true;
		}
	}
	
	reflex start_auction when: (at_scene) {
		//write "Auction is starting now";
	}
	
	reflex send_inform when: (at_scene) {
		loop i from:0 to:guest_num-1 {
			guest g <- guest at i;
			//write(name + " sends inform message");
			do start_conversation (to :: [g], protocol :: 'fipa-inform', performative :: 'inform', contents :: ['start of auction'] );
		}
	}

	reflex send_cfp_1 when:(time > 260) {
		loop i from: 0 to: guest_num - 1 {
			guest g <- guest at i;
			do start_conversation (to :: [g], protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['Selling signed T-Shirt']);
		}
	}
	
	reflex read_interested when:(!empty(proposes)) {
		loop p over: proposes {
			write p.contents;
		}
	}
	
	
	

	
	aspect base {
		draw pyramid(3) color: #cyan;
	}
}

species exit {
	
	rgb color <- #green;
	
	aspect base {
		draw circle(6) color: color;
	}
	
}

species scene {
	aspect base {
		draw square(18) color: #darkred;
	}
}

/*
 *  *************************** SPECIES END HERE **************************
 */

experiment main {
	
	output {
		
		display map type: opengl {
			species guest aspect: base;
			species auctioneer aspect: base;
			species exit aspect: base;
			species scene aspect: base;
		}
	}
}
