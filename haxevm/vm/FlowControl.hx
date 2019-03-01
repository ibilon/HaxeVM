package haxevm.vm;

enum FlowControl
{
	FCReturn(v:EVal);
	FCBreak;
	FCContinue;
	FCThrow(v:EVal);
}
