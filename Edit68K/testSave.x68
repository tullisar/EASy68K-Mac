{\rtf1\ansi\ansicpg1252\cocoartf1038\cocoasubrtf350
{\fonttbl\f0\fmodern\fcharset0 Courier;}
{\colortbl;\red255\green255\blue255;}
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\ql\qnatural\pardirnatural

\f0\fs20 \cf0 *-----------------------------------------------------------\
* Program     : Modification\
* Written By  :\
* Date        :\
* Description :\
*-----------------------------------------------------------\
        ORG     $1000\
START:                          ; first instruction of the program\
\
        MOVE.B  #9,D0            \
        TRAP    #15             ; halt simulator\
\
* Variables and Strings\
\
\
        END     START           ; last line of source\
\
* Looks like font information is already saved on a per file basis, handled by the OS. Nice!}