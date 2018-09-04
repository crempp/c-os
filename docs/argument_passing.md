# Assembly Argument Passing

The registers used to pass arguments to a function are AX, BX, CX and DX. The following algorithm describes how arguments are passed to functions.

Initially, we have the following registers available for passing arguments: **AX, DX, BX and CX**. Note that registers are selected from this list in the order they appear. That is, the first register selected is AX and the
last is CX. For each argument Ai, starting with the left most argument, perform the following steps.

1. If the size of Ai is 1 byte, convert it to 2 bytes and proceed to the next step. If Ai is of type "unsigned char", it is converted to an "unsigned int". If Ai is of type "signed char", it is converted to a "signed int". If Ai is a 1-byte structure, the padding is determined by the compiler.
2. If an argument has already been assigned a position on the stack, Ai will also be assigned a position on the stack. Otherwise, proceed to the next step.
3. If the size of Ai is 2 bytes, select a register from the list of available registers. If a register is available, Ai is assigned that register. The register is then removed from the list of available registers. If no registers are available, Ai will be assigned a position on the stack.
4. If the size of Ai is 4 bytes, select a register pair from the following list of combinations: [DX AX] or [CX BX]. The first available register pair is assigned to Ai and removed from the list of available pairs. The high-order 16 bits of the argument are assigned to the first register in the pair; the low-order 16 bits are assigned to the second register in the pair. If none of the above register pairs is available, Ai will be assigned a position on the stack.
5. If the type of Ai is "double" or "float" (in the absence of a function prototype), select [AX BX CX DX] from the list of available registers. All four registers are removed from the list of available registers. The high-order 16 bits of the argument are assigned to the first register and the low-order 16 bits are assigned to the fourth register. If any of the four registers is not available, Ai will be assigned a position on the stack.
6. All other arguments will be assigned a position on the stack.

*Notes:*
1. Arguments that are assigned a position on the stack are padded to a multiple of 2 bytes. That is, if a 3-byte structure is assigned a position on the stack, 4 bytes will be pushed on the stack.
2. Arguments that are assigned a position on the stack are pushed onto the stack starting with the rightmost argument.


## Sizes of Predefined Types
The following table lists the predefined types, their size as returned by the "sizeof" function, the size of an argument of that type and the registers used to pass that argument if it was the only argument in the argument list.

| Basic Type   | "sizeof" | Argument Size | Registers Used |
|--------------|----------|---------------|----------------|
| char         | 1        | 2             | [AX]           |
| short int    | 2        | 2             | [AX]           |
| int          | 2        | 2             | [AX]           |
| long int     | 4        | 4             | [DX AX]        |
| float        | 4        | 8             | [AX BX CX DX]  |
| double       | 8        | 8             | [AX BX CX DX]  |
| near pointer | 2        | 2             | [AX]           |
| far pointer  | 4        | 4             | [DX AX]        |
| huge pointer | 4        | 4             | [DX AX]        |

*Note that the size of the argument listed in the table assumes that no function prototypes are specified.*
Function prototypes affect the way arguments are passed. This will be discussed in the section entitled "Effect of Function Prototypes on Arguments".

*Notes:*
1. Provided no function prototypes exist, an argument will be converted to a default type as described in the following table.

| Argument Type | Passed As    |
|---------------|--------------|
| char          | unsigned int |
| signed char   | signed int   |
| unsigned char | unsigned int |
| float         | double       |

## Returning values

1. 1-byte values are to be returned in register AL.
2. 2-byte values are to be returned in register AX.
3. 4-byte values are to be returned in registers DX and AX with the most significant word in register DX.
4. 8-byte values, except structures, are to be returned in registers AX, BX, CX and DX with the most significant word in register AX.
5. Otherwise, the caller allocates space on the stack for the return value and sets register SI to point to this area. In a big data model, register SI contains an offset relative to the segment value in segment register SS.
