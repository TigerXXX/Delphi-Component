{ ============================================
  Software Name : 	OLED Library
  ============================================ }
{ ******************************************** }
{ Written By WalWalWalides                     }
{ CopyRight � 2019                             }
{ Email : WalWalWalides@gmail.com              }
{ GitHub :https://github.com/walwalwalides     }
{ ******************************************** }

unit UOLEDControls;

interface

uses
  System.SysUtils, System.Classes, Messages, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,Types, UOLEDKNOB,UOLEDConstants,
  UOLEDShape;
type
  TOLEDPotentiometer = class;

  TonBeforePaint = procedure (Sender:TOLEDPotentiometer) of object;
  TOnChanged = procedure (Sender:TObject;index,value:integer) of object;
  TOptions = class(TPersistent)
                   protected
                       FShape:TOLEDKnobShape;
                       FButtonColorOff,FButtonColorOn: TColor;
                       FSliderColor:TColor;
                       FTextWithSeg7: boolean;
                       FRMCElement:TOLEDPotentiometer;
                       procedure SetShape(value:TOLEDKnobShape);
                       constructor Create(RMCElement:TOLEDPotentiometer);
                       procedure SetButtonColorOff(value:Tcolor);
                       procedure SetButtonColorOn(value:Tcolor);
                       procedure SetSliderColor(value:Tcolor);
                       procedure SetTextWithSeg7(value:boolean);
                   published
                     property ButtonColorOff:Tcolor read FButtonColorOff write SetButtonColorOff;
                     property ButtonColorOn:Tcolor read FButtonColorOn write SetButtonColorOn;
                     property SliderColor:Tcolor read FSliderColor write SetSliderColor;
                     property TextWithSeg7: boolean read FTextWithSeg7 write SetTextWithSeg7;
                     property Shape: TOLEDKnobShape read FShape write SetShape;
                   end;
  TWinControlOLED = class (TWinControl)
    function GetKnobEditor:TKnobEditor;virtual;abstract;
  end;
  TOLEDElementBase = class( TPaintBox) // TCustomControl )  //
  private
    FPosition: TRect;
    FWScale,FHScale: double;
    FIndex:integer;
    procedure SetPosition(value:TRect);
    procedure Resize;
  public
    FontSize:integer;
    OnSomething:TNotifyEvent;
    constructor Create(AOwner : TComponent); override;
    property Position:TRect read FPosition write SetPosition ;
    procedure SetScale(w,h:double);
    property Text;
    property Canvas;
  published
    property Index:integer read FIndex write FIndex;
    property Font;
    property Caption;
    property Color;
    property OnClick;
    property Visible;

  end;
  TOLEDPotentiometer = class (TOLEDElementBase)
  private
     FValue,FminValue,FmaxValue:integer;
     FDiscreteIndex:integer;
     FOverlayR1, FOverlayR2,FOverlayShape:integer;
//     FOptions:TOptions;
     FRMCShape:TOLEDShape;
     FOnChanged:TOnChanged;
     FKnobEditor:TKnobEditor;
     FonBeforePaint: TonBeforePaint ;

     FShape:TOLEDKnobShape;
     FButtonColorOff,FButtonColorOn: TColor;
     FSliderColor:TColor;
     FTextWithSeg7: boolean;
     FRMCElement:TOLEDPotentiometer;

     procedure SetKnobShape(Value:TOLEDKnobShape);
     function  GetKnobShape:TOLEDKnobShape;
     function GetKnobEditor:TKnobEditor;
     procedure SetValue(aValue:integer);virtual;

     procedure SetSliderColor(Value:TColor);
     function GetSliderColor: TColor;
    procedure HandleOnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HandleOnMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure HandleOnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetButtonColorOff(Value:TColor);
    function GetButtonColorOff:TColor;
    procedure SetButtonColorOn (Value:TColor);
    function GetButtonColorOn:TColor;
//    function GetOptions:TOptions;
//    procedure SetOptions(Value:TOptions);
    procedure OnShapeValueChanged(Sender: TObject; value: integer);
    procedure SetTextWithSeg7(Value:boolean);
    function  GetTextWithSeg7:boolean;
  public
     {property } DiscretePoints:integer;

     function BackColor:TColor;
     property  KnobEditor: TKnobEditor read GetKnobEditor;
     procedure DefaultWH(VAR w,h:integer);virtual;
     procedure SetCaption(value:string);
     property BeforeOnPaint: TonBeforePaint read FonBeforePaint write FonBeforePaint;
     constructor Create(AOwner : TComponent); override;
     procedure Paint;override;
     procedure SetAttributeValue(msg:integer;value:integer);
     procedure CopyOptions(source:TOLEDPotentiometer);
     procedure SetOverlayR1(r1:integer);
     procedure SetOverlayR2(r2:integer);
     procedure SetOverlayShape(shape:integer);
  published
//     property  Options: TOptions read GetOptions write SetOptions;
     property  ButtonColorOff:TColor read GetButtonColorOff write SetButtonColorOff;
     property  ButtonColorOn:TColor read GetButtonColorOn write SetButtonColorOn;
     property  SliderColor:TColor read GetSliderColor write SetSliderColor;
     property  TextWithSeg7: boolean read GetTextWithSeg7 write SetTextWithSeg7;
     property  Shape:TOLEDKnobShape read GetKnobShape write SetKnobShape;

     property  OnChanged: TOnChanged read FOnChanged write FOnChanged;
     property  MinValue:integer read FMinValue write FMinValue;
     property  MaxValue:integer read FMaxValue write FMaxValue;
     property  Value:integer read FValue write SetValue;
     property  OverLayR1: integer read FOverlayR1 write SetOverlayR1;
     property  OverLayR2: integer read FOverlayR2 write SetOverlayR2;
     property  OverLayShape: integer read FOverlayShape write SetOverlayShape;

  end;

type   TVCLBitmap = Vcl.Graphics.TBitmap;
       ArrayOfInteger = TArray<integer>;

//procedure Register;

implementation

{$R RMC.RES}

uses Windows,Math;
//type TVCLBitmap = Vcl.Graphics.TBitmap;

//procedure Register;
//begin
//  RegisterComponents('RMC', [TOLEDPotentiometer]);
//end;

procedure TOLEDPotentiometer.SetAttributeValue(msg, value: integer);
begin
  if FRMCShape<>NIL then FRMCShape.SetAttributeValue(msg,value);
end;

procedure TOLEDPotentiometer.SetButtonColorOff(Value: TColor);
begin
  FButtonColorOff:=Value;
  Invalidate;
end;

procedure TOLEDPotentiometer.SetButtonColorOn(Value: TColor);
begin
  FButtonColorOn:=Value;
  Invalidate;
end;

procedure TOLEDPotentiometer.SetCaption(value: string);
begin
  if value<>Caption then
  begin
    Caption:=value;
    Invalidate;
  end;
end;

function TOLEDPotentiometer.GetKnobShape: TOLEDKnobShape;
begin
  result:=FShape;
end;

function TOLEDPotentiometer.GetSliderColor: TColor;
begin
  result:=FSliderColor;
end;

function TOLEDPotentiometer.GetTextWithSeg7: boolean;
begin
  result:=FTextWithSeg7;
end;

procedure TOLEDPotentiometer.HandleOnMouseDown(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
begin
  if FRMCShape<>NIL then FRMCShape.OnMouseDown(Sender,Button,Shift,X, Y);
end;

procedure TOLEDPotentiometer.HandleOnMouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);
begin
  if FRMCShape<>NIL then FRMCShape.OnMouseMove(Sender,Shift,X, Y);
end;

procedure TOLEDPotentiometer.HandleOnMouseUp(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
begin
  if FRMCShape<>NIL then FRMCShape.OnMouseUp(Sender,Button,Shift,X, Y);
end;

procedure TOLEDPotentiometer.OnShapeValueChanged(Sender:TObject;value:integer);
VAR newIndex:integer;
begin
  self.Value:=value;
  if assigned(FonChanged) then
  begin
    if DiscretePoints > 1 then
    begin
      NewIndex:=round((DiscretePoints-1)*value/127);
      if NewIndex = FDiscreteIndex then exit;
      FDiscreteIndex:=NewIndex;
      value:= round(127*NewIndex / (DiscretePoints-1));
    end;
    FonChanged(self,Index,Value);
  end;
end;

procedure TOLEDPotentiometer.SetKnobShape(Value: TOLEDKnobShape);
begin
  if (Shape = Value) and (FRMCShape<>NIL) then exit;
  if FRMCShape<>NIL then FRMCShape.Free;
  FRMCShape:=CreateShape(self,Value,OnShapeValueChanged);
  FShape:=Value;
  Invalidate;
end;

function TOLEDPotentiometer.GetButtonColorOff: TColor;
begin
  result:=FButtonColorOff;
end;

function TOLEDPotentiometer.GetButtonColorOn: TColor;
begin
  result:=FButtonColorOn;
end;

function TOLEDPotentiometer.GetKnobEditor: TKnobEditor;
VAR p:TWinControl;
begin
  p:=parent;
  result:=NIL;
  while p<>NIL do
  begin
    if p is TWinControlOLED then result:=TWinControlOLED(P).GetKnobEditor;
    p:=p.parent;
  end;
end;

procedure TOLEDPotentiometer.SetTextWithSeg7(Value: boolean);
begin
  if TextWithSeg7 = Value then exit;
  FTextWithSeg7 := Value;
  Invalidate;
end;

procedure TOLEDPotentiometer.SetOverlayR1(r1: integer);
begin
  FOverlayR1:=r1;
  Invalidate;
end;

procedure TOLEDPotentiometer.SetOverlayR2(r2: integer);
begin
  FOverlayR2:=r2;
  Invalidate;
end;

procedure TOLEDPotentiometer.SetOverlayShape(shape: integer);
begin
  FOverlayShape:=shape;
  Invalidate;
end;

procedure TOLEDPotentiometer.DefaultWH(var w, h: integer);
begin
  w:=64;
  h:=64;
  if FRMCShape<>NIL then FRMCShape.DefaultWH(w, h)
end;

procedure TOLEDPotentiometer.CopyOptions(source: TOLEDPotentiometer);
begin
  SliderColor:=source.SliderColor;
  ButtonColorOff:=source.ButtonColorOff;
  ButtonColorOn:=source.ButtonColorOn;
  TextWithSeg7:=source.TextWithSeg7;
  Shape:=source.Shape;
end;

constructor TOLEDPotentiometer.Create(AOwner : TComponent);
begin
  FRMCShape:=NIL;
  inherited;
  DiscretePoints:=0;
  Cursor:=crHandPoint;
  OnMouseDown:=HandleOnMouseDown;
  OnMouseMove:=HandleOnMouseMove;
  OnMouseUp  :=HandleOnMouseUp;
  Fvalue:=0;
  SliderColor:=clwhite;
  FmaxValue:=127;
  Color := clNone;
end;


procedure TOLEDPotentiometer.Paint;
begin
  inherited;
  if assigned(BeforeOnPaint) then BeforeOnPaint(self);
  if FRMCShape<>NIL then
     FRMCShape.Paint;
end;

procedure TOLEDPotentiometer.SetSliderColor(Value: TColor);
begin
  if SliderColor = Value then exit;
  FSliderColor:=Value;
  Invalidate;
end;

procedure TOLEDPotentiometer.SetValue(aValue: integer);
begin
  if aValue<minValue then exit;
  if aValue>maxValue then exit;
  if FValue = aValue then exit;
  FValue:=aValue;
  if FRMCShape<>NIL then FRMCShape.SetValue(aValue);
  Invalidate;
end;

{ TOLEDPotentiometer }

constructor TOLEDElementBase.Create(AOwner: TComponent);
begin
  inherited;
//  DoubleBuffered:=true;
  AutoSize:=false;
  FWScale:=1;
  FHScale:=1;
end;

procedure TOLEDElementBase.SetScale(w,h:double);

begin
  if w<0.3 then exit;
  FWScale := w;
  if h<0.3 then exit;
  FHScale := h;
  Resize;
end;

procedure TOLEDElementBase.SetPosition(value: TRect);
begin
  FPosition:=value;
  Resize;
end;

procedure TOLEDElementBase.Resize;
begin
  SetBounds(round(FPosition.left*FWscale),round(FPosition.top*FHscale),round((FPosition.right-FPosition.left)*FWscale),round((FPosition.bottom-FPosition.top)*FHscale));
end;

{ TRMCElementRolandKnob }

function TOLEDPotentiometer.BackColor: TColor;
begin
  if Color = clNone then
    result:=parent.Brush.Color
  else
    result:=Color;
end;

{ TOptions }

constructor TOptions.Create(RMCElement: TOLEDPotentiometer);
begin
  FRMCElement:=RMCElement;
end;

procedure TOptions.SetButtonColorOff(value: Tcolor);
begin
  FButtonColorOff:=value;
  FRMCElement.Invalidate;
end;

procedure TOptions.SetButtonColorOn(value: Tcolor);
begin
  FButtonColorOn:=value;
  FRMCElement.Invalidate;
end;

procedure TOptions.SetShape(value: TOLEDKnobShape);
begin
  FShape:=value;
  FRMCElement.Shape:=Value;
end;

procedure TOptions.SetSliderColor(value: Tcolor);
begin
  FSliderColor:=value;
  FRMCElement.Invalidate;
end;

procedure TOptions.SetTextWithSeg7(value: boolean);
begin
  FTextWithSeg7:=value;
  FRMCElement.Invalidate;
end;

begin
end.



