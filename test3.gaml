/**
* Name: test2
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model test2

/* Insert your model definition here */

global {

	
	int x <- 0;
	
	init {
		
		
		create participant number:3 {
			location <- {40 + x, 40};
			x <- x + 10;
		}
		
		create initiator number:1;
	}
}


species initiator skills: [fipa] {
	
	list<participant> agreedBuyers;
	
	int shirtPrice <- 800;
	int lowestPrice <- 600;
	
	reflex auction_starts when:(time = 10) {
		write "Auction is starting now";
	}
	
	//The auction starts with the initiator informing about the product
	reflex send_inform when: (time = 10) {
		do start_conversation (to :: list(participant), protocol :: 'fipa-inform', performative :: 'inform', contents :: ['T-Shirt']);
	}
	
	reflex read_inform_from_participant when: (!empty(informs)) {
		message messageInc <- (informs at 0);
		string interested_or_not <- messageInc.contents[0];
		if interested_or_not = "Interested" {
			agreedBuyers <+ messageInc.sender;
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
		draw square(5) at:{50,50} color: #red;
	}
}



species participant skills:[fipa] {
	
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
		draw triangle(5) color: #green;
	}
}




experiment main {
	output {
		display my_display type: opengl {
			species initiator aspect:base;
			species participant aspect:base;
		}
	}
}
