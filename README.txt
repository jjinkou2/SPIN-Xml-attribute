SPIN-Xml-attribute
------------------

This Obj finds XML attributes and put them into a list of string 

┌-----------------------------------------------------------------------------------┐
| This Obj finds XML attributes and put them into a list of string                  |
| suppose you have an xml text that provides informations inside attributes like    |
|                                                                                   |
|                 <test>                                                            |
|                    <Day data="Auj">                                               |
|                    <Day data="Tom">                                               |
|                 </test>"                                                          |
|                                                                                   |
|  GetXMLATTRIBs will extract all attributes values. Results are stored into        |
|  an array of strings.                                                             |
|                                                                                   |
|  Days  = "Auj\0Tom\0"                                                             |
|                                                                                   |
└-----------------------------------------------------------------------------------┘

           ┌--> get starting position
┌───────-┐ │                                                                    ┌---> Days
│ xmltxt │-┘         |                                                          │
└──────-─┘ │                     ┌--store in global value--┐  dispatch function │
           └--> ParseXMLTxt ---> |     Values_Array        │--------------------┼---> Conditions
                                 └-------------------------┘   GetXMLAttribs    │
                                                                                │
                                                                                └---> Icons

NOTE: This file uses a modified version of OBJ string. I added a string copy function
