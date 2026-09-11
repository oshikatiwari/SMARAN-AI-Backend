import 'dart:math';

/// Manages the flip tween for a single card.
///
/// Pure Dart class — no Flutter or Flame imports. Driven by the Flame
/// game loop via [update(dt)].
///
/// Flip model:
///   Progress 0.0 → 0.5: front face scales from 1.0 → 0.0 (card disappears)
///   Progress 0.5 → 1.0: back face scales from 0.0 → 1.0 (other side appears)
///
/// The [scaleX] getter returns the horizontal scale factor for the card's
/// render method. [isFaceUp] flips at exactly progress = 0.5.
///
/// Usage in [CardComponent]:
///   _flipAnimation.startFlip(toFaceUp: true);
///   // In update():  _flipAnimation.update(dt);
///   // In render():  canvas.scale(_flipAnimation.scaleX, 1.0);
final class CardFlipAnimation {
  CardFlipAnimation({
    this.flipDurationSeconds = 0.35,
  });

  /// Total time (seconds) for one complete flip. Keep ≥ 0.3 for elderly users.
  final double flipDurationSeconds;

  double _progress = 0.0;     // 0.0 = fully face-down, 1.0 = fully face-up
  bool _isAnimating = false;
  bool _targetFaceUp = false;
  bool _isFaceUp = false;     // current logical state

  // ── Public API ────────────────────────────────────────────────────────────

  /// Whether the card is currently mid-animation.
  bool get isAnimating => _isAnimating;

  /// Whether the card is showing its face (post-flip).
  bool get isFaceUp => _isFaceUp;

  /// Horizontal scale factor to apply during render.
  ///
  /// Returns a value in [-1.0, 1.0]:
  ///   Positive = showing current face
  ///   Passes through 0.0 at progress = 0.5 (the "middle" of the flip)
  double get scaleX {
    if (!_isAnimating) return _isFaceUp ? 1.0 : 1.0;
    // Progress 0.0 → 0.5: cos(progress × π) goes 1 → -1, abs → 1 → 0
    // Progress 0.5 → 1.0: cos(progress × π) goes -1 → 1, abs → 0 → 1
    // We use cos to get a smooth S-curve; abs because we only squish, never mirror.
    return cos(_progress * pi).abs();
  }

  /// True when progress has passed the halfway point (face has switched).
  bool get isMidFlip => _progress >= 0.5;

  /// Starts a flip toward [toFaceUp].
  ///
  /// If the card is already in the target state and not animating, no-op.
  /// If called during an in-progress animation, the animation continues
  /// (avoids janky direction reversal).
  void startFlip({required final bool toFaceUp}) {
    if (_isAnimating) return; // don't interrupt
    if (_isFaceUp == toFaceUp) return; // already there

    _targetFaceUp = toFaceUp;
    _progress = 0.0;
    _isAnimating = true;
  }

  /// Advances the animation by [dt] seconds. Call from [Component.update].
  void update(final double dt) {
    if (!_isAnimating) return;

    _progress += dt / flipDurationSeconds;

    // At the midpoint, switch the logical face so render draws the new side.
    if (_progress >= 0.5 && _isFaceUp != _targetFaceUp) {
      _isFaceUp = _targetFaceUp;
    }

    if (_progress >= 1.0) {
      _progress = 1.0;
      _isAnimating = false;
    }
  }

  /// Instantly sets the card to face-down with no animation.
  void resetToFaceDown() {
    _progress = 0.0;
    _isAnimating = false;
    _isFaceUp = false;
    _targetFaceUp = false;
  }

  /// Instantly sets the card to face-up with no animation.
  void setFaceUpInstant() {
    _progress = 1.0;
    _isAnimating = false;
    _isFaceUp = true;
    _targetFaceUp = true;
  }
}
