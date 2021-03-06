package robotlegs.bender.extensions.display.base.impl;

import openfl.Lib;
import openfl.events.Event;
import msignal.Signal.Signal0;
import robotlegs.bender.extensions.contextView.ContextView;
import robotlegs.bender.extensions.display.base.api.ILayers;
import robotlegs.bender.extensions.display.base.api.IRenderContext;
import robotlegs.bender.extensions.display.base.api.IRenderer;
import robotlegs.bender.extensions.display.base.api.IViewport;
import robotlegs.bender.framework.api.IInjector;
import robotlegs.bender.framework.api.IContext;
import robotlegs.bender.framework.api.ILogger;

/**
 * ...
 * @author P.J.Shand
 * 
 */
@:rtti
@:keepSub
class Renderer implements IRenderer
{
	@inject public var contextView:ContextView;
	@inject public var viewport:IViewport;
	@inject public var renderContext:IRenderContext;
	@inject public var layers:ILayers;
	
	@:isVar public var onActiveChange(get, null):Signal0;
	@:isVar public var active(get, set):Bool = true;
	
	public var prePresent = new Signal0();
	public var postPresent = new Signal0();
	
	private static var count:Int = -1;
	private var index:Int = 0;
	
	public var frameRate:Null<Int>;
	var skip:Int = 1;
	var renderCount:Int = 0;
	var renderMod:Int = 0;
	
	public function new(context:IContext)
	{
		count++;
		index = count;
	}
	
	public function start():Void
	{
		contextView.view.stage.addEventListener(Event.ENTER_FRAME, Update);	
	}
	
	public function stop():Void
	{
		contextView.view.stage.removeEventListener(Event.ENTER_FRAME, Update);
	}
	
	public function render():Void
	{
		Update(null);
	}
	
	private function Update(e:Event):Void 
	{
		if (!renderContext.available) return;
		
		if (frameRate != null){
			skip = Math.floor(Lib.current.stage.frameRate / frameRate);
			renderMod = renderCount % skip;
		}
		
		if (renderCount % skip == 0){
			if (index == count) {
				renderContext.begin();
				
			}
			if (active){
				for (i in 0...layers.layers.length) 
				{
					// in some instances context3D is set to null in this loop
					if (!renderContext.available) return;
					if (layers.layers[i].active){
						layers.layers[i].process();
					}
				}
			}
			prePresent.dispatch();
			if (index == 0) {
				renderContext.end();
			}
			postPresent.dispatch();
		}
		
		if (index == 0) {
			renderCount++;
		}
	}
	
	private function get_active():Bool 
	{
		return active;
	}
	
	private function set_active(value:Bool):Bool 
	{
		if (active == value) return value;
		active = value;
		onActiveChange.dispatch();
		if (active) count++;
		else count--;
		return active;
	}
	
	private function get_onActiveChange():Signal0 
	{
		return onActiveChange;
	}
}