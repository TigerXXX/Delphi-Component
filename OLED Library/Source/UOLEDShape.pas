{ ============================================
  Software Name : 	OLED Library
  ============================================ }
{ ******************************************** }
{ Written By WalWalWalides }
{ CopyRight � 2019 }
{ Email : WalWalWalides@gmail.com }
{ GitHub :https://github.com/walwalwalides }
{ ******************************************** }
unit UOLEDShape;

interface

uses System.SysUtils, System.Classes, Messages, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Types, UOLEDConstants, UOLEDKNOB;

{ interface.interface }
type
  TOLEDProcChanged = reference to procedure(sender: TObject; newvalue: integer);

  TOLEDShape = class
    procedure Paint; virtual; abstract;
    procedure SetValue(aValue: integer); virtual; abstract;
    procedure OnMouseDown(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer); virtual; abstract;
    procedure OnMouseUp(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer); virtual; abstract;
    procedure OnMouseMove(sender: TObject; Shift: TShiftState; X, Y: integer); virtual; abstract;
    procedure OnMouseClick(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer); virtual;
    procedure SetAttributeValue(msg, value: integer); virtual; abstract;
    procedure DefaultWH(VAR w, h: integer); virtual; abstract;

  end;

function CreateShape(owner: TComponent; shape: TOLEDKnobShape; procChanged: TOLEDProcChanged): TOLEDShape;

implementation

{ implementation.interface }

uses UOLEDControls, Windows, Math, Dialogs, UOLEDBitmaps, UOLED7Segment, Vcl.Imaging.pngimage;

type
  TVCLBitmap = Vcl.Graphics.TBitmap;
  ArrayOfInteger = TArray<integer>;

  TOLEDShapeBaseImp = class(TOLEDShape)
  private
    FThumbStartP: TPoint;
    FThumbStartValue: integer;
    FThumping, FMouseHasMoved: boolean;
    FProcChanged: TOLEDProcChanged;
    { property } shape: TOLEDKnobShape;
    { property } value: integer;
    OLEDPotentiometer: TOLEDPotentiometer;
    procedure Init; virtual;
    procedure SetValue(aValue: integer); override;
    function MouseMoveUseX: boolean; virtual;
    procedure DefaultWH(VAR w, h: integer); override;
    function MouseRange: integer; virtual;
    function MouseInvert: boolean; virtual;
    // procedure Paint;virtual;abstract;
    procedure OnMouseDown(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure OnMouseUp(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure OnMouseMove(sender: TObject; Shift: TShiftState; X, Y: integer); override;
    constructor Create(owner: TComponent; shape: TOLEDKnobShape; procChanged: TOLEDProcChanged); virtual;
    procedure StartMouseKnob(X, Y, knob: integer);
    function CalcButtonColor: TColor;
    procedure SetAttributeValue(msg, value: integer); override;
    function KnobEditor: TKnobEditor;
    procedure Line(x1, y1, x2, y2: extended);
  end;

  TOLEDTwinkle = class(TOLEDShapeBaseImp)
  private
    FLightColor: TColor;
    FTimer: TTimer;
    FOwnInvalidate: boolean;
    FSpeed, FPaintPosition: integer;
    procedure SetValue(aValue: integer); override;
    procedure Paint; override;
    procedure Init; override;
    function CalcColor: TColor;
    procedure PaintInner;
    procedure TwinkleTimer(sender: TObject);
    function NextPosition: boolean;
    function PrevPosition: boolean;
  public
    procedure SetAttributeValue(msg, value: integer); override;
  end;

  TOLEDSunrise = class(TOLEDShapeBaseImp)
  private
    procedure Paint; override;
  public
  end;

  TOnOwnerDraw = procedure(sender: TOLEDPotentiometer) of object;

  TOLEDOwnerDraw = class(TOLEDShapeBaseImp)
  private
    procedure Paint; override;
  public
    OnOwnerDraw: TOnOwnerDraw;
  end;

  TOLEDElementOLED = class(TOLEDShapeBaseImp)
    function OLEDMouseRange(defvalue: integer): integer;
    procedure Paint; override;
  end;

  TOLEDElementVA = class(TOLEDShapeBaseImp)
    procedure KnobPaint(w, h, mx, my, r1, r2: integer; getBitmap: TVCLBitmap; count: integer; values: ArrayOfInteger);
    procedure Paint; override;
    procedure DefaultWH(VAR w, h: integer); override;
  end;

  TOLEDElementRol = class(TOLEDShapeBaseImp)

  private
    FSaveValue: integer;
  protected
    procedure RolandKnobPaint;
    procedure RolandVSliderPaint;
    procedure RolandHSliderPaint;
    procedure RolandTextPaint;
    function MouseInvert: boolean; override;
    function MouseRange: integer; override;
    function MouseMoveUseX: boolean; override;
    procedure Paint; override;
    procedure OnMouseClick(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;

  end;

  { implementation.implementation }

function OLEDStyle(shape: TOLEDKnobShape): TOLEDStyle;
begin
  case shape of
    trKnob, trButton, trSlider, trNone, trMidi4, trLedButton, trTextButton, trText, trLed, trTextLine, trPitchKnob:
      result := tsOLED;
    tkVCOWave, tkLFOWave, tkFoot, tkNoise, tkValue, tkNone, tkLFO, tkSlider, tkSliderMulti:
      result := tsRoland;
    tvWave, tvFoot, tvKnob, tvLFO, tvLFOSel, tvWaveFoot4, tvWaveShape4, tvLOF1, tvLFO2:
      result := tsVASynth;
    trTwinkle:
      result := tsTwinkle;
    tsKnob, tsButton, tsSlider, tsLed:
      result := tsSunrise;
    toOwnerDraw:
      result := tsOwnerDraw;
  else
    result := tsError;
  end;
end;

function CreateShape(owner: TComponent; shape: TOLEDKnobShape; procChanged: TOLEDProcChanged): TOLEDShape;
begin
  case OLEDStyle(shape) of
    tsOLED:
      result := TOLEDElementOLED.Create(owner, shape, procChanged);
    tsRoland:
      result := TOLEDElementRol.Create(owner, shape, procChanged);
    tsVASynth:
      result := TOLEDElementVA.Create(owner, shape, procChanged);
    tsTwinkle:
      result := TOLEDTwinkle.Create(owner, shape, procChanged);
    tsSunrise:
      result := TOLEDSunrise.Create(owner, shape, procChanged);
    tsOwnerDraw:
      result := TOLEDOwnerDraw.Create(owner, shape, procChanged);
    tsError:
      result := NIL;
  end;
end;

constructor TOLEDShapeBaseImp.Create(owner: TComponent; shape: TOLEDKnobShape; procChanged: TOLEDProcChanged);
begin
  // inherited Create(NIL);
  OLEDPotentiometer := TOLEDPotentiometer(owner);
  FProcChanged := procChanged;
  self.shape := shape;
  FThumping := false;
  Init;
end;

procedure TOLEDShapeBaseImp.DefaultWH(var w, h: integer);
begin

end;

procedure TOLEDShapeBaseImp.Init;
begin

end;

function TOLEDShapeBaseImp.KnobEditor: TKnobEditor;
begin
  result := OLEDPotentiometer.KnobEditor;
end;

procedure TOLEDShapeBaseImp.OnMouseUp(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin

  FThumping := false;
  if not FMouseHasMoved then
    OnMouseClick(sender, Button, Shift, X, Y);
  if (shape = trPitchKnob) and (KnobEditor <> NIL) then
    KnobEditor.EditKnobMouseUp(OLEDPotentiometer.index);

end;

procedure TOLEDShapeBaseImp.OnMouseMove(sender: TObject; Shift: TShiftState; X, Y: integer);
VAR
  newvalue, d: integer;
begin
  if FThumping then
  begin

    FMouseHasMoved := true;
    if MouseMoveUseX then
      d := X - FThumbStartP.X // default move is left to right
    else
    begin
    if   (shape = tkLFO) then d := -FThumbStartP.Y + Y // default move is up
    else
      d := FThumbStartP.Y - Y;
  end;

  if MouseInvert then
    d := -d;
  if d > MouseRange then
    d := MouseRange;
  if d < -MouseRange then
    d := -MouseRange;
  newvalue := FThumbStartValue + d * (OLEDPotentiometer.maxValue - OLEDPotentiometer.minValue) DIV MouseRange;
  if newvalue < OLEDPotentiometer.minValue then
    newvalue := OLEDPotentiometer.minValue;
  if newvalue > OLEDPotentiometer.maxValue then
    newvalue := OLEDPotentiometer.maxValue;
  if newvalue <> value then
  begin
    value := newvalue;
    if (shape = trPitchKnob) and (KnobEditor <> NIL) then
      KnobEditor.EditKnobMouseMove(OLEDPotentiometer.index, value);
    FProcChanged(self, value);
  end;
end;
end;

procedure TOLEDShapeBaseImp.SetAttributeValue(msg, value: integer);
begin

end;

procedure TOLEDShapeBaseImp.SetValue(aValue: integer);
begin
  value := aValue;
end;

procedure TOLEDShapeBaseImp.StartMouseKnob(X, Y, knob: integer);
begin
  FThumbStartP := Point(X, Y);
  FThumbStartValue := value;
  FThumping := true;
  FMouseHasMoved := false;
end;

function TOLEDShapeBaseImp.MouseMoveUseX: boolean;
begin
  result := false;
end;

function TOLEDShapeBaseImp.MouseInvert: boolean;
begin
  result := false;
end;

function TOLEDShapeBaseImp.MouseRange: integer;
begin
  if OLEDPotentiometer.maxValue - OLEDPotentiometer.minValue > 5 then
    result := 200
  else
    result := 100;
end;

procedure TOLEDShapeBaseImp.OnMouseDown(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
  function CalcMidi(value: integer): integer;
  VAR
    midi: integer;
  begin
    midi := ord(X > OLEDPotentiometer.Width DIV 2) + 2 * ord(Y > OLEDPotentiometer.Height DIV 2);
    if value and (1 shl midi) <> 0 then
      result := value and not(1 shl midi)
    else
      result := value or (1 shl midi);
  end;
  function CalcLFOSelect(value: integer): integer;
  begin
    value := value DIV 32;
    result := round(127 * (value xor (1 shl ord(Y > OLEDPotentiometer.Height DIV 2))) / 3);
  end;

begin
  with TOLEDPotentiometer(sender) do
  begin
    case shape of
      trNone:
        ;
      trLedButton, trLed, trTextButton, trTwinkle, tsButton, tsLed, trButton:
        begin
          value := 127 - value;
          FProcChanged(self, value);
        end;
      trMidi4:
        begin
          value := CalcMidi(value);
          FProcChanged(self, value);
        end;
      trPitchKnob, trKnob:
        begin
          StartMouseKnob(X, Y, index);
          if (shape = trPitchKnob) and (KnobEditor <> NIL) then
            KnobEditor.EditKnobMouseDown(index, value);
        end;

    else
      StartMouseKnob(X, Y, index);
    end;
  end;
end;

function TOLEDShapeBaseImp.CalcButtonColor: TColor;
begin
  if value <> 0 then
    result := OLEDPotentiometer.ButtonColorOn
  else
    result := OLEDPotentiometer.ButtonColorOff;
  if (result = clNone) or not OLEDPotentiometer.Visible then
    result := OLEDPotentiometer.BackColor;
end;

procedure CopyAntiAliased(handlet: THandle; wt, ht: integer; handles: THandle; ws, hs: integer);
begin
  SetStretchBltMode(handlet, HALFTONE);
  StretchBlt(handlet, 0, 0, wt, ht, handles, 0, 0, ws, hs, SRCCOPY);
end;

function dx(r, alpha: integer): integer;
begin
  result := round(r * cos(pi * alpha / 180));
end;

function dy(r, alpha: integer): integer;
begin
  result := round(r * sin(pi * alpha / 180));
end;

{ TOLEDTwinkle }

procedure TOLEDTwinkle.Init;
begin
  inherited;
  FTimer := TTimer.Create(NIL);
  FTimer.OnTimer := TwinkleTimer;
  FTimer.Interval := 16;
  FTimer.Enabled := false;
  FSpeed := 8;
  FLightColor := $252525;
  FPaintPosition := 0;
end;

procedure TOLEDTwinkle.Paint;
VAR
  cl: TColor;
  r: Trect;
begin
  if not FOwnInvalidate then
    with OLEDPotentiometer, Canvas do
    begin
      Brush.Color := BackColor;
      Pen.Color := Brush.Color;
      Brush.Style := bsSolid;
      Pen.Style := psSolid;
      Pen.Width := 1;
      r := Rect(0, 0, Width, Height);
      Rectangle(0, 0, Width + 1, Height + 1);
    end;
  PaintInner;
end;

procedure TOLEDTwinkle.PaintInner;
VAR
  cl: TColor;
  r: Trect;
begin
  with OLEDPotentiometer, Canvas do
  begin
    cl := FLightColor;
    Brush.Color := cl;
    Pen.Color := clBlack;
    Pen.Style := psSolid;
    Pen.Width := 2;
    r := Rect(0, 0, Width, Height);
    Ellipse(r.Left, r.Top, r.Right, r.Bottom);
  end;
end;

function RGB(r, g, b: integer): integer;
begin
  result := b SHL 16 + g SHL 8 + r;
end;

function TOLEDTwinkle.CalcColor: TColor;
VAR
  X: double;
  r, g, b, fx: integer;
begin
  X := FPaintPosition / 255;
  fx := round(sqrt(X) * 255);
  b := $25 + round((128 - $25) * 2 * X);
  if X < 0.5 then
    result := RGB(b, b, b) // fx,fx,fx)
  else
    result := RGB(fx, fx, fx DIV 3); // light yellow = rgb(255,255,102)
end;

function TOLEDTwinkle.NextPosition: boolean;
VAR
  newPosition: integer;
begin
  newPosition := FPaintPosition + FSpeed;
  if newPosition >= 256 then
  begin
    result := false;
    FPaintPosition := 255;
  end
  else
  begin
    result := true;
    FPaintPosition := newPosition;
  end;
  FLightColor := CalcColor;
end;

function TOLEDTwinkle.PrevPosition: boolean;
VAR
  newPosition: integer;
begin
  newPosition := FPaintPosition - FSpeed;
  if newPosition < 0 then
  begin
    result := false;
    FPaintPosition := 0;
  end
  else
  begin
    result := true;
    FPaintPosition := newPosition;
  end;

  FLightColor := CalcColor;
end;

procedure TOLEDTwinkle.TwinkleTimer(sender: TObject);
begin
  if (value > 0) then
    FTimer.Enabled := NextPosition
  else
    FTimer.Enabled := PrevPosition;
  FOwnInvalidate := true;
  OLEDPotentiometer.Invalidate;
  FOwnInvalidate := false;
end;

procedure TOLEDTwinkle.SetAttributeValue(msg, value: integer);
begin
  if msg = OLEDMSG_TWINKLESPEED then
    FSpeed := value;
end;

procedure TOLEDTwinkle.SetValue(aValue: integer);
begin
  inherited;
  FTimer.Enabled := true;
end;

procedure TOLEDShapeBaseImp.Line(x1, y1, x2, y2: extended);
begin
  with OLEDPotentiometer.Canvas do
  begin
    MoveTo(round(x1), round(y1));
    LineTo(round(x2), round(y2));
  end;
end;

function TOLEDElementRol.MouseInvert: boolean;
begin
  result := (shape = tkVCOWave) or (shape = tkLFO);
end;

function TOLEDElementOLED.OLEDMouseRange(defvalue: integer): integer;
begin
  if OLEDPotentiometer.maxValue - OLEDPotentiometer.minValue > 5 then
    result := 200
  else
    result := 100;
end;

function TOLEDElementRol.MouseRange: integer;
begin
  if MouseMoveUseX then
    result := OLEDPotentiometer.Width
  else
    result := OLEDPotentiometer.Height;
end;

procedure TOLEDElementOLED.Paint;
  procedure DrawKnob;
  VAR
    r: Trect;
    alpha, r1, r2, xm, ym: integer;
    bm: TVCLBitmap;
  begin
    with OLEDPotentiometer, Canvas do
    begin
      r := Rect(0, 0, Width, Height);
      bm := getBitmap(BmpOLEDKnob);
      bm.transparent := true;
      StretchDraw(r, bm);
      alpha := 240 - 300 * (value - minValue) DIV (maxValue - minValue);
      r1 := round(15 * Width DIV bm.Width);
      r2 := round(24 * Width DIV bm.Width);
      xm := Width div 2;
      ym := Height DIV 2;
      MoveTo(xm + dx(r1, alpha), ym - dy(r1, alpha));
      Pen.Color := clWhite;
      Pen.Width := 2;
      LineTo(xm + dx(r2, alpha), ym - dy(r2, alpha));
    end;
  end;

  procedure DrawVerSlider;
  VAR
    xm, yt, yb, yv, ym, i: integer;
  begin
    with OLEDPotentiometer, Canvas do
    begin
      xm := Width DIV 2;
      yt := 4;
      yb := Height - 4;
      yv := yb - ((yb - yt) * (value - minValue)) DIV (maxValue - minValue);
      Brush.Color := BackColor;
      Brush.Style := bsSolid;
      Pen.Style := psClear;
      Rectangle(0, 0, Width + 1, Height + 1);
      Pen.Color := RGB(156, 145, 148);
      Pen.Width := 1;
      Pen.Style := psSolid;
      for i := 0 to 10 do
      begin
        MoveTo(xm, yt + i * (yb - yt) DIV 10);
        LineTo(xm + 5, yt + i * (yb - yt) DIV 10);
      end;
      Pen.Color := clWhite;
      Pen.Width := 1;
      MoveTo(xm, yt);
      LineTo(xm, yb);
      MoveTo(xm, yt);
      LineTo(xm + 10, yt);
      MoveTo(xm, yb);
      LineTo(xm + 10, yb);
      MoveTo(xm, (yb + yt) DIV 2);
      LineTo(xm + 5, (yb + yt) DIV 2);
      Pen.Color := sliderColor;
      Pen.Width := 3;
      MoveTo(xm - 10, yv);
      LineTo(xm + 10, yv);
    end;
  end;
  procedure DrawHorSlider;
  VAR
    ym, xt, xb, xv, xm, i: integer;
  begin
    with OLEDPotentiometer, Canvas do
    begin
      ym := Height DIV 2;
      xt := 4;
      xb := Width - 4;
      xv := xb - ((xb - xt) * (value - minValue)) DIV (maxValue - minValue);
      Brush.Color := BackColor;
      Brush.Style := bsSolid;
      Pen.Style := psClear;
      Rectangle(0, 0, Width + 1, Height + 1);
      Pen.Color := RGB(156, 145, 148);
      Pen.Width := 1;
      Pen.Style := psSolid;
      for i := 0 to 10 do
      begin
        MoveTo(ym, xt + i * (xb - xt) DIV 10);
        LineTo(ym + 5, xt + i * (xb - xt) DIV 10);
      end;
      Pen.Color := clWhite;
      Pen.Width := 1;
      MoveTo(ym, xt);
      LineTo(ym, xb);
      MoveTo(ym, xt);
      LineTo(ym + 10, xt);
      MoveTo(ym, xb);
      LineTo(ym + 10, xb);
      MoveTo(ym, (xb + xt) DIV 2);
      LineTo(ym + 5, (xb + xt) DIV 2);
      Pen.Color := sliderColor;
      Pen.Width := 3;
      MoveTo(ym - 10, xv);
      LineTo(ym + 10, xv);
    end;
  end;

  procedure DrawSlider;
  begin

    if OLEDPotentiometer.Width < OLEDPotentiometer.Height then
      DrawVerSlider
    else
      DrawHorSlider;
  end;
  procedure DrawMidi4;
  VAR
    w, h, i, l, t: integer;
  begin
    with OLEDPotentiometer, Canvas do
    begin
      Brush.Color := BackColor;
      Brush.Style := bsSolid;
      Pen.Style := psClear;
      Rectangle(0, 0, Width + 1, Height + 1);

      Brush.Color := clBlue;
      Brush.Style := bsSolid;
      Pen.Style := psSolid;
      Pen.Color := cLgray;
      w := Width; // Leeg|  |Leeg| |Leeg   Leeg =4
      h := Height;
      w := (w - 4) DIV 2;
      h := (h - 4) DIV 2;
      for i := 0 to 3 do
      begin
        l := (i MOD 2) * (w + 4);
        t := (i DIV 2) * (h + 4);
        if value AND (1 SHL i) <> 0 then
          Brush.Color := cLgray
        else
          Brush.Color := BackColor;
        Rectangle(l, t, l + w, t + h);
      end;
    end;
  end;
  procedure DrawButtonText;
  VAR
    cl: TColor;
    c: TSize;
    r: Trect;
  begin
    if not OLEDPotentiometer.Visible then
      exit;
    with OLEDPotentiometer, Canvas do
    begin
      cl := CalcButtonColor;
      Brush.Color := cl;
      Brush.Style := bsSolid;
      Pen.Color := ButtonColorOn;
      Pen.Style := psSolid;
      Pen.Width := 1;
      r := Rect(0, 0, Width, Height);
      FillRect(r);
      Rectangle(r);
      if value <> 0 then
        Font.Color := clBlack
      else
        Font.Color := ButtonColorOn;
      if FontSize = 0 then
        Font.Size := 6
      else
        Font.Size := FontSize;
      inc(r.Left);
      inc(r.Top);
      dec(r.Right);
      dec(r.Bottom);
      c := TextExtent(Text);
      TextRect(r, ((r.Left + r.Right) DIV 2) - c.cx DIV 2, (r.Bottom + r.Top) DIV 2 - c.cy DIV 2, Text);
    end;
  end;
  procedure DrawLed;
  VAR
    cl: TColor;
    r: Trect;
  begin
    with OLEDPotentiometer, Canvas do
    begin
      cl := CalcButtonColor;
      Brush.Color := cl;
      Brush.Style := bsSolid;
      Pen.Color := cl;
      r := Rect(0, 0, Width, Height);
      Rectangle(r);
    end;
  end;

  procedure DrawText(lineText: boolean);
  VAR
    c: TSize;
    cl: TColor;
    r: Trect;
    doline: boolean;
    s, s1, s2: string;
    p, X, Y: integer;
  begin
    // if not visible then exit;

    with OLEDPotentiometer, OLEDPotentiometer.Canvas do
    begin
      cl := OLEDPotentiometer.Font.Color;
      if cl = clNone then
        exit;
      Brush.Color := BackColor;
      Pen.Color := Brush.Color;
      Brush.Style := bsSolid;
      Pen.Style := psSolid;
      Pen.Width := 1;
      r := Rect(0, 0, Width, Height);
      Rectangle(r);

      Pen.Color := RGB(156, 145, 148);
      Pen.Style := psSolid;
      Brush.Style := bsClear;
      Font.Color := cl;
      if lineText then
      begin
        Font.Size := 10;
        Font.Name := 'FixedSys';
        s := Text;
        if s = '' then
          exit;
        doline := s[1] = '-';
        if doline then
          s := Copy(s, 2);
        c := TextExtent(s);
        X := (r.Left + r.Right) DIV 2 - c.cx DIV 2;
        Y := (r.Bottom + r.Top) DIV 2 - c.cy DIV 2;
        TextRect(r, X, Y, s);
        if doline then
        begin
          Y := Y + c.cy DIV 2;
          Pen.Color := cl;
          Line(0, Y, X - 4, Y);
          Line(0, Y + 1, X - 4, Y + 1);
          Line(X + 4 + c.cx, Y, Width, Y);
          Line(X + 4 + c.cx, Y + 1, Width, Y + 1);
        end;

      end
      else
      begin
        if FontSize = 0 then
          Font.Size := 6
        else
          Font.Size := FontSize;
        Font.Name := 'Arial';
        Font.Color := OLEDPotentiometer.Font.Color;

        c := TextExtent(Text);
        p := pos(' ', Text);
        X := (r.Left + r.Right - c.cx) DIV 2;
        Y := (r.Bottom - 2) - c.cy;
        if (X < 0) and (p > 0) then
        begin
          // retry on two lines...
          s1 := Copy(Text, 1, p - 1);
          s2 := Copy(Text, p + 1);
          c := TextExtent(s1);
          X := (r.Left + r.Right) DIV 2 - c.cx DIV 2;
          Y := 0;
          TextRect(r, X, Y, s1);
          c := TextExtent(s2);
          X := (r.Left + r.Right) DIV 2 - c.cx DIV 2;
          Y := c.cy;
          TextRect(r, X, Y, s2);
        end
        else
          TextRect(r, X, Y, Text);
      end;
    end;
  end;
  procedure DrawButton;
  VAR
    cl: TColor;
    r: Trect;
  begin
    with OLEDPotentiometer, Canvas do
    begin
      Brush.Color := BackColor; // ;
      Brush.Style := bsSolid;
      Pen.Style := psClear;
      Rectangle(0, 0, Width + 1, Height + 1);

      Brush.Color := clBlack;
      Brush.Style := bsSolid;
      Pen.Style := psSolid;
      Pen.Color := cLgray;
      RoundRect(0, 0, Width, Height, 5, 5);

      if shape = trLedButton then
      begin
        with Canvas do
        begin
          cl := CalcButtonColor;
          Brush.Color := cl;
          Brush.Style := bsSolid;
          Pen.Color := cl;
          r := Rect(Width DIV 2 - 6 + Width MOD 2, 2 * Height DIV 3 - 2, Width DIV 2 + 6, 2 * Height DIV 3 + 2);
          Rectangle(r);
        end;

      end;

    end;
  end;

begin
  case shape of
    trPitchKnob, trKnob:
      DrawKnob;
    trSlider:
      DrawSlider;
    trLed:
      DrawLed;
    trText:
      DrawText(false);
    trTextLine:
      DrawText(true);
    trLedButton, trButton:
      DrawButton;
    trMidi4:
      DrawMidi4;
    trTextButton:
      DrawButtonText;
  end;
end;

function TOLEDElementRol.MouseMoveUseX: boolean;
begin
  result := ((shape = tkSlider) or (shape = tkSliderMulti)) and (OLEDPotentiometer.Width > OLEDPotentiometer.Height);
end;

procedure TOLEDElementRol.Paint;
begin
  if OLEDPotentiometer.TextWithSeg7 then
    RolandTextPaint
  else
    case shape of
      tkVCOWave, tkLFOWave, tkFoot, tkNoise, tkValue, tkNone:
        RolandKnobPaint;
      tkLFO:
        RolandVSliderPaint;
      tkSlider, tkSliderMulti:
        if OLEDPotentiometer.Width < OLEDPotentiometer.Height then
          RolandVSliderPaint
        else
          RolandHSliderPaint;
    end;
end;

{ TOLEDElementVA }

procedure TOLEDElementVA.DefaultWH(var w, h: integer);
begin
  w := 79;
  h := 52;
  case shape of
    tvFoot:
      begin
        w := 67;
        h := 60;
      end;
    tvKnob:
      begin
        w := 66;
        h := 57;
      end;
  end;
end;

procedure TOLEDElementVA.Paint;
VAR
  bdefault: TVCLBitmap;
begin
  bdefault := NIL;
  case shape of
    tvWave:
      KnobPaint(79, 52, 37, 28, 8, 20, getBitmap(BmpOLEDVAWave), 8, ArrayOfInteger.Create(225, 195, 165, 135, 45, 15, -15, -45));
    tvFoot:
      KnobPaint(67, 60, 33, 34, 8, 20, getBitmap(BmpOLEDVAFoot), 7, ArrayOfInteger.Create(225, 180, 135, 90, 45, 0, -45));
    tvKnob:
      KnobPaint(66, 57, 34, 34, 13, 16, getBitmap(BmpOLEDVAKnob), 0, NIL);
    tvLFO:
      KnobPaint(79, 52, 37, 28, 8, 20, getBitmap(BmpOLEDVALFO), 4, ArrayOfInteger.Create(225, 135, 45, -45));
    tvLFOSel:
      bdefault := getBitmap(BmpOLEDVALFOSEL);
    tvWaveFoot4:
      bdefault := getBitmap(BmpOLEDVAFoot4);
    tvWaveShape4:
      bdefault := getBitmap(BmpOLEDVAWAVE4);
    tvLOF1:
      bdefault := getBitmap(BmpOLEDVALFO1);
    tvLFO2:
      bdefault := getBitmap(BmpOLEDVALFO2);
  end;
  if bdefault <> NIL then
    KnobPaint(79, 52, 37, 28, 8, 20, bdefault, 4, ArrayOfInteger.Create(270 - 36, 270 - 2 * 36, 270 - 3 * 36, 270 - 4 * 36));
end;

procedure TOLEDElementVA.KnobPaint(w, h, mx, my, r1, r2: integer; getBitmap: TVCLBitmap; count: integer; values: ArrayOfInteger);
  function calcAngle(value: integer): integer;
  begin
    if count = 0 then
      result := 225 - round(value * 270 / 127)
    else
      result := values[trunc(value * count / 128)];
  end;

VAR
  x1, x2, y1, y2, alpha: integer;
VAR
  bmp2: TVCLBitmap;
begin
  bmp2 := TVCLBitmap.Create;
  bmp2.SetSize(w, h);
  with bmp2.Canvas do
  begin
    StretchDraw(Rect(0, 0, w, h), getBitmap);
    alpha := calcAngle(value);
    x1 := dx(r1, alpha);
    x2 := dx(r2, alpha);
    y1 := -dy(r1, alpha);
    y2 := -dy(r2, alpha);
    if shape = tvKnob then
    begin
      Pen.Color := clBlack;
      Pen.Width := 2;
      MoveTo(mx, my);
      LineTo(mx + x1, my + y1);
      Pen.Color := clWhite;
      LineTo(mx + x2, my + y2);
    end
    else
    begin
      Pen.Color := clWhite;
      Pen.Width := 2;
      MoveTo(mx + x1, my + y1);
      LineTo(mx + x2, my + y2);
    end;
  end;
  with OLEDPotentiometer do
    CopyAntiAliased(Canvas.Handle, Width, Height, bmp2.Canvas.Handle, bmp2.Width, bmp2.Height);
  bmp2.Free;
end;

procedure TOLEDElementRol.RolandKnobPaint;
  function dx(r, alpha: integer): integer;
  begin
    result := round(r * cos(pi * alpha / 180));
  end;
  function dy(r, alpha: integer): integer;
  begin
    result := round(r * sin(pi * alpha / 180));
  end;
  procedure DrawKnob;
  VAR
    WaveCount, mx, my, grad, positions, i, vvalue, d, dmx, r1, r2, x1, x2, y1, y2: integer;
  begin
    with OLEDPotentiometer, Canvas do
    begin

      getBitmap(BmpRolandKnob).transparent := true;
      StretchDraw(Rect(12, 13, 12 + 66, 10 + 66), getBitmap(BmpRolandKnob));
      mx := 44;
      my := 13 + 33;
      Pen.Color := clLightGray;
      Pen.Width := 1;
      if (shape = tkNoise) then
        positions := 3
      else
        positions := 4;
      if (shape = tkFoot) then
        positions := 7;
      if (shape = tkValue) then
        positions := 10;
      r1 := 38;
      d := 1;
      if shape = tkValue then
        grad := (270 - 45) - ((360 - 2 * 45) * value) DIV (maxValue + 1)
      else if shape = tkFoot then
        grad := 195 - 35 * (positions * value DIV (maxValue + 1)) // tussen 195 en -15 ??
      else if (shape = tkVCOWave) or (shape = tkLFOWave) then
      begin
        if (shape = tkVCOWave) then
          WaveCount := 8
        else
          WaveCount := 4;
        vvalue := value * WaveCount DIV positions;
        if vvalue >= 127 then
          vvalue := 127;
        grad := 45 - 30 * (positions * vvalue DIV (maxValue + 1));
      end
      else
        grad := 45 - 30 * (positions * value DIV (maxValue + 1));

      dec(mx, 1);
      r1 := 5;
      r2 := 28;
      x1 := dx(r1, grad);
      x2 := dx(r2, grad);
      y1 := -dy(r1, grad);
      y2 := -dy(r2, grad);
      Pen.Color := clBlack;
      Pen.Width := 3;
      Line(mx + d * x1, my + y1, mx + d * (x2 - 1), my + y2 - 1);
      Line(mx + d * x1, my + y1, mx + d * x2, my + y2);
    end;
  end;
  procedure DrawPanel(x1: integer);
  VAR
    i, y1, dumi: integer;
  begin
    with OLEDPotentiometer, Canvas do
    begin
      Pen.Width := 1;
      Pen.Color := clLightGray;
      Pen.Style := psSolid;

      y1 := 92 - 36 - 44;
      Font.Name := 'FixedSys';
      Font.Size := 8;
      Brush.Style := bsClear;
      Font.Color := clLightGray;
    end;
  end;

begin
  DrawKnob;
  // if Shape <> tkFoot then
  DrawPanel(87);
end;

procedure TOLEDElementRol.RolandVSliderPaint;
VAR
  bmb, bmu, bms: TVCLBitmap;
  h, hu, huCount, hs, h2, hb, i, t, w2, Y: integer;
  fy: single;
  r: Trect;
begin
  with OLEDPotentiometer, Canvas do
  begin
    bmb := getBitmap(BmpSliderVerBot);
    bmu := getBitmap(BmpSliderVerUpp);
    bms := getBitmap(BmpRolandVSlider);
    w2 := round(Width * 0.7);
    hs := round(bms.Height * w2 / bms.Width);
    h := Height - hs;
    if Height >= 100 then
      h := h - 35;
    hb := round(bmb.Height * Width / bmb.Width);
    hu := round(bmu.Height * Width / bmu.Width);
    huCount := round((h - hb) / hu);
    h2 := huCount * hu + hb;
    fy := h / h2;
    t := hs DIV 2;
    for i := 0 to huCount - 1 do
    // draw scaled bmu at 0,t+i*hu,width,t+(i+1)*hu-1
    begin
      r := Rect(0, round(t + i * fy * hu), Width, round(t + (i + 1) * fy * hu));
      StretchDraw(r, bmu);
    end;
    // draw scaled getBitmap at t+huCount*hu-1,width, t+huCount*hu-1 + hb - 1
    r := Rect(0, round(t + fy * huCount * hu), Width, round(t + fy * (huCount * hu + hb - 1)));
    StretchDraw(r, bmb);
    Y := hs DIV 2 + round((127 - value) * h / 127);
    r := Rect((Width - w2) DIV 2, Y - hs DIV 2, (Width + w2) DIV 2, Y + hs DIV 2);
    bms.transparent := true;
    StretchDraw(r, bms);
    if Height >= 100 then
      Draw7Segment(Canvas, 0, Height - 35, value, true, false);
  end;
end;

procedure TOLEDElementRol.RolandHSliderPaint;
VAR
  bmb, bmu, bms: TVCLBitmap;
  w, wu, wuCount, ws, w2, X, wb, i, l, h2: integer;
  fx: single;
  r: Trect;
begin
  with OLEDPotentiometer, Canvas do
  begin
    bmb := getBitmap(BmpSliderHorBot);
    bmu := getBitmap(BmpSliderHorUpp);
    bms := getBitmap(BmpRolandHSlider);
    h2 := round(Height * 0.7);
    ws := round(bms.Width * h2 / bms.Height);
    w := Width - ws;
    wb := round(bmb.Width * Height / bmb.Height);
    wu := round(bmu.Width * Height / bmu.Height);
    wuCount := round((w - wb) / wu);
    w2 := wuCount * wu + wb;
    fx := w / w2;
    l := ws DIV 2;
    for i := 0 to wuCount - 1 do
    // draw scaled bmu at 0,t+i*hu,width,t+(i+1)*hu-1
    begin
      r := Rect(round(l + i * fx * wu), 0, round(l + (i + 1) * fx * wu), Height);
      StretchDraw(r, bmu);
    end;
    // draw scaled getBitmap at t+huCount*hu-1,width, t+huCount*hu-1 + hb - 1
    r := Rect(round(l + fx * wuCount * wu), 0, round(l + fx * (wuCount * wu + wb - 1)), Height);
    StretchDraw(r, bmb);
    X := ws DIV 2 + round(value * w / 127);
    r := Rect(X - ws DIV 2, (Height - h2) DIV 2, X + ws DIV 2, (Height + h2) DIV 2);
    bms.transparent := true;
    StretchDraw(r, bms);
  end;
end;

procedure TOLEDElementRol.OnMouseClick(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  with OLEDPotentiometer do
  begin
    if (shape = tkSlider) or (shape = tkSliderMulti) then
    begin
      if Width < Height then
      begin
        if Y < Height - 40 then
        begin
          value := 127 - Y * 127 DIV (Height - 40);
          FProcChanged(self, value);
        end
        else
        begin
          if value = 0 then
          begin
            value := FSaveValue;
            FProcChanged(self, value);
          end
          else
          begin
            FSaveValue := value;
            value := 0;
            FProcChanged(self, value);
          end;
        end
      end
      else
      begin
        value := X * 127 DIV Width;
        FProcChanged(self, value);
      end
    end;
  end;
end;

procedure TOLEDElementRol.RolandTextPaint;
VAR
  c: TSize;
  cl: TColor;
  r: Trect;
  s: string;
  i, v, X, Y, WaveCount, dumi: integer;
const
  noise: array [0 .. 2] of string = ('PNK', 'BLU', 'WHT');
const
  lfosel: array [0 .. 3] of string = ('None', 'LFO1', 'LFO2', 'L1+2');

begin

  with OLEDPotentiometer do
    case shape of
      tkNone:
        Draw7Segment(Canvas, 0, 0, value, true, false);
      tkValue:
        Draw7SegmentEx(Canvas, Rect(0, 0, Width, Height), Text, value, deValue);
      tkFoot:
        begin
          v := 7 * value DIV (maxValue + 1);
          Draw7SegmentEx(Canvas, Rect(0, 0, Width, Height), Text, v, deNegValue);
        end;
      tkVCOWave, tkLFOWave:
        begin
          if shape = tkVCOWave then
            WaveCount := 8
          else
            WaveCount := 4;
          v := WaveCount * value DIV (maxValue + 1);
          if (shape = tkLFOWave) and (v = 3) then
            v := 7; // noise
          Draw7SegmentEx(Canvas, Rect(0, 0, Width, Height), Text, v, deWaveValue);
        end;
      tkNoise:
        begin
          s := noise[3 * value DIV (maxValue + 1)];
          Draw7SegmentEx(Canvas, Rect(0, 0, Width, Height), Text, v, deTextValue, s);
        end;
      tkLFO:
        begin
          s := lfosel[4 * value DIV (maxValue + 1)];
          Draw7SegmentEx(Canvas, Rect(0, 0, Width, Height), Text, v, deTextValue, s);
        end;
    end;
end;

{ TOLEDShape }

procedure TOLEDShape.OnMouseClick(sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
end;

{ TOLEDOverlay }

procedure ColorToRGB(const Color: integer; out r, g, b: integer);
begin
  r := Color and $FF;
  g := (Color shr 8) and $FF;
  b := (Color shr 16) and $FF;
end;

function RGBToColor(const r, g, b: integer): integer;
begin
  result := r or (g shl 8) or (b shl 16);
end;

function MixColors(c1, c2: TColor; f: single): TColor;
VAR
  r, g, b, r1, g1, b1, r2, g2, b2: integer;
begin
  ColorToRGB(c1, r1, g1, b1);
  ColorToRGB(c2, r2, g2, b2);
  r := round(r1 * (1 - f) + r2 * f);
  g := round(g1 * (1 - f) + g2 * f);
  b := round(b1 * (1 - f) + b2 * f);
  result := RGBToColor(r, g, b);
end;

{ TOLEDSunrise }

procedure TOLEDSunrise.Paint;
VAR
  bm: TVCLBitmap;
  X, Y, w, h, t: integer;
begin
  case shape of
    tsButton:
      with OLEDPotentiometer, Canvas do
      begin
        if value = 0 then
          bm := getBitmap(BmpSunriseButOff)
        else
          bm := getBitmap(BmpSunriseButOn);
        if (sliderColor = clBlack) then
          bm := getBitmap(BmpSunriseButFull);
        StretchDraw(Rect(0, 0, Width, Height), bm);
      end;
    tsLed:
      with OLEDPotentiometer, Canvas do
      begin
        if value = 0 then
          bm := getBitmap(BmpSunriseLedOff)
        else
          bm := getBitmap(BmpSunriseLedOn);
        StretchDraw(Rect(0, 0, Width, Height), bm);
      end;
    tsKnob:
      with OLEDPotentiometer, Canvas do
      begin
        bm := getBitmap(BmpSunriseKnob);
        StretchDraw(Rect(0, 0, Width, Height), bm);
        StretchDraw(Rect(0, 0, Width - 2, Height), getRotKnob(value));
      end;
    tsSlider:
      with OLEDPotentiometer, Canvas do
      begin
        bm := getBitmap(BmpSunriseSlider);
        StretchDraw(Rect(0, 0, Width, Height), bm);
        bm := getBitmap(BmpSunriseSliderKnob);
        t := round(Height / 10);
        h := round(Height * 0.8);
        Y := t + round((127 - value) * h / 127);
        w := round(2 * Width / 3);
        X := (Width - w) DIV 2;
        h := round(bm.Height * w / bm.Width);
        Y := Y - h DIV 2;
        StretchDraw(Rect(X, Y, X + w, Y + h), bm);
      end;

  end;
end;

{ TOLEDArp }

procedure TOLEDOwnerDraw.Paint;
begin
  if assigned(OLEDPotentiometer.OnSomething) then
    OLEDPotentiometer.OnSomething(OLEDPotentiometer);
end;

end.
