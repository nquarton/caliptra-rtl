# SHA512
Date: 28-06-2023
Author: LUBIS EDA

## Folder Structure
The following subdirectories are part of the main directory **formal**

- model: Contains the high level abstracted model 
- properties: Contains the assertion IP(AIP) named as **fv_sha512.sv** and the constraints in place for the respective AIP **fv_constraints.sv**


## DUT Overview

The DUT sha512_core has the primary inputs and primary outputs as shown below.

| S.No | Port              | Direction | Description                                                                       |
| ---- | ----------------- | --------- | --------------------------------------------------------------------------------- |
| 1    | clk               | input     | The positive edge of the clk is used for all the signals                          |
| 2    | reset_n           | input     | The reset signal is active low and resets the core                                |
| 3    | zeroize           | input     | The core is reseted when this signal is triggered.                               |
| 4    | init              | input     | The core is initialised with respective mode constants and processes the message. |
| 5    | next              | input     | The core processes the message block with the previously computed results         |
| 6    | mode[1:0]         | input     | Define which hash function: SHA512,SHA384,SHA224,SHA256                           |
| 7    | block_msg[1023:0] | input     | The padded block message                                                          |
| 8    | ready             | output    | When triggered indicates that the core is ready                                      |
| 9    | digest[511:0]     | output    | The hashed value of the given message block                                       |
| 10   | digest_valid      | output    | When triggered indicates that the computed digest is ready                        |

When the respective mode is selected and initalised the core iterates for 80 rounds to process the hash value, if the next is triggered then the previous values of the **H** registers are in place for processing the hash value. The digest is always generated of 512 bits, in which if the mode changes to 384 then from MSB 384 bits is a valid output and rest is garbage value.
## Assertion IP Overview

The Assertion IP signals are bound with the respective signals in the dut, where for the **rst** reset_n && !zeroize is used, which ensures the reset functionality. And another AIP signal block_in_valid is triggered whenever the init or next is high.

- reset_a: Checks that all the resgiters are resetted and the state is idle, with the ready to high.

- DONE_to_IDLE_a: Checks the necessary registers,outputs holds the values when state transits from Done to idle, 

- IDLE_to_SHA_Rounds_a: Checks if the state is in idle ,the mode choosen as 224,the init is triggered then the registers should be initialised with the respective constants of 224.

- IDLE_to_SHA_Rounds_1_a: Checks if the state is in idle ,the mode choosen as 256,the init is triggered then the registers should be initialised with the respective constants of 256.

- IDLE_to_SHA_Rounds_2_a: Checks if the state is in idle ,the mode choosen as 512,the init is triggered then the registers should be initialised with the respective constants of 512.

- IDLE_to_SHA_Rounds_3_a: Checks if the state is in idle ,the mode choosen is neither 512,256 nor 224,the init is triggered then the registers should be initialised with the respective constants of default, which covers 384 mode also.

- IDLE_to_SHA_Rounds_4_a: Checks if the state is in idle and there is no init signal and the next signal asserts then the register holds the past values.

- SHA_Rounds_to_DONE_a: Checks if the rounds are done then the registers are updated correctly.

- SHA_Rounds_to_SHA_Rounds_a: Checks if the the rounds less than 16 then the necessary registers are updated correctly and the round increments.

- SHA_Rounds_to_SHA_Rounds_1_a: Checks if the rounds are greater than 16 and less than 80 then the respective registers are updated correctly and the round increments.

- IDLE_wait_a: Checks if there isn't either init or next signal triggered in idle state then the state stays in idle and holds the past values and the core is ready.
- 
## Loading the AIP


For onespin:<br>
    1. Open onespin, select file, run source.<br>
    2. Select the prove.tcl in onespin folder for running the properties. <br>

For VCformal:<br>
    1. Navigate to the vcf folder containing tcl scripts.<br>
    2. open terminal <br>
    3. run the cmd vcf -f  prove.tcl (for running the properties).<br>

For JasperGold: 
    1. Open Jaspergold, click on file ->  Tcl scripts -> Source.<br>
    2. Now Navigate to the script location and select the prove.tcl.<br>
    3. All the checkers and constraints would be loaded to the interface, right click on them and click on prove task.<br>

