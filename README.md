# 6502_practice
Assembly Practice Repo for 6502/6507

# sample compilation using the DASM provided macro and vsc .h files:
dasm rainbow.asm -lrainbow.txt -f3 -v5 -orainbow.bin -Iincludes

# or when the includes files are explicitly defined:
dasm bgsquare.asm -f3 -obgsquare.rom