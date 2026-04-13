[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/d5nOy1eX)

# Computer Systems Organization Assignment 2

### Q1: Binary Search Tree (BST) in Assembly
I started by dealing with manual memory management using `malloc` to allocate the exact 24 bytes each struct node requires. Then, I mapped out the recursive logic for both the `insert` function and the standard `get` lookup.

### Q2: Next Greater Element
Since we were given inputs dynamically via command-line arguments (parsing them with `atoi`), I had to allocate dynamic arrays for the inputs, the results, and our custom stack. We utilized two pointers heavily—one looping backwards through the inputs, and one acting as our `stack_top`, popping elements that were smaller before logging the current top as the solution. 

### Q3: Reverse Engineering and Buffer Overflow

**Part A (Reverse Engineering):** Initially, this feels like an overflow challenge. However, dumping the object code and running `strings` on `.rodata` revealed that the program securely pulls a hardcoded password string and just runs a `strcmp` instead of being explicitly vulnerable.

**Part B (Buffer Overflow & Return Oriented Programming):** The second target program swapped out secure input handling for the highly vulnerable `gets()` function. We need to perform a buffer overflow to overwrite the Return Address (`ra`) pushing the instruction pointer straight into the `.pass` block.

**Calculating the Offset:** By inspecting the disassembly of `main`, the exact padding offset is derived mathematically from the compiler's stack pointer (`sp`) subtractions:
1. First, a 16-byte frame header is established (`addi sp, sp, -16`). The Return Address is safely deposited exactly 8 bytes deep into this header (`sd ra, 8(sp)`).
2. Afterwards, the local buffer meant to hold our string input is hollowed out directly below that header via `addi sp, sp, -208`.
3. Because the `gets()` array starts precisely at this new depth, we must type `208 bytes` of padding characters stringing up to the ceiling of our frame header, plus an additional `8 bytes` to precisely map into the stored `ra` location.
This definitively frames our required vulnerability padding to exactly **216 bytes** `(208 + 8)`. *(Note: Whenever different target binaries are compiled with dynamically larger arrays like `-256`, this identical logic exposes their true offset, e.g., 256 + 8 = 264 bytes).*

### Q4: Dynamic Shared Libraries
Basically, as the calculator loops through inputs, it dynamically maps the required library (like `./libadd.so`) directly into process memory precisely when it's needed, finds the target function symbol, executes the math, and immediately unloads it.

### Q5: O(1) Space Palindrome Checker
In a normal language, checking a palindrome is easy: just load the string and check if it mirrors. But we were constrained to strictly O(1) space regardless of file size (even if it's gigabytes large). I wrote an assembly loop for this. It sets two virtual pointers (at file start and size-1), physically seeks the disk reader to those offsets, pulls a single byte into a fixed 2-byte stack buffer, compares them, and repeats inwards. No memory overhead!