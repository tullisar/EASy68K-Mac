*-----------------------------------------------------------
* Program     : Modification
* Written By  :
* Date        :
* Description :
*-----------------------------------------------------------
        ORG     $1000
START:                          ; first instruction of the program

        MOVE.B  #9,D0            
        TRAP    #15             ; halt simulator

* Variables and Strings


        END     START           ; last line of source