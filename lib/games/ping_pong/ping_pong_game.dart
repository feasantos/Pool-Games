import 'dart:math';

enum PingPongStatus { idle, playing, p1Wins, p2Wins }

class PingPongGame {
  static const int winScore = 7;
  static const double ballR = 8.0;
  static const double paddleH = 14.0;
  static const double paddleMargin = 36.0;
  static const double paddleWRatio = 0.28;
  static const double initSpeed = 5.0;
  static const double speedStep = 0.25;
  static const double maxSpeed = 9.5;
  static const double aiMaxSpeed = 4.2;

  final _rng = Random();

  double width = 0;
  double height = 0;
  double ballX = 0;
  double ballY = 0;
  double ballDx = 0;
  double ballDy = 0;
  double ballSpeed = initSpeed;
  double p1X = 0;
  double p2X = 0;
  int p1Score = 0;
  int p2Score = 0;
  PingPongStatus status = PingPongStatus.idle;
  bool twoPlayer = false;

  double get paddleW => width * paddleWRatio;
  double get p2Top => paddleMargin;
  double get p2Bottom => paddleMargin + paddleH;
  double get p1Top => height - paddleMargin - paddleH;
  double get p1Bottom => height - paddleMargin;

  void init(double w, double h) {
    width = w;
    height = h;
    p1X = (w - paddleW) / 2;
    p2X = (w - paddleW) / 2;
    p1Score = 0;
    p2Score = 0;
    status = PingPongStatus.idle;
    _resetBall(toward: 1);
  }

  void _resetBall({required int toward}) {
    ballX = width / 2;
    ballY = height / 2;
    ballSpeed = initSpeed;
    final a = (_rng.nextDouble() * 40 - 20) * pi / 180;
    ballDx = sin(a) * ballSpeed;
    ballDy = cos(a) * ballSpeed * toward;
  }

  void update() {
    if (status != PingPongStatus.playing) return;

    ballX += ballDx;
    ballY += ballDy;

    // Side walls
    if (ballX - ballR <= 0) {
      ballX = ballR;
      ballDx = ballDx.abs();
    } else if (ballX + ballR >= width) {
      ballX = width - ballR;
      ballDx = -ballDx.abs();
    }

    // P1 paddle (bottom) — ball moving down
    if (ballDy > 0 &&
        ballY + ballR >= p1Top &&
        ballY - ballR <= p1Bottom &&
        ballX + ballR > p1X &&
        ballX - ballR < p1X + paddleW) {
      _bounceOffPaddle(p1X, isBottom: true);
      ballY = p1Top - ballR;
    }

    // P2 paddle (top) — ball moving up
    if (ballDy < 0 &&
        ballY - ballR <= p2Bottom &&
        ballY + ballR >= p2Top &&
        ballX + ballR > p2X &&
        ballX - ballR < p2X + paddleW) {
      _bounceOffPaddle(p2X, isBottom: false);
      ballY = p2Bottom + ballR;
    }

    if (!twoPlayer) _moveAI();

    if (ballY - ballR > height) {
      p2Score++;
      _afterScore(p2Scored: true);
    } else if (ballY + ballR < 0) {
      p1Score++;
      _afterScore(p2Scored: false);
    }
  }

  void _bounceOffPaddle(double paddleX, {required bool isBottom}) {
    final t =
        ((ballX - (paddleX + paddleW / 2)) / (paddleW / 2)).clamp(-1.0, 1.0);
    final a = t * 60 * pi / 180;
    ballSpeed = (ballSpeed + speedStep).clamp(initSpeed, maxSpeed);
    ballDx = sin(a) * ballSpeed;
    ballDy = isBottom
        ? -cos(a).abs() * ballSpeed
        : cos(a).abs() * ballSpeed;
  }

  void _moveAI() {
    final target = ballX - paddleW / 2;
    final diff = target - p2X;
    p2X = (diff.abs() <= aiMaxSpeed
            ? target
            : p2X + (diff > 0 ? aiMaxSpeed : -aiMaxSpeed))
        .clamp(0, width - paddleW);
  }

  void _afterScore({required bool p2Scored}) {
    if (p1Score >= winScore) {
      status = PingPongStatus.p1Wins;
    } else if (p2Score >= winScore) {
      status = PingPongStatus.p2Wins;
    } else {
      _resetBall(toward: p2Scored ? 1 : -1);
    }
  }

  void setP1Paddle(double touchX) {
    p1X = (touchX - paddleW / 2).clamp(0, width - paddleW);
  }

  void setP2Paddle(double touchX) {
    p2X = (touchX - paddleW / 2).clamp(0, width - paddleW);
  }

  void start() {
    _resetBall(toward: 1);
    status = PingPongStatus.playing;
  }

  void restart() {
    p1Score = 0;
    p2Score = 0;
    p1X = (width - paddleW) / 2;
    p2X = (width - paddleW) / 2;
    start();
  }
}
