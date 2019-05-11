{ ============================================
  Software Name : 	OLED Library
  ============================================ }
{ ******************************************** }
{ Written By WalWalWalides                     }
{ CopyRight � 2019                             }
{ Email : WalWalWalides@gmail.com              }
{ GitHub :https://github.com/walwalwalides     }
{ ******************************************** }
unit UOLEDBitmaps;

interface

uses
  Winapi.Windows, System.SysUtils,  System.Classes, Vcl.Graphics, Vcl.Imaging.pngimage;

(* DON'T REMOVE THIS IT IS NEEDED BY RESOURCE CREATER RH: EBITMAPS *)
type  eBitmaps = (Bmpdunebutton,Bmpduneosc,BmpRMC7Led,BmpRMCButton,BmpRMCFoot4,BmpRMCKnob,BmpRMCKnob2,BmpRMCVAFoot,BmpRMCVAFOOT4,BmpRMCVAKnob,BmpRMCVALFO,
          BmpRMCVALFO1,BmpRMCVALFO2,BmpRMCVALFOSEL,BmpRMCVAWave,BmpRMCVAWave4,BmpRMCWave,BmpRolandHSlider,BmpRolandKnob,BmpRolandVSlider,BmpSliderHorBot,
          BmpSliderHorUpp,BmpSliderVerBot,BmpSliderVerUpp,BmpSunriseButFull,BmpSunriseButOff,BmpSunriseButOn,BmpSunriseKnob,BmpSunriseLedOff,BmpSunriseLedOn,
          BmpSunriseNoise,BmpSunriseSaw,BmpSunriseSin,BmpSunriseSlider,BmpSunriseSliderKnob,BmpSunriseSquare,BmpSunriseTri,BmpTRANBUTTON0,BmpTRANBUTTON1

);
(* DON'T REMOVE THIS IT IS NEEDED BY RESOURCE CREATER RH: _EBITMAPS *)

function getBitmap(e:eBitmaps):TBitmap;
function getRotKnob(value:integer):TPngImage;

implementation

VAR   RMCBitmapsBmp : array [eBitmaps] of TBitmap;
(* DON'T REMOVE THIS IT IS NEEDED BY RESOURCE CREATER RH: RMCBITMAPS *)
const RMCBitmapNames : array[eBitmaps] of string =('DUNEBUTTON','DUNEOSC','RMC7LED','RMCBUTTON','RMCFOOT4','RMCKNOB','RMCKNOB2','RMCVAFOOT','RMCVAFOOT4',
          'RMCVAKNOB','RMCVALFO','RMCVALFO1','RMCVALFO2','RMCVALFOSEL','RMCVAWAVE','RMCVAWAVE4','RMCWAVE','ROLANDHSLIDER','ROLANDKNOB','ROLANDVSLIDER',
          'SLIDERHORBOT','SLIDERHORUPP','SLIDERVERBOT','SLIDERVERUPP','SUNRISEBUTFULL','SUNRISEBUTOFF','SUNRISEBUTON','SUNRISEKNOB','SUNRISELEDOFF',
          'SUNRISELEDON','SUNRISENOISE','SUNRISESAW','SUNRISESIN','SUNRISESLIDER','SUNRISESLIDERKNOB','SUNRISESQUARE','SUNRISETRI','TRANBUTTON0','TRANBUTTON1'
);
(* DON'T REMOVE THIS IT IS NEEDED BY RESOURCE CREATER RH: _RMCBITMAPS *)


function getBitmap(e:eBitmaps):TBitmap;
begin
  if RMCBitmapsBmp[e]<>NIL then result:=RMCBitmapsBmp[e]
  else
  begin
     RMCBitmapsBmp[e]:=TBitmap.Create;
     RMCBitmapsBmp[e].LoadFromResourceName(HInstance, RMCBitmapNames[e]);
     result:=RMCBitmapsBmp[e];
  end
end;


function ThreeStr(n:integer):string;
begin
  result:=inttostr(n);
  if n<10 then result:='00'+result
  else if n<100 then result:='0'+result;
end;
VAR pngs:array[0..100] of TPngImage;
function getRotKnob(value:integer):TPngImage;
begin
  if (value>127) then value:=127;
  if (value<0) then value:=0;
  value:=round(100*value/127);
  if pngs[value]=NIL then
  begin
    pngs[value]:=TPngImage.Create;
    pngs[value].LoadFromResourceName(HInstance,'SP_ROT_'+ThreeStr(value));
  end;
  result:=pngs[value];
end;



end.
