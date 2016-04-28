{{
************************
* XML Get Attrib v0.1
************************
* Created by Laurent Pose
* Created 28/04/2016 (April 28, 2016)
* See end of file for terms of use.
************************
*

* v0.1  - 15/04/15 - Creation
************************

┌---------------------------------------------------------------------------------------------------┐
| This Obj finds XML attributes and put them into a list of string                                  |
| suppose you have an xml text that provides informations inside attributes like                    |
|                                                                                                   |
|                 <test>                                                                            |
|                    <Day data="Auj">                                                               |
|                    <Day data="Tom">                                                               |
|                 </test>"                                                                          |
|                                                                                                   |
|  GetXMLATTRIBs will extract all attributes values. Results are stored into an array of strings.   |
|                                                                                                   |
|  Days  = "Auj\0Tom\0"                                                                             |
|                                                                                                   |
└---------------------------------------------------------------------------------------------------┘

           ┌--> get starting position
┌───────-┐ │                                                                    ┌---> Days
│ xmltxt │-┘                                                                   │
└──────-─┘ │                     ┌--store in global value--┐  dispatch function │
           └--> ParseXMLTxt ---> |     Values_Array        │--------------------┼---> Conditions
                                 └-------------------------┘   GetXMLAttribs    │
                                                                                │
                                                                                └---> Icons

NOTE: This file uses a modified version of OBJ string. I added a string copy function

}}

CON

  _clkmode        = xtal1 + pll16x              'Use crystal * 16
  _xinfreq        = 5_000_000                   '5MHz * 16 = 80 MHz

  LENSTRING       = 80                          ' Max lenght for each extracted value
  LENDAY          = 4
  NBVALUE         = 3                           ' Look for only 3 values

  CR              = 13

VAR

  byte Values_Array[NBVALUE*LENSTRING]           ' stores NBVALUE values string

  byte TMin[NBVALUE*3]                           ' stores temperature in string
  byte TMax[NBVALUE*3]
  byte Days[NBVALUE*LENDAY]
  byte Conditions[NBVALUE*LENSTRING]
  byte Icons[NBVALUE*LENSTRING]

OBJ

  PC            : "Parallax Serial Terminal Extended"
  STR           : "Strings2.2"


Pub Main | startIdx
  PC.Start(115_200)                           ' Start Parallax Serial Terminal
  PC.Clear

  startIdx := STR.StrPos(@xmltxt,string("<forecast_conditions>"),0) ' cut the header until the forecast tag

  GetXMLAttribs (@Days,LENDAY,@xmltxt,string("day_of_week data="),startIdx)
  GetXMLAttribs (@Tmin,3,@xmltxt,string("low data="),startIdx)
  GetXMLAttribs (@Tmax,3,@xmltxt,string("high data="),startIdx)
  GetXMLAttribs (@Conditions,LENSTRING,@xmltxt,string("<condition data="),startIdx)
  GetXMLAttribs (@Icons,LENSTRING,@xmltxt,string("<icon data="),startIdx)

{  if (ParseXml_Str(@xmltxt,string("<icon data="))==true)
    repeat i from 0 to NBVALUE-1
        STR.strcopy(@Icons[i*LENSTRING],@Values_Array[i*LENSTRING],0, LENSTRING)
  else
    PC.STR(string("Icons NOT Found"))
}

  PrintAttribs

PUB PrintAttribs | i
  repeat i from 0 to NBVALUE-1
        PC.str(string(CR,CR,"Day["))
        PC.dec(i)
        PC.str(string("]="))
        PC.str(@Days[i*LENDAY])

        PC.str(string(CR,"Tmin["))
        PC.dec(i)
        PC.str(string("]="))
        PC.str(@Tmin[i*3])

        PC.str(string(CR,"Tmax["))
        PC.dec(i)
        PC.str(string("]="))
        PC.str(@Tmax[i*3])

        PC.str(string(CR,"Conditions["))
        PC.dec(i)
        PC.str(string("]="))
        PC.str(@Conditions[i*LENSTRING])

        PC.str(string(CR,"Icons["))
        PC.dec(i)
        PC.str(string("]="))
        PC.str(@Icons[i*LENSTRING])

PUB GetXMLAttribs (DestAttribs,len,ptrXML,strAttrib,startIdx):found | i
{{
Return a list of attributes from xml beginning at 'start'
PARAM:
  output:
  - DestAttribs                return list of attributes
  - return                     0 = found,  -1 = not found

  input:
  - len                        Lenght of the attributes
  - ptrXML                     xml string to look into
  - strAttrib                  field to look for
  - startIdx                    start address


Exemple
    byte Days[3]
    xmbuffer = "<test> <Day data="Auj"> <Day data="Tom"></test>"
    GetXMLAttribs (@Days,3,@xmltxt,string("day_of_week data="))

    output : Days  = "Auj\0Tom\0"
             result = 0

}}

  if (ParseXml_Str(ptrXML,strAttrib,startIdx)==true)
    repeat i from 0 to NBVALUE-1
        STR.strcopy(DestAttribs+i*len,@Values_Array[i*LENSTRING],0, len)   ' 2 possibilities of addressing
    return true
  else
    PC.STR(string(CR,CR))
    PC.Str(@strAttrib)
    PC.STR(string(" NOT Found"))
    return false

Pub ParseXml_Str (strAddr,strField,startIdx):found | i,j,k,strBuffer

{{
Return a string array containing all the values beginning at 'start'
All the values are saved into the global array : Values_Array

PARAM:
  - strAddr                     xml string to look into
  - strField                    field to look for
  - startIdx                    start address
  - found                       0 = found,  -1 = not found

Extraction is limited to NBVALUE

Exemple

    xmbuffer = "<test> <Day data="Auj"> <Day data="Tom"></test>"
    result := ParseXml_Temp (xmlbuffer,"Day data=",1)

    output : TokenAdr  = [pointer to "Day" , pointer to "Tom"]
             result = 0

}}

  i := 0                                        ' index of first quote : <field="value"/>
  j := 0                                        ' index of last  quote

  strBuffer := STR.StrStr(strAddr,strField,startIdx) ' cut the string until field (some field could have been in the header)
                                                ' we removed the header
                                                ' return false if not found
  k := 0

  repeat while (k < NBVALUE) 'or (strBuffer <> FALSE)
 ' repeat while (k<3)
    i := STR.strpos(strBuffer,string(34),0)+1   ' find letter inside 1rst quote : "->A<-uj"
    j := STR.strpos(strBuffer,string(34),i)-1   ' find last letter : "Au->j<-"

    STR.strcopy(@Values_Array[k*LENSTRING],strBuffer,i, j-i+1)

    ' prepare next loop
    strBuffer := STR.StrStr(strBuffer,strField,j)   ' cut the string until field
    k++
    ' repeat end


  ' End of function =>  result
  if (strBuffer==false) and  (k==NBVALUE)
    found := false                                   ' No field inside xml
  else
    found := true


Dat

  xmltxt      byte  "<xml_api_reply version=",34,"1",34,">"
              byte  "  <weather module_id=",34,"0",34," tab_id=",34,"0",34,">"
              byte  "      <forecast_information>"
              byte  "         <!-- Some inner tags containing data about the city found, time and unit-stuff -->"
              byte  "         <city data=",34,"Paris, FR",34,"/>"
              byte  "         <postal_code data=",34,34,"/>"
              byte  "         <latitude_e6 data=",34,34,"/>"
              byte  "         <longitude_e6 data=",34,34,"/>"
              byte  "         <forecast_date data=",34,"2016-04-11",34,"/>"
              byte  "         <current_date_time data=",34,"2016-04-11 11:11:37 +0200",34,"/>"
              byte  "         <unit_system data=",34,"fr",34,"/>"
              byte  "      </forecast_information>"
              byte  "      <current_conditions>"
              byte  "         <!-- Some inner tags containing data of current weather -->"
              byte  "         <condition data=",34,"Risque de Pluie",34,"/>"
              byte  "         <temp_f data=",34,"52",34,"/>"
              byte  "         <temp_c data=",34,"11",34,"/>"
              byte  "         <humidity data=",34,"Humidit�: 88%",34,"/>"
              byte  "         <icon data=",34,"/images/weather/chance_of_rain.gif",34,"/>"
              byte  "         <wind_condition data=",34,"Vent: SE de 7 km/h",34,"/>"
              byte  "      </current_conditions>"
              byte  "      <forecast_conditions>"
              byte  "         <!-- Some inner tags containing data about future weather -->"
              byte  "         <day_of_week data=",34,"Auj",34,"/>"
              byte  "         <low data=",34,"38",34,"/>"
              byte  "         <high data=",34,"14",34,"/>"
              byte  "         <icon data=",34,"/images/weather/rain.gif",34,"/>"
              byte  "         <condition data=",34,"Pluie  auj Fine",34,"/>"
              byte  "      </forecast_conditions>"
              byte  "      <forecast_conditions>"
              byte  "         <!-- Some inner tags containing data about future weather -->"
              byte  "         <day_of_week data=",34,"Mar",34,"/>"
              byte  "         <low data=",34,"6",34,"/>"
              byte  "         <high data=",34,"14",34,"/>"
              byte  "         <icon data=",34,"/images/weather/mist.gif",34,"/>"
              byte  "         <condition data=",34,"Pluie  mar Fine",34,"/>"
              byte  "      </forecast_conditions>"
              byte  "      <forecast_conditions>"
              byte  "         <!-- Some inner tags containing data about future weather -->"
              byte  "         <day_of_week data=",34,"Mer",34,"/>"
              byte  "         <low data=",34,"8",34,"/>"
              byte  "         <high data=",34,"16",34,"/>"
              byte  "         <icon data=",34,"/images/weather/mist.gif",34,"/>"
              byte  "         <condition data=",34,"Pluie  mer Fine",34,"/>"
              byte  "      </forecast_conditions>"
              byte  "      <forecast_conditions>"
              byte  "         <!-- Some inner tags containing data about future weather -->"
              byte  "         <day_of_week data=",34,"Jeu",34,"/>"
              byte  "         <low data=",34,"7",34,"/>"
              byte  "         <high data=",34,"14",34,"/>"
              byte  "         <icon data=",34,"/images/weather/rain.gif",34,"/>"
              byte  "         <condition data=",34,"Pluie jeu ",34,"/>"
              byte  "      </forecast_conditions>"
              byte  "    </weather>"
              byte  "</xml_api_reply>",0


{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
