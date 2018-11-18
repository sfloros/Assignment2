/**
* Name: basic
* Author: spiro
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */
global {
	point sceneloc <- {50, 0};
	point sceneloc1 <- {10, 90};
	int guest_num <- 3;
	
	int balance <- 5000;
	int minCost <- 100;
	int maxCost <- 1000;
	init{
		
		create participant number: guest_num  {
	//		location <- sceneloc1 ;
		}
		
		create auction_scene number: 2 {
			location <- sceneloc;
		}
		
		create initiator number: 1 {
			location <- sceneloc;
		}
	}
	
}
/*
 *  ******************** GLOBAL ENDS HERE ****************************
 */

/*
 *  ******************** SPECIES START HERE *************************
 */

species participant skills:[moving, fipa] {
	point target_point <- nil;
	int preferredPrice <- rnd(minCost, maxCost);
	int counter <- 100;
	int a<- 0;
	int b<- 0;


	
	
	reflex go_to_scene  {
	
		if (location distance_to sceneloc1 > 4) {
			do goto target:sceneloc1;
	}
	}
	
	
	int preferedPrice <- rnd(500, 1000);
	
	
	reflex read_informs when:(!empty(informs)) {
		message messageInc <- (informs at 0);
		string product <- string(messageInc.contents[0]);
		write (string(messageInc.sender) + " is selling: " + string(product));
		if (string(product) = "T-Shirt"){
			do start_conversation (to: list(initiator), protocol: 'fipa-inform', performative: 'inform', contents:["Interested"]);
			write name + " wants to participate";
		}
	}


	reflex do_i_propose when:(!empty(cfps)) {
		message messageInc <- (cfps at 0);
		int product_price <- int(messageInc.contents[0]);
		do propose with:(message: messageInc, contents: ["Lower it", preferedPrice]);
	}
	
	reflex read_rejected when:(!empty(reject_proposals)) {
		loop r over:reject_proposals {
			write string(r.sender) +" says to  " + name  + ": "+ string(r.contents);
		}
	}
	
	reflex read_accepted when:(!empty(accept_proposals)) {
		loop a over:accept_proposals {
			write string(a.sender) + " says to " + name  + ": "+ string(a.contents);
		}
	}

	
	aspect base {
		draw pyramid(3)at:{location.x, location.y, 0} color: #darkred;
		draw sphere(1) at:{location.x, location.y,2}color: #darkred;
		
		//x<-x +3;
		//y<-y -3;
	}
}


species initiator skills:[fipa, moving]{
	list<participant> agreedBuyers;
	
	int shirtPrice <- 800;
	int lowestPrice <- 600;
	rgb color <- #red;
	
	reflex auction_starts when:(time = 5) {
		
		write "Auction is starting in a bit";
	}
	
	
	reflex heading_to_scene when:(time >5 ) {
	if (location distance_to sceneloc1 > 4) {
			do goto target:{sceneloc1.x,sceneloc1.y-10};
		}
	
	
	}
	reflex send_inform when: (location distance_to sceneloc1 < 15) {
		do start_conversation (to :: list(participant), protocol :: 'fipa-inform', performative :: 'inform', contents :: ['T-Shirt']);
	}
		reflex read_inform_from_participant when: (!empty(informs)) {

		write 'Auctioneer: read_agree_message';
		
		loop a over: informs{
			
			if(a.contents=['I accept']){
				add a.sender to: agreedBuyers;
			}
			write ''+ a.sender+ ' added to list of interested buyers: '; 
		}
	}
	
		reflex send_price_to_list when:(!empty(agreedBuyers)) {
		do start_conversation (to: list(agreedBuyers), protocol: 'fipa-contract-net', performative: 'cfp', contents: [shirtPrice] );
	}
	
	reflex accept_reject_proposes when:(!empty(proposes)) {
		message messageInc <- (proposes at 0);
		int price <- int(messageInc.contents[1]);
		if( price < lowestPrice) {
			do reject_proposal (message: messageInc, contents:["Can't go any lower"]);
		}
		else if(price > lowestPrice) {
			int newPrice <- 700;
			do accept_proposal (message: messageInc, contents:["New price: " + newPrice]);
		}
	}
	


	
	aspect base {
		draw pyramid(3)at:{location.x, location.y, 0} color: #blue;
		draw sphere(1) at:{location.x, location.y,2}color: #blue;
	}
}

species auction_scene {
	
	rgb color <- #green;
	
	aspect base {
		draw circle(6) color: #green;
		draw square(15)at:sceneloc1 color: #red;
	}
	
}

/*
 *  *************************** SPECIES END HERE **************************
 */

experiment main {
	
	output {
		
		display map type: opengl {
			species participant aspect: base;
			species initiator aspect: base;
			species auction_scene aspect: base;
		}
	}
}

