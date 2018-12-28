Jellybean Guessing Game SC Series
----------------------------------

This is a 'series' of smart contracts which goes step by step in building a 'Jellybean Guessing Game' with some commentary to explain what is going on. This may end up as a full-fledged tutorial at some point, but currently I do not have the time to do so, so the minimalistic explanations will suffice for the more dedicated learner.

The game is simple; the SC owner starts the game by locking in the answer, and the player must guess the right number of jellybeans. In this 'series' several topics are covered:

- How to lock funds in a smart contract (with a DataScript attached)
- How to attempt to redeem funds from a smart contract (with a RedeemerScript attached)
- How on-chain code works/how it validates whether a collectFromScript call is valid.
- How to hash the winning number and validate the hashed guess.
- How to set up wallet triggers/handlers to automate closing the game after block #10 if the player failed to guess the answer in time.
- How to check data inputed via the UI to make sure it is valid, else throw an error.
