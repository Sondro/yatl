package yatl;

/**
 * Basic tweener
 * Is implementation agnostic, hence you need to come up with update system for it yourself.
 */
class Tween
{
  
  private var _duration:Float;
  private var _elapsed:Float;
  private var _t:Float;
  private var _percent:Float;
  
  /** Fired when start() fuction called and tweener reset/was not running.. */
  public dynamic function onStart(t:Tween):Void { }
  /** Fired when tweener finishes. */
  public dynamic function onFinish(t:Tween):Void { }
  /** Fired after tweener calls apply(). */
  public dynamic function onUpdate(t:Tween):Void { }
  /** Fired when cancel() function called and tweener was not idle. */ 
  public dynamic function onCancel(t:Tween):Void { }
  /** Fired when tweener was paused. */
  public dynamic function onPause(t:Tween):Void { }
  /** Fired when tweener was unpaused. */
  public dynamic function onUnpause(t:Tween):Void { }
  
  /** Returns the progress of the tweener (value between 0..1)*/
  public var percent(get, set):Float;
  private inline function get_percent():Float return _percent;
  private function set_percent(v:Float):Float
  {
    if (v < 0) v = 0;
    else if (v > 1) v = 1;
    _percent = v;
    _elapsed = _duration * v;
    _t = applyEase(v);
    if (state == TweenState.Running)
    {
      apply();
      onUpdate(this);
    }
    return v;
  }
  
  /** Returns the progress of the tweener with applied easing function. **/
  public var t(get, never):Float;
  private inline function get_t():Float return _t;
  /** Returns total time elapsed since start. **/
  public var elapsed(get, never):Float;
  private inline function get_elapsed():Float return _elapsed;
  
  /** Easing function applicable to t variable.**/
  public var ease:Float->Float;
  private inline function applyEase(v:Float):Float return ease != null ? ease(v) : v;
  
  /** Current tween state. **/
  public var state(default, null):TweenState;
  
  public var isRunning(get, never):Bool;
  public var isPaused(get, set):Bool;
  private inline function get_isRunning():Bool return state == TweenState.Running;
  private inline function get_isPaused():Bool return state == TweenState.Paused;
  private function set_isPaused(v:Bool):Bool
  {
    if (state == TweenState.Idle) return false;
    else
    {
      var newState:TweenState = v ? TweenState.Paused : TweenState.Running;
      if (newState != state)
      {
        state = newState;
        if (v) onPause(this);
        else onUnpause(this);
      }
      return v;
    }
  }
  
  // Todo: Reverse
  
  public function new(duration:Float = 1, ?ease:Float->Float)
  {
    this._elapsed = 0;
    this._duration = duration;
    this.ease = ease;
    this.state = TweenState.Idle;
  }
  
  public function init(?duration:Float, ?ease:Float->Float)
  {
    if (duration != null) this._duration = duration;
    this.ease = ease;
  }
  
  /** Starts the tween if reset == true or state == idle, otherwise resumes tween if it's paused. 
    * Note that it calls apply() and all corresponding callbacks on start. **/
  public function start(reset:Bool = true):Void
  {
    if (reset || state == TweenState.Idle)
    {
      _elapsed = 0;
      _percent = 0;
      _t = applyEase(0);
      state = TweenState.Running;
      onStart(this);
      apply();
      onUpdate(this);
    }
    else if (state == TweenState.Paused) resume();
    
  }
  
  /** Pauses the tween if it's currently running. **/
  public inline function pause():Void
  {
    if (state == TweenState.Running)
    {
      state = TweenState.Paused;
      onPause(this);
    }
  }
  
  /** Resumes the tween if it's currently paused. **/
  public inline function resume():Void
  {
    if (state == TweenState.Paused)
    {
      state = TweenState.Running;
      onUnpause(this);
    }
  }
  
  /** Update the tween with specified delta-time. **/
  public function update(delta:Float):Void
  {
    if (state == TweenState.Running)
    {
      _elapsed += delta;
      
      if (_elapsed > _duration)
      {
        _elapsed = _duration;
        _percent = 1;
        _t = applyEase(1);
        apply();
        onUpdate(this);
        state = TweenState.Idle;
        onTweenFinish();
        onFinish(this);
      }
      else
      {
        _percent = _elapsed / _duration;
        _t = applyEase(_percent);
        apply();
        onUpdate(this);
      }
    }
  }
  
  /** Cancel the tween if it's paused or running. **/
  public function cancel():Void
  {
    if (state != TweenState.Idle)
    {
      state = TweenState.Idle;
      onTweenCancel();
      onCancel(this);
    }
  }
  
  /** Override this to apply your logic during update tick. **/
  private function apply():Void
  {
    // Actual tweener logic.
  }
  
  /** Called when tween was cancelled. Use it to dispose of the data. **/
  private function onTweenCancel():Void
  {
    
  }
  
  /** Called when tween has been finished. Use it to dispose of the data or do post-tween mumbo-jumbo. **/
  private function onTweenFinish():Void
  {
    
  }
  
}
