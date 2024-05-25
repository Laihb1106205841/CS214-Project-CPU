# CS214-Project-CPU
This is the project repository for CS214, which aims at realizing a pipeline-structured CPU. The present workflow is as follows:
## Testcase
Using Assembly code to generate testcases(stored as txt and transformed to coe files, use ROM to load into the instruction memory)

## Pipeline CPU
The pipeline CPU can be divided in the following part. 
- Instruction fetch (Ifetch)
- Instruction decode (Idecode)
- Execution (Exe)
- Memory (Dmem)
- Write Back (WBack)
All the stages are sequential, reacting to the posedge of the clock cycle. ROM in IFetch and RAM in Memory are negedge-triggered. As we have to withdraw data from the memory based on the results of calculation. However, all the data will be simultaneously transferred to the next elements at the next posedge.

## Things to do
- [ ] CPU Top Module, connecting all the components above
- [ ] Forwarding Control Unit
- [ ] Inputs and Outputs Memory and UART communication
- [ ] Possibly realize the SIMD units?
- [ ] Testing on board
