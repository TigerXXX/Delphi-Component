{ ============================================
  Software Name : 	OLED Library
  ============================================ }
{ ******************************************** }
{ Written By WalWalWalides                     }
{ CopyRight � 2019                             }
{ Email : WalWalWalides@gmail.com              }
{ GitHub :https://github.com/walwalwalides     }
{ ******************************************** }

unit UOLED7Segment;

interface

uses System.Classes, Vcl.Controls, Types,Vcl.Graphics;

type TDrawExFormat = (deValue,deNegValue,deWaveValue,deTextValue);

procedure Draw7Segment(Canvas:TCanvas;x,y,value:integer;DrawBorder,DrawNegative:boolean);
procedure Draw7SegmentEx(Canvas: TCanvas; r: TRect; Text: string; value: integer; format:TDrawExFormat;formatText:string='');


implementation

uses UOLEDBitmaps;

procedure Draw7Segment(Canvas:TCanvas;x,y,value:integer;DrawBorder,DrawNegative:boolean);
  procedure Line(x1,y1,x2,y2:integer);
  begin
    with Canvas do
    begin
      if x1=x2 then
      begin
        MoveTo(x+2*x1,y+2*y1);
        LineTo(x+2*x1,y+2*(y2+1));
        MoveTo(x+2*x1+1,y+2*y1);
        LineTo(x+2*x1+1,y+2*(y2+1));
      end
      else
      begin
        MoveTo(x+2*x1,y+2*y1);
        LineTo(x+2*(x2+1),y+2*y1);
        MoveTo(x+2*x1,y+2*y1+1);
        LineTo(x+2*(x2+1),y+2*y1+1);
      end;
    end;
  end;
  procedure DrawSegment(index,seg:integer;bright:boolean);
  VAR x1,y1,x2,y2:integer;
    procedure DefLine(ax1,ay1,ax2,ay2:integer);
    begin
      x1:=ax1; y1:=ay1; x2:=ax2; y2:=ay2;
    end;
  begin
    case seg of
      0: DefLine(1,0,3,0);
      1: DefLine(0,1,0,2);
      3: DefLine(1,3,3,3);
      4: DefLine(0,4,0,5);
      6: DefLine(1,6,3,6);
      2: DefLine(4,1,4,2);
      5: DEfLine(4,4,4,5);
    end;
    x1:=x1+6*index;
    x2:=x2+6*index;
    with Canvas do
    if bright then Pen.Color:=$FFFF00 else Pen.Color:=$6F6F25;
    Line(x1,y1,x2,y2);
  end;
  procedure DrawNumber(index,value:integer);
  const map:array[0..11] of integer = (119,36,93,109,46,107,123,39,127,111,0,8);
  VAR i:integer;
  begin
    for i:=0 to 6 do
      DrawSegment(index,i,map[value] and (1 SHL i) <>0);
  end;

VAR r:TRect;
    xoff:integer;
    bm:TBitmap;
begin
  with Canvas do
  begin
    xoff:=12*ord(DrawNegative);
    r:=Rect(x+xoff,y,x+53-xoff,y+33);
    bm:=getBitmap(BmpOLED7Led);
    bm.transparent:=true;
    if DrawBorder then StretchDraw(r,bm);
    inc(x,8+xoff);
    inc(y,10);
    Pen.Width:=1;
    Pen.Style:=psSolid;      // 5 x7
    if not DrawNegative then
    begin
      DrawNumber(2,value MOD 10);
      value:=value DIV 10;
      if value = 0 then
      begin
        DrawNumber(1,10);
        DrawNumber(0,10);
        exit;
      end;
      DrawNumber(1,value MOD 10);
      value:=value div 10;
      if value = 0 then value:=10;
      DrawNumber(0,value );
    end
    else
    begin
      DrawNumber(1,abs(value));
      if value<0 then DrawNumber(0,11)
                 else DrawNumber(0,10);
    end;
  end;
end;

function RGB(r,g,b:integer):integer;begin result:= b SHL 16 + g SHL 8 + r; end;

procedure Draw7SegmentEx(Canvas:TCanvas;r:TRect;Text:string;value:integer; format:TDrawExFormat;formatText:string);
    procedure TextFiguur(x,y,w:integer; s:string);
    VAR c:TSize;
        r:TRect;
    begin
      with Canvas do
      begin
        r:=Rect(x,y,x+w,y+13);
        c:=TextExtent(s);
        TextRect(r,r.Right-c.cx,(r.Bottom-1)-c.cy,s);
      end;
    end;
    procedure Line(x1,y1,x2,y2:extended);
    begin
      with Canvas do
      begin
        MoveTo(round(x1),round(y1));
        LineTo(round(x2),round(y2));
      end;
    end;


    procedure Puntje(x,y:integer);
    begin
      with Canvas do
      begin
        Line(x,y,x+2,y);
        Line(x,y+1,x+2,y+1);
      end;
    end;

    procedure Figuur(x,y,fig:integer);
      procedure puntjes(x,y,b:integer);
      VAR i:integer;
      begin
        for i:=0 to 7 do if b and (1 SHL i) <> 0 then
          puntje(x+2*(7-i),y);
      end;
      procedure bitm(x,y,b1,b2,b3,b4,b5,b6:integer);
      begin
        puntjes(x,y+0,b1);
        puntjes(x,y+2,b2);
        puntjes(x,y+4,b3);
        puntjes(x,y+6,b4);
        puntjes(x,y+8,b5);
        puntjes(x,y+10,b6);
      end;
    begin
      case fig of
        0:  bitm(x,y,$1,$3,$5,$9,$11,$21);     // saw
        1:  bitm(x,y,$0,$4F,$49,$49,$79,$0);   // squ
        2:  bitm(x,y,$30,$48,$49,$9,$6,0);     // sin
        3:  bitm(x,y,$0,$8,$14,$22,$41,0);     // tri
        4:  bitm(x,y,$0,$38,$28,$28,$6F,0);    // H Pulse
        5:  bitm(x,y,$0,$E,$0A,$0A,$FB,0);     // Q Pulse
        6:  bitm(x,y,$1,$2,$14,$28,$8,0);      // tri saw
        7:  bitm(x,y,$20,$31,$77,$5f,$5d,$48); // noise
        else
            bitm(x,y,$FF,$FF,$FF,$FF,$FF,$FF)
      end;
    end;

VAR s:string;
    c: TSize;
    x,y,waveCount:integer;

begin
  with Canvas do
  begin

    Brush.color:=$252525;
    Pen.Color:=RGB(156,145,148);//Brush.Color;
    Brush.Style:=bsSolid;
    Pen.Style:=psSolid;

    Pen.Width:=1;
    Rectangle(r);

    Pen.Color:=RGB(156,145,148);
    Pen.Style:=psSolid;
    Brush.Style:=bsClear;
    if r.Width< 120 then
    begin
      Font.size:=7;
      font.Name:='Arial';
    end
    else
    begin
      Font.Size:=10;
      font.Name:='FixedSys';
    end;
    s:=Text;
    if s='' then s:='H';
    font.Color:=clWhite; //toColor(trLightGray);
    c:=TextExtent(s);
    x:=(r.Width-50-c.cx) DIV 2;
    y:=r.Height-c.cy;
    y:=y DIV 2;
    TextRect(r,x,y,Text);
    case format of
      deValue:
        Draw7Segment(Canvas,r.Width-50,(r.Height-33) DIV 2,value,false,value<0);
      deNegValue:
          Draw7Segment(Canvas,r.Width-50,(r.Height-33) DIV 2,value-3,false,true);
      deWaveValue:
        begin
          Pen.Color:=$FFFF00;
          Figuur(r.Width-30,y+3,value);
        end;
      deTextValue:
        begin
          Font.Color:=$FFFF00;
          TextFiguur(r.Width-57,y+3,50,formatText);
        end;
    end;
  end;
end;



end.
