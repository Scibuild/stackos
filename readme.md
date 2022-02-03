# StackOS

A very basic hobby, real mode operating system that works as a reverse polish notation calculator, somewhat Forth-like, except not turing complete. Will run on real hardware.

## Words

|--------|-----------------------------------------------|
| Number | Push a 16 bit positive integer onto the stack | 
| +      | Add top two elements on stack                 |
| -      | Subtract top two elements on stack            |
| *      | Multiply top two elements on stack            |
| div    | divide top two elements on stack              |
| swap   | `a b -- b a`                                  |
| drop   | `a -- `                                       |
| dup    | `a -- a a`                                    |
| rot    | `a b c -- b c a`                              |
| over   | `a b -- a b a`                                |
|--------|-----------------------------------------------|

