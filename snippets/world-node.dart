// title: World-Node
// description: Eine sich drehende Erde
// category: layouts
// tags: earth
// author: John Doe
// featured: false
// prompt: Tetsprompt
// model: claude-opus-4.7

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: Center(child: SpinningGlobeBackground()),
      ),
    );
  }
}

class SpinningGlobeBackground extends StatefulWidget {
  final ScrollController? scrollController;

  final double ambientSpin;
  final double scrollSensitivity;
  final double decaySeconds;

  final bool atmosphere;
  final bool arcs;
  final bool pulse;
  final bool terminator;
  final bool shootingStars;
  final bool scrollBurst;

  final Color background;
  final Color landColor;
  final Color cityColor;
  final Color atmosphereColor;

  final double sizeFraction;
  final double axisTiltDegrees;

  const SpinningGlobeBackground({
    super.key,
    this.scrollController,
    this.ambientSpin = 0.16,
    this.scrollSensitivity = 0.003,
    this.decaySeconds = 1.0,
    this.atmosphere = true,
    this.arcs = true,
    this.pulse = true,
    this.terminator = true,
    this.shootingStars = true,
    this.scrollBurst = true,
    this.background = const Color(0xFF0A0907),
    this.landColor = const Color(0xFF3A342B),
    this.cityColor = const Color(0xFFFFB64D),
    this.atmosphereColor = const Color(0xFFFF9B3D),
    this.sizeFraction = 0.85,
    this.axisTiltDegrees = 23.4,
  });

  @override
  State<SpinningGlobeBackground> createState() =>
      _SpinningGlobeBackgroundState();
}

class _Arc {
  final int a;
  final int b;
  final double start; // seconds
  final double life;
  _Arc(this.a, this.b, this.start, this.life);
}

class _Shooter {
  double x, y, vx, vy, life = 0, max;
  _Shooter(this.x, this.y, this.vx, this.vy, this.max);
}

class _SpinningGlobeBackgroundState extends State<SpinningGlobeBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _lastTickSet = false;

  double _rotation = 0;
  double _extraVelocity = 0;
  double _lastScrollOffset = 0;

  // Animation state
  double _nowT = 0;
  double _terminatorPhase = 0;
  double _burst = 0;
  final List<_Arc> _arcs = [];
  final List<_Shooter> _shooters = [];
  final math.Random _rng = math.Random();

  Offset? _pointer;
  int? _hoverCityIndex;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
    _lastScrollOffset = widget.scrollController?.offset ?? 0;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant SpinningGlobeBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
      _lastScrollOffset = widget.scrollController?.offset ?? 0;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final c = widget.scrollController;
    if (c == null || !c.hasClients) return;
    final off = c.offset;
    final delta = off - _lastScrollOffset;
    _lastScrollOffset = off;
    _extraVelocity += delta * widget.scrollSensitivity;
    _extraVelocity = _extraVelocity.clamp(-6.0, 6.0);
    if (widget.scrollBurst && delta.abs() > 6) {
      _burst = math.min(1, _burst + delta.abs() / 400);
    }
  }

  void _spawnArc() {
    if (kCities.isEmpty) return;
    final a = _rng.nextInt(kCities.length);
    int b = _rng.nextInt(kCities.length);
    if (b == a) b = (a + 1) % kCities.length;
    _arcs.add(_Arc(a, b, _nowT, 2.4 + _rng.nextDouble() * 1.6));
  }

  void _spawnShooter(Size size) {
    final sx = _rng.nextDouble() * size.width;
    final sy = _rng.nextDouble() * size.height * 0.5;
    final angle = (20 + _rng.nextDouble() * 30) * math.pi / 180;
    final speed = 800 + _rng.nextDouble() * 600;
    _shooters.add(
      _Shooter(
        sx,
        sy,
        math.cos(angle) * speed,
        math.sin(angle) * speed,
        0.6 + _rng.nextDouble() * 0.4,
      ),
    );
  }

  void _onTick(Duration elapsed) {
    final double dt;
    if (!_lastTickSet) {
      dt = 0.016;
      _lastTickSet = true;
    } else {
      dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    }
    _lastTick = elapsed;
    _nowT += dt;

    final tau = widget.decaySeconds.clamp(0.05, 10.0);
    _extraVelocity *= math.exp(-dt / tau);
    if (_extraVelocity.abs() < 1e-4) _extraVelocity = 0;
    _rotation += (widget.ambientSpin + _extraVelocity) * dt;

    _burst *= math.exp(-dt / 0.35);
    _terminatorPhase += dt * 0.12;

    if (widget.arcs &&
        _arcs.length < 4 &&
        _rng.nextDouble() < dt * 1.1) {
      _spawnArc();
    }
    _arcs.removeWhere((a) => _nowT - a.start > a.life);

    if (widget.shootingStars &&
        _rng.nextDouble() < dt * 0.25 &&
        _lastSize != Size.zero) {
      _spawnShooter(_lastSize);
    }
    for (final s in _shooters) {
      s.life += dt;
      s.x += s.vx * dt;
      s.y += s.vy * dt;
    }
    _shooters.removeWhere((s) => s.life > s.max);

    if (mounted) setState(() {});
  }

  void _pickCity(Offset p, Size size, double hit) {
    final proj = _Projection.fromSize(
      size,
      widget.sizeFraction,
      widget.axisTiltDegrees * math.pi / 180,
      _rotation,
    );
    int? best;
    double bestDist = hit * hit;
    for (int i = 0; i < kCities.length; i++) {
      final c = kCities[i];
      final pos = proj.project(c.lat, c.lng);
      if (pos == null) continue;
      final dx = pos.dx - p.dx;
      final dy = pos.dy - p.dy;
      final d2 = dx * dx + dy * dy;
      if (d2 < bestDist) {
        bestDist = d2;
        best = i;
      }
    }
    _hoverCityIndex = best;
    _pointer = p;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cons) {
      final size = Size(cons.maxWidth, cons.maxHeight);
      _lastSize = size;
      return MouseRegion(
        onHover: (e) {
          setState(() => _pickCity(e.localPosition, size, 14));
        },
        onExit: (_) => setState(() {
          _hoverCityIndex = null;
          _pointer = null;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (d) {
            setState(() => _pickCity(d.localPosition, size, 18));
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GlobePainter(
                    rotation: _rotation,
                    axisTilt: widget.axisTiltDegrees * math.pi / 180,
                    sizeFraction: widget.sizeFraction,
                    background: widget.background,
                    landColor: widget.landColor,
                    cityColor: widget.cityColor,
                    atmosphereColor: widget.atmosphereColor,
                    atmosphere: widget.atmosphere,
                    showArcs: widget.arcs,
                    showPulse: widget.pulse,
                    showTerminator: widget.terminator,
                    highlightedCityIndex: _hoverCityIndex,
                    nowT: _nowT,
                    terminatorPhase: _terminatorPhase,
                    burst: _burst,
                    arcs: _arcs,
                    shooters: _shooters,
                  ),
                ),
              ),
              if (_hoverCityIndex != null && _pointer != null)
                Positioned(
                  left: _pointer!.dx + 14,
                  top: _pointer!.dy - 28,
                  child: IgnorePointer(
                    child: _CityLabel(
                      name: kCities[_hoverCityIndex!].name,
                      color: widget.cityColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _CityLabel extends StatelessWidget {
  final String name;
  final Color color;
  const _CityLabel({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xE6100E0B),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          letterSpacing: 1.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Projection
// ---------------------------------------------------------------------------

class _Projection {
  final Offset center;
  final double radius;
  final double lambda0;
  final double axisTilt;
  final double ct;
  final double st;

  _Projection({
    required this.center,
    required this.radius,
    required this.lambda0,
    required this.axisTilt,
  })  : ct = math.cos(axisTilt),
        st = math.sin(axisTilt);

  factory _Projection.fromSize(
    Size size,
    double sizeFraction,
    double axisTilt,
    double rotation,
  ) {
    final r = math.min(size.width, size.height) * sizeFraction / 2;
    return _Projection(
      center: Offset(size.width / 2, size.height / 2),
      radius: r,
      lambda0: rotation,
      axisTilt: axisTilt,
    );
  }

  Offset? project(double lat, double lng) {
    final r = projectWithDepth(lat, lng);
    return r?.pos;
  }

  ({Offset pos, double depth})? projectWithDepth(double lat, double lng) {
    final phi = lat * math.pi / 180;
    final lam = lng * math.pi / 180 + lambda0;
    final cp = math.cos(phi);
    final sx = cp * math.sin(lam);
    final sy = math.sin(phi);
    final sz = cp * math.cos(lam);
    final ry = sy * ct - sz * st;
    final rz = sy * st + sz * ct;
    if (rz < 0) return null;
    return (
      pos: Offset(center.dx + sx * radius, center.dy - ry * radius),
      depth: rz,
    );
  }

  /// Project a unit 3D vector (already rotated around y by lambda0 implicitly
  /// — caller handles that) with altitude lift > 1 allowed.
  ({Offset pos, double depth}) projectVec(double x, double y, double z) {
    final ry = y * ct - z * st;
    final rz = y * st + z * ct;
    return (
      pos: Offset(center.dx + x * radius, center.dy - ry * radius),
      depth: rz,
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _GlobePainter extends CustomPainter {
  final double rotation;
  final double axisTilt;
  final double sizeFraction;
  final Color background;
  final Color landColor;
  final Color cityColor;
  final Color atmosphereColor;
  final bool atmosphere;
  final bool showArcs;
  final bool showPulse;
  final bool showTerminator;
  final int? highlightedCityIndex;
  final double nowT;
  final double terminatorPhase;
  final double burst;
  final List<_Arc> arcs;
  final List<_Shooter> shooters;

  _GlobePainter({
    required this.rotation,
    required this.axisTilt,
    required this.sizeFraction,
    required this.background,
    required this.landColor,
    required this.cityColor,
    required this.atmosphereColor,
    required this.atmosphere,
    required this.showArcs,
    required this.showPulse,
    required this.showTerminator,
    required this.highlightedCityIndex,
    required this.nowT,
    required this.terminatorPhase,
    required this.burst,
    required this.arcs,
    required this.shooters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = background;
    canvas.drawRect(Offset.zero & size, bg);

    final proj = _Projection.fromSize(size, sizeFraction, axisTilt, rotation);
    final cx = proj.center.dx, cy = proj.center.dy, R = proj.radius;

    // Atmosphere glow
    if (atmosphere) {
      final glowR = R * 1.28;
      final shader = RadialGradient(
        colors: [
          atmosphereColor.withOpacity(0.30),
          atmosphereColor.withOpacity(0.08),
          atmosphereColor.withOpacity(0.0),
        ],
        stops: const [0.72, 0.88, 1.0],
      ).createShader(Rect.fromCircle(center: proj.center, radius: glowR));
      canvas.drawCircle(proj.center, glowR, Paint()..shader = shader);
    }

    // Ocean disc
    final oceanPaint = Paint()
      ..color = Color.lerp(background, landColor, 0.10) ?? background;
    canvas.drawCircle(proj.center, R, oceanPaint);

    // Graticule
    _drawGraticule(canvas, proj);

    // Continents
    final landPaint = Paint()..style = PaintingStyle.fill;
    for (final pt in kContinentDots) {
      final res = proj.projectWithDepth(pt[1], pt[0]);
      if (res == null) continue;
      final t = res.depth.clamp(0.0, 1.0);
      final r = 0.9 + t * 1.0;
      landPaint.color = Color.lerp(background, landColor, 0.35 + 0.65 * t)!;
      canvas.drawCircle(res.pos, r, landPaint);
    }

    // Cities
    final pulsePhase = nowT * 1.2;
    for (int i = 0; i < kCities.length; i++) {
      final c = kCities[i];
      final res = proj.projectWithDepth(c.lat, c.lng);
      if (res == null) continue;
      final t = res.depth.clamp(0.0, 1.0);
      if (t < 0.05) continue;
      final isHi = i == highlightedCityIndex;

      if (showPulse) {
        final local = (pulsePhase + i * 0.37) % 2.6;
        if (local < 1.3) {
          final tt = local / 1.3;
          final rr = (isHi ? 10 : 6) + tt * (isHi ? 22 : 14);
          canvas.drawCircle(
            res.pos,
            rr,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = cityColor.withOpacity((1 - tt) * 0.55 * t),
          );
        }
      }

      // halo
      canvas.drawCircle(
        res.pos,
        (isHi ? 7.0 : 3.2) * (0.55 + 0.45 * t),
        Paint()
          ..color = cityColor.withOpacity(isHi ? 0.45 : 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
      // core
      canvas.drawCircle(
        res.pos,
        (isHi ? 2.4 : 1.5) * (0.6 + 0.4 * t),
        Paint()
          ..color = isHi
              ? const Color(0xFFFFD488)
              : Color.lerp(landColor, cityColor, 0.6 + 0.4 * t)!,
      );
    }

    // Arcs
    if (showArcs) {
      for (final arc in arcs) {
        final age = (nowT - arc.start) / arc.life;
        if (age < 0 || age > 1) continue;
        final ca = kCities[arc.a], cb = kCities[arc.b];
        final head = age.clamp(0.0, 1.0);
        final tail = math.max(0.0, age - 0.35);
        _drawGreatArc(canvas, proj, ca.lat, ca.lng, cb.lat, cb.lng, tail, head, age);
      }
    }

    // Terminator sweep
    if (showTerminator) {
      final ang = terminatorPhase;
      final nx = math.sin(ang), ny = -math.cos(ang) * 0.15;
      final g = Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0x000A0907),
            Color(0x000A0907),
            Color(0x2EFFB45A),
            Color(0x8C0A0907),
            Color(0xBF0A0907),
          ],
          stops: const [0.0, 0.40, 0.50, 0.52, 1.0],
        ).createShader(
          Rect.fromPoints(
            Offset(cx - nx * R * 1.2, cy - ny * R * 1.2),
            Offset(cx + nx * R * 1.2, cy + ny * R * 1.2),
          ),
        );
      canvas.save();
      final path = Path()..addOval(Rect.fromCircle(center: proj.center, radius: R));
      canvas.clipPath(path);
      canvas.drawCircle(proj.center, R, g);
      canvas.restore();
    }

    // Inner rim shadow
    final rimShader = RadialGradient(
      colors: [
        background.withOpacity(0.0),
        background.withOpacity(0.55),
      ],
      stops: const [0.82, 1.0],
    ).createShader(Rect.fromCircle(center: proj.center, radius: R));
    canvas.drawCircle(proj.center, R, Paint()..shader = rimShader);

    // Scroll burst ring
    if (burst > 0.01) {
      final br = R * (1.02 + (1 - burst) * 0.18);
      canvas.drawCircle(
        proj.center,
        br,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + burst * 2
          ..color = cityColor.withOpacity(burst * 0.55),
      );
    }

    // Shooting stars
    for (final s in shooters) {
      final tt = s.life / s.max;
      final alpha = math.sin(tt * math.pi);
      const tailLen = 90.0;
      final ang = math.atan2(s.vy, s.vx);
      final tx = s.x - math.cos(ang) * tailLen;
      final ty = s.y - math.sin(ang) * tailLen;
      final g = Paint()
        ..strokeWidth = 1.4
        ..shader = LinearGradient(
          colors: [
            const Color(0x00FFDCB4),
            Color.fromRGBO(255, 230, 200, alpha),
          ],
        ).createShader(Rect.fromPoints(Offset(tx, ty), Offset(s.x, s.y)));
      canvas.drawLine(Offset(tx, ty), Offset(s.x, s.y), g);
    }
  }

  void _drawGreatArc(
    Canvas canvas,
    _Projection proj,
    double lat1,
    double lng1,
    double lat2,
    double lng2,
    double tStart,
    double tEnd,
    double age,
  ) {
    final phi1 = lat1 * math.pi / 180;
    final lam1 = lng1 * math.pi / 180 + rotation;
    final phi2 = lat2 * math.pi / 180;
    final lam2 = lng2 * math.pi / 180 + rotation;
    final ax = math.cos(phi1) * math.sin(lam1);
    final ay = math.sin(phi1);
    final az = math.cos(phi1) * math.cos(lam1);
    final bx = math.cos(phi2) * math.sin(lam2);
    final by = math.sin(phi2);
    final bz = math.cos(phi2) * math.cos(lam2);
    final dot = (ax * bx + ay * by + az * bz).clamp(-1.0, 1.0);
    final omega = math.acos(dot);
    if (omega < 1e-3) return;
    final sinO = math.sin(omega);
    final maxAlt = 0.18 + 0.12 * math.min(1.0, omega / math.pi);
    const steps = 40;

    final path = Path();
    bool started = false;
    for (int i = 0; i <= steps; i++) {
      final u = i / steps;
      if (u < tStart || u > tEnd) {
        started = false;
        continue;
      }
      final sA = math.sin((1 - u) * omega) / sinO;
      final sB = math.sin(u * omega) / sinO;
      var x = sA * ax + sB * bx;
      var y = sA * ay + sB * by;
      var z = sA * az + sB * bz;
      final n = math.sqrt(x * x + y * y + z * z);
      final alt = 1 + maxAlt * math.sin(u * math.pi);
      x = x / n * alt;
      y = y / n * alt;
      z = z / n * alt;
      final pr = proj.projectVec(x, y, z);
      if (pr.depth < 0) {
        started = false;
        continue;
      }
      if (!started) {
        path.moveTo(pr.pos.dx, pr.pos.dy);
        started = true;
      } else {
        path.lineTo(pr.pos.dx, pr.pos.dy);
      }
    }
    final fade = math.sin(math.pi * age.clamp(0.0, 1.0));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = cityColor.withOpacity(0.55 * fade),
    );
  }

  void _drawGraticule(Canvas canvas, _Projection proj) {
    final p = Paint()
      ..color = landColor.withOpacity(0.14)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (int lat = -60; lat <= 60; lat += 30) {
      final path = Path();
      bool started = false;
      for (int lng = -180; lng <= 180; lng += 6) {
        final pos = proj.project(lat.toDouble(), lng.toDouble());
        if (pos == null) {
          started = false;
          continue;
        }
        if (!started) {
          path.moveTo(pos.dx, pos.dy);
          started = true;
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }
      canvas.drawPath(path, p);
    }
    for (int lng = -180; lng < 180; lng += 30) {
      final path = Path();
      bool started = false;
      for (int lat = -85; lat <= 85; lat += 5) {
        final pos = proj.project(lat.toDouble(), lng.toDouble());
        if (pos == null) {
          started = false;
          continue;
        }
        if (!started) {
          path.moveTo(pos.dx, pos.dy);
          started = true;
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _GlobePainter old) => true;
}

// ---------------------------------------------------------------------------
// City data (~160 major world cities)
// ---------------------------------------------------------------------------

class City {
  final String name;
  final double lat;
  final double lng;
  const City(this.name, this.lat, this.lng);
}

const List<City> kCities = [
  City("New York", 40.7128, -74.006),
  City("Los Angeles", 34.0522, -118.2437),
  City("Chicago", 41.8781, -87.6298),
  City("Houston", 29.7604, -95.3698),
  City("Toronto", 43.6532, -79.3832),
  City("Montreal", 45.5017, -73.5673),
  City("Vancouver", 49.2827, -123.1207),
  City("Mexico City", 19.4326, -99.1332),
  City("San Francisco", 37.7749, -122.4194),
  City("Seattle", 47.6062, -122.3321),
  City("Miami", 25.7617, -80.1918),
  City("Boston", 42.3601, -71.0589),
  City("Washington DC", 38.9072, -77.0369),
  City("Atlanta", 33.749, -84.388),
  City("Dallas", 32.7767, -96.797),
  City("Denver", 39.7392, -104.9903),
  City("Phoenix", 33.4484, -112.074),
  City("Philadelphia", 39.9526, -75.1652),
  City("Guadalajara", 20.6597, -103.3496),
  City("Havana", 23.1136, -82.3666),
  City("Panama City", 8.9824, -79.5199),
  City("Bogotá", 4.711, -74.0721),
  City("Lima", -12.0464, -77.0428),
  City("Quito", -0.1807, -78.4678),
  City("Caracas", 10.4806, -66.9036),
  City("São Paulo", -23.5505, -46.6333),
  City("Rio de Janeiro", -22.9068, -43.1729),
  City("Brasília", -15.7939, -47.8828),
  City("Salvador", -12.9714, -38.5014),
  City("Buenos Aires", -34.6037, -58.3816),
  City("Santiago", -33.4489, -70.6693),
  City("Montevideo", -34.9011, -56.1645),
  City("Asunción", -25.2637, -57.5759),
  City("La Paz", -16.4897, -68.1193),
  City("London", 51.5074, -0.1278),
  City("Paris", 48.8566, 2.3522),
  City("Berlin", 52.52, 13.405),
  City("Madrid", 40.4168, -3.7038),
  City("Rome", 41.9028, 12.4964),
  City("Amsterdam", 52.3676, 4.9041),
  City("Brussels", 50.8503, 4.3517),
  City("Vienna", 48.2082, 16.3738),
  City("Prague", 50.0755, 14.4378),
  City("Warsaw", 52.2297, 21.0122),
  City("Stockholm", 59.3293, 18.0686),
  City("Oslo", 59.9139, 10.7522),
  City("Copenhagen", 55.6761, 12.5683),
  City("Helsinki", 60.1699, 24.9384),
  City("Dublin", 53.3498, -6.2603),
  City("Lisbon", 38.7223, -9.1393),
  City("Barcelona", 41.3851, 2.1734),
  City("Milan", 45.4642, 9.19),
  City("Munich", 48.1351, 11.582),
  City("Zurich", 47.3769, 8.5417),
  City("Athens", 37.9838, 23.7275),
  City("Budapest", 47.4979, 19.0402),
  City("Bucharest", 44.4268, 26.1025),
  City("Kyiv", 50.4501, 30.5234),
  City("Moscow", 55.7558, 37.6173),
  City("Saint Petersburg", 59.9311, 30.3609),
  City("Istanbul", 41.0082, 28.9784),
  City("Edinburgh", 55.9533, -3.1883),
  City("Reykjavik", 64.1466, -21.9426),
  City("Tel Aviv", 32.0853, 34.7818),
  City("Jerusalem", 31.7683, 35.2137),
  City("Beirut", 33.8886, 35.4955),
  City("Damascus", 33.5138, 36.2765),
  City("Amman", 31.9539, 35.9106),
  City("Cairo", 30.0444, 31.2357),
  City("Riyadh", 24.7136, 46.6753),
  City("Jeddah", 21.4858, 39.1925),
  City("Doha", 25.2854, 51.531),
  City("Dubai", 25.2048, 55.2708),
  City("Abu Dhabi", 24.4539, 54.3773),
  City("Kuwait City", 29.3759, 47.9774),
  City("Tehran", 35.6892, 51.389),
  City("Baghdad", 33.3152, 44.3661),
  City("Lagos", 6.5244, 3.3792),
  City("Accra", 5.6037, -0.187),
  City("Dakar", 14.7167, -17.4677),
  City("Abidjan", 5.36, -4.0083),
  City("Casablanca", 33.5731, -7.5898),
  City("Algiers", 36.7538, 3.0588),
  City("Tunis", 36.8065, 10.1815),
  City("Tripoli", 32.8872, 13.1913),
  City("Khartoum", 15.5007, 32.5599),
  City("Addis Ababa", 9.032, 38.7492),
  City("Nairobi", -1.2921, 36.8219),
  City("Kampala", 0.3476, 32.5825),
  City("Dar es Salaam", -6.7924, 39.2083),
  City("Luanda", -8.839, 13.2894),
  City("Kinshasa", -4.4419, 15.2663),
  City("Johannesburg", -26.2041, 28.0473),
  City("Cape Town", -33.9249, 18.4241),
  City("Durban", -29.8587, 31.0218),
  City("Antananarivo", -18.8792, 47.5079),
  City("Mumbai", 19.076, 72.8777),
  City("Delhi", 28.7041, 77.1025),
  City("Kolkata", 22.5726, 88.3639),
  City("Bangalore", 12.9716, 77.5946),
  City("Chennai", 13.0827, 80.2707),
  City("Hyderabad", 17.385, 78.4867),
  City("Karachi", 24.8607, 67.0011),
  City("Lahore", 31.5204, 74.3587),
  City("Islamabad", 33.6844, 73.0479),
  City("Kabul", 34.5553, 69.2075),
  City("Tashkent", 41.2995, 69.2401),
  City("Almaty", 43.222, 76.8512),
  City("Dhaka", 23.8103, 90.4125),
  City("Kathmandu", 27.7172, 85.324),
  City("Colombo", 6.9271, 79.8612),
  City("Yangon", 16.8661, 96.1951),
  City("Bangkok", 13.7563, 100.5018),
  City("Hanoi", 21.0285, 105.8542),
  City("Ho Chi Minh City", 10.8231, 106.6297),
  City("Phnom Penh", 11.5564, 104.9282),
  City("Vientiane", 17.9757, 102.6331),
  City("Kuala Lumpur", 3.139, 101.6869),
  City("Singapore", 1.3521, 103.8198),
  City("Jakarta", -6.2088, 106.8456),
  City("Manila", 14.5995, 120.9842),
  City("Beijing", 39.9042, 116.4074),
  City("Shanghai", 31.2304, 121.4737),
  City("Guangzhou", 23.1291, 113.2644),
  City("Shenzhen", 22.5431, 114.0579),
  City("Chengdu", 30.5728, 104.0668),
  City("Xi'an", 34.3416, 108.9398),
  City("Hong Kong", 22.3193, 114.1694),
  City("Taipei", 25.033, 121.5654),
  City("Seoul", 37.5665, 126.978),
  City("Pyongyang", 39.0392, 125.7625),
  City("Tokyo", 35.6762, 139.6503),
  City("Osaka", 34.6937, 135.5023),
  City("Kyoto", 35.0116, 135.7681),
  City("Sapporo", 43.0621, 141.3544),
  City("Ulaanbaatar", 47.8864, 106.9057),
  City("Novosibirsk", 55.0084, 82.9357),
  City("Vladivostok", 43.1198, 131.8869),
  City("Sydney", -33.8688, 151.2093),
  City("Melbourne", -37.8136, 144.9631),
  City("Brisbane", -27.4698, 153.0251),
  City("Perth", -31.9523, 115.8613),
  City("Adelaide", -34.9285, 138.6007),
  City("Auckland", -36.8485, 174.7633),
  City("Wellington", -41.2865, 174.7762),
  City("Suva", -18.1248, 178.4501),
  City("Port Moresby", -9.4438, 147.1803),
  City("Honolulu", 21.3099, -157.8581),
  City("Anchorage", 61.2181, -149.9003),
  City("Reykjanes", 63.8, -22.6),
  City("Minsk", 53.9006, 27.559),
  City("Riga", 56.9496, 24.1052),
  City("Tallinn", 59.437, 24.7536),
  City("Vilnius", 54.6872, 25.2797),
  City("Sofia", 42.6977, 23.3219),
  City("Belgrade", 44.7866, 20.4489),
  City("Zagreb", 45.815, 15.9819),
  City("Tbilisi", 41.7151, 44.8271),
  City("Baku", 40.4093, 49.8671),
  City("Yerevan", 40.1792, 44.4991),
];

// ---------------------------------------------------------------------------
// Continent dot coordinates (~1,200 points)
// ---------------------------------------------------------------------------

const List<List<double>> kContinentDots = [
  [-180, -85],
  [-150, -85],
  [-120, -85],
  [-90, -85],
  [-60, -85],
  [-30, -85],
  [0, -85],
  [30, -85],
  [60, -85],
  [90, -85],
  [120, -85],
  [150, -85],
  [-180, -82],
  [-158.44, -82],
  [-136.89, -82],
  [-115.33, -82],
  [-93.78, -82],
  [-72.22, -82],
  [-50.66, -82],
  [-29.11, -82],
  [-7.55, -82],
  [14, -82],
  [35.56, -82],
  [57.11, -82],
  [78.67, -82],
  [100.23, -82],
  [121.78, -82],
  [143.34, -82],
  [164.89, -82],
  [-180, -79],
  [-164.28, -79],
  [-148.55, -79],
  [-132.83, -79],
  [-117.11, -79],
  [-101.39, -79],
  [-85.66, -79],
  [-69.94, -79],
  [-54.22, -79],
  [-38.5, -79],
  [-22.77, -79],
  [-7.05, -79],
  [8.67, -79],
  [24.39, -79],
  [40.12, -79],
  [55.84, -79],
  [71.56, -79],
  [87.28, -79],
  [103.01, -79],
  [118.73, -79],
  [134.45, -79],
  [150.17, -79],
  [165.9, -79],
  [-180, -76],
  [-167.6, -76],
  [-155.2, -76],
  [-142.8, -76],
  [-130.4, -76],
  [-118, -76],
  [-105.6, -76],
  [-93.2, -76],
  [-80.79, -76],
  [-68.39, -76],
  [-55.99, -76],
  [-43.59, -76],
  [-31.19, -76],
  [-18.79, -76],
  [-6.39, -76],
  [6.01, -76],
  [18.41, -76],
  [30.81, -76],
  [43.21, -76],
  [55.61, -76],
  [68.01, -76],
  [80.41, -76],
  [92.82, -76],
  [105.22, -76],
  [117.62, -76],
  [130.02, -76],
  [142.42, -76],
  [154.82, -76],
  [167.22, -76],
  [179.62, -76],
  [-180, -73],
  [-169.74, -73],
  [-159.48, -73],
  [-149.22, -73],
  [-138.96, -73],
  [-128.7, -73],
  [-118.43, -73],
  [-108.17, -73],
  [-97.91, -73],
  [-87.65, -73],
  [-77.39, -73],
  [-67.13, -73],
  [-56.87, -73],
  [-46.61, -73],
  [-36.35, -73],
  [-26.09, -73],
  [-15.83, -73],
  [-5.56, -73],
  [4.7, -73],
  [14.96, -73],
  [25.22, -73],
  [35.48, -73],
  [45.74, -73],
  [56, -73],
  [66.26, -73],
  [76.52, -73],
  [86.78, -73],
  [97.04, -73],
  [107.31, -73],
  [117.57, -73],
  [127.83, -73],
  [138.09, -73],
  [148.35, -73],
  [158.61, -73],
  [168.87, -73],
  [179.13, -73],
  [-72.8, -52],
  [-70.25, -49],
  [-72.03, -46],
  [-67.71, -46],
  [169.81, -46],
  [-69.25, -43],
  [-65.14, -43],
  [168.67, -43],
  [172.77, -43],
  [176.87, -43],
  [-70.35, -40],
  [-66.43, -40],
  [-62.51, -40],
  [168.54, -40],
  [172.46, -40],
  [176.38, -40],
  [-71.06, -37],
  [-67.31, -37],
  [-63.55, -37],
  [-59.79, -37],
  [139.29, -37],
  [143.05, -37],
  [146.81, -37],
  [169.35, -37],
  [173.1, -37],
  [-71.44, -34],
  [-67.82, -34],
  [-64.2, -34],
  [-60.58, -34],
  [-56.97, -34],
  [134.82, -34],
  [138.44, -34],
  [142.06, -34],
  [145.68, -34],
  [149.3, -34],
  [-71.5, -31],
  [-68, -31],
  [-64.5, -31],
  [-61, -31],
  [-57.5, -31],
  [-54, -31],
  [19.49, -31],
  [22.99, -31],
  [26.49, -31],
  [29.99, -31],
  [117.49, -31],
  [120.99, -31],
  [124.49, -31],
  [127.99, -31],
  [131.49, -31],
  [134.99, -31],
  [138.49, -31],
  [141.99, -31],
  [145.49, -31],
  [148.99, -31],
  [-71.27, -28],
  [-67.88, -28],
  [-64.48, -28],
  [-61.08, -28],
  [-57.68, -28],
  [-54.28, -28],
  [-50.89, -28],
  [17.07, -28],
  [20.46, -28],
  [23.86, -28],
  [27.26, -28],
  [30.66, -28],
  [34.06, -28],
  [115.6, -28],
  [119, -28],
  [122.4, -28],
  [125.79, -28],
  [129.19, -28],
  [132.59, -28],
  [135.99, -28],
  [139.38, -28],
  [142.78, -28],
  [146.18, -28],
  [149.58, -28],
  [152.98, -28],
  [-70.77, -25],
  [-67.46, -25],
  [-64.15, -25],
  [-60.84, -25],
  [-57.53, -25],
  [-54.21, -25],
  [-50.9, -25],
  [15.3, -25],
  [18.61, -25],
  [21.92, -25],
  [25.23, -25],
  [28.54, -25],
  [31.85, -25],
  [35.16, -25],
  [38.47, -25],
  [45.09, -25],
  [114.6, -25],
  [117.91, -25],
  [121.22, -25],
  [124.53, -25],
  [127.84, -25],
  [131.15, -25],
  [134.46, -25],
  [137.77, -25],
  [141.08, -25],
  [144.39, -25],
  [147.7, -25],
  [151.01, -25],
  [-69.99, -22],
  [-66.75, -22],
  [-63.52, -22],
  [-60.28, -22],
  [-57.05, -22],
  [-53.81, -22],
  [-50.58, -22],
  [-47.34, -22],
  [-44.1, -22],
  [-40.87, -22],
  [14.14, -22],
  [17.37, -22],
  [20.61, -22],
  [23.84, -22],
  [27.08, -22],
  [30.31, -22],
  [33.55, -22],
  [36.79, -22],
  [40.02, -22],
  [46.49, -22],
  [114.44, -22],
  [117.68, -22],
  [120.91, -22],
  [124.15, -22],
  [127.38, -22],
  [130.62, -22],
  [133.85, -22],
  [137.09, -22],
  [140.32, -22],
  [143.56, -22],
  [146.8, -22],
  [-68.95, -19],
  [-65.78, -19],
  [-62.6, -19],
  [-59.43, -19],
  [-56.26, -19],
  [-53.09, -19],
  [-49.91, -19],
  [-46.74, -19],
  [-43.57, -19],
  [-40.39, -19],
  [13.54, -19],
  [16.72, -19],
  [19.89, -19],
  [23.06, -19],
  [26.24, -19],
  [29.41, -19],
  [32.58, -19],
  [35.75, -19],
  [38.93, -19],
  [45.27, -19],
  [48.45, -19],
  [121.42, -19],
  [124.59, -19],
  [127.77, -19],
  [130.94, -19],
  [134.11, -19],
  [137.29, -19],
  [140.46, -19],
  [143.63, -19],
  [146.8, -19],
  [-70.77, -16],
  [-67.65, -16],
  [-64.53, -16],
  [-61.41, -16],
  [-58.28, -16],
  [-55.16, -16],
  [-52.04, -16],
  [-48.92, -16],
  [-45.8, -16],
  [-42.68, -16],
  [-39.56, -16],
  [13.5, -16],
  [16.62, -16],
  [19.74, -16],
  [22.86, -16],
  [25.98, -16],
  [29.1, -16],
  [32.22, -16],
  [35.34, -16],
  [38.46, -16],
  [47.83, -16],
  [125.85, -16],
  [128.97, -16],
  [132.09, -16],
  [135.21, -16],
  [138.33, -16],
  [141.45, -16],
  [144.57, -16],
  [-72.24, -13],
  [-69.16, -13],
  [-66.08, -13],
  [-63, -13],
  [-59.92, -13],
  [-56.84, -13],
  [-53.76, -13],
  [-50.69, -13],
  [-47.61, -13],
  [-44.53, -13],
  [-41.45, -13],
  [-38.37, -13],
  [10.89, -13],
  [13.97, -13],
  [17.05, -13],
  [20.13, -13],
  [23.21, -13],
  [26.29, -13],
  [29.37, -13],
  [32.44, -13],
  [35.52, -13],
  [38.6, -13],
  [47.84, -13],
  [130.97, -13],
  [134.05, -13],
  [137.13, -13],
  [140.21, -13],
  [-73.38, -10],
  [-70.33, -10],
  [-67.29, -10],
  [-64.24, -10],
  [-61.2, -10],
  [-58.15, -10],
  [-55.1, -10],
  [-52.06, -10],
  [-49.01, -10],
  [-45.96, -10],
  [-42.92, -10],
  [-39.87, -10],
  [-36.82, -10],
  [11.92, -10],
  [14.96, -10],
  [18.01, -10],
  [21.05, -10],
  [24.1, -10],
  [27.15, -10],
  [30.19, -10],
  [33.24, -10],
  [36.29, -10],
  [121.58, -10],
  [124.63, -10],
  [127.67, -10],
  [-77.23, -7],
  [-74.21, -7],
  [-71.19, -7],
  [-68.17, -7],
  [-65.14, -7],
  [-62.12, -7],
  [-59.1, -7],
  [-56.08, -7],
  [-53.05, -7],
  [-50.03, -7],
  [-47.01, -7],
  [-43.99, -7],
  [-40.96, -7],
  [-37.94, -7],
  [10.42, -7],
  [13.44, -7],
  [16.46, -7],
  [19.49, -7],
  [22.51, -7],
  [25.53, -7],
  [28.55, -7],
  [31.58, -7],
  [107.14, -7],
  [110.16, -7],
  [113.19, -7],
  [116.21, -7],
  [119.23, -7],
  [128.3, -7],
  [131.32, -7],
  [134.34, -7],
  [137.37, -7],
  [-77.75, -4],
  [-74.74, -4],
  [-71.74, -4],
  [-68.73, -4],
  [-65.72, -4],
  [-62.71, -4],
  [-59.71, -4],
  [-56.7, -4],
  [-53.69, -4],
  [-50.68, -4],
  [-47.68, -4],
  [-44.67, -4],
  [-41.66, -4],
  [-38.66, -4],
  [9.46, -4],
  [12.47, -4],
  [15.48, -4],
  [18.48, -4],
  [21.49, -4],
  [24.5, -4],
  [99.68, -4],
  [102.69, -4],
  [105.7, -4],
  [108.7, -4],
  [111.71, -4],
  [135.77, -4],
  [138.78, -4],
  [-77.98, -1],
  [-74.98, -1],
  [-71.98, -1],
  [-68.98, -1],
  [-65.98, -1],
  [-62.98, -1],
  [-59.98, -1],
  [-56.98, -1],
  [-53.98, -1],
  [-50.98, -1],
  [-47.98, -1],
  [-44.98, -1],
  [-41.98, -1],
  [6.03, -1],
  [9.03, -1],
  [12.03, -1],
  [15.03, -1],
  [99.04, -1],
  [102.04, -1],
  [105.04, -1],
  [-77.94, 2],
  [-74.94, 2],
  [-71.93, 2],
  [-68.93, 2],
  [-65.93, 2],
  [-62.93, 2],
  [-59.93, 2],
  [-56.93, 2],
  [-53.92, 2],
  [-50.92, 2],
  [-47.92, 2],
  [3.11, 2],
  [6.11, 2],
  [9.12, 2],
  [12.12, 2],
  [99.17, 2],
  [120.18, 2],
  [-77.61, 5],
  [-74.6, 5],
  [-71.59, 5],
  [-68.58, 5],
  [-65.56, 5],
  [-62.55, 5],
  [-59.54, 5],
  [-56.53, 5],
  [-53.52, 5],
  [-50.51, 5],
  [115.12, 5],
  [118.13, 5],
  [-80.03, 8],
  [-77, 8],
  [-73.97, 8],
  [-70.94, 8],
  [-67.91, 8],
  [-64.88, 8],
  [-61.85, 8],
  [-58.82, 8],
  [-4.29, 8],
  [80.54, 8],
  [110.83, 8],
  [113.86, 8],
  [116.89, 8],
  [119.92, 8],
  [-69.98, 11],
  [-8.86, 11],
  [76.72, 11],
  [79.77, 11],
  [82.83, 11],
  [110.33, 11],
  [113.39, 11],
  [116.45, 11],
  [119.5, 11],
  [-16.13, 14],
  [-13.04, 14],
  [-9.95, 14],
  [33.34, 14],
  [36.43, 14],
  [39.52, 14],
  [42.61, 14],
  [45.7, 14],
  [76.62, 14],
  [79.71, 14],
  [82.81, 14],
  [110.63, 14],
  [113.72, 14],
  [116.82, 14],
  [119.91, 14],
  [-13.74, 17],
  [33.32, 17],
  [36.46, 17],
  [39.6, 17],
  [42.73, 17],
  [45.87, 17],
  [49.01, 17],
  [74.1, 17],
  [77.24, 17],
  [80.38, 17],
  [83.51, 17],
  [108.61, 17],
  [111.75, 17],
  [114.89, 17],
  [118.02, 17],
  [121.16, 17],
  [33.9, 20],
  [37.09, 20],
  [40.28, 20],
  [43.48, 20],
  [46.67, 20],
  [49.86, 20],
  [53.05, 20],
  [72.21, 20],
  [75.4, 20],
  [78.6, 20],
  [81.79, 20],
  [84.98, 20],
  [107.33, 20],
  [110.52, 20],
  [113.71, 20],
  [116.91, 20],
  [120.1, 20],
  [31.84, 23],
  [35.1, 23],
  [38.36, 23],
  [41.62, 23],
  [44.88, 23],
  [48.14, 23],
  [51.39, 23],
  [54.65, 23],
  [57.91, 23],
  [70.95, 23],
  [74.21, 23],
  [77.47, 23],
  [80.73, 23],
  [83.99, 23],
  [87.24, 23],
  [90.5, 23],
  [103.54, 23],
  [106.8, 23],
  [110.06, 23],
  [113.32, 23],
  [116.58, 23],
  [119.84, 23],
  [-109.91, 26],
  [-106.57, 26],
  [-103.23, 26],
  [-99.89, 26],
  [-86.54, 26],
  [-83.2, 26],
  [33.62, 26],
  [36.96, 26],
  [40.3, 26],
  [43.63, 26],
  [46.97, 26],
  [50.31, 26],
  [53.65, 26],
  [56.98, 26],
  [70.34, 26],
  [73.67, 26],
  [77.01, 26],
  [80.35, 26],
  [83.69, 26],
  [87.02, 26],
  [100.38, 26],
  [103.71, 26],
  [107.05, 26],
  [110.39, 26],
  [113.73, 26],
  [117.06, 26],
  [120.4, 26],
  [123.74, 26],
  [-114.83, 29],
  [-111.4, 29],
  [-107.97, 29],
  [-104.54, 29],
  [-101.11, 29],
  [-97.68, 29],
  [-94.25, 29],
  [-90.82, 29],
  [-87.39, 29],
  [-83.96, 29],
  [36.09, 29],
  [39.52, 29],
  [42.95, 29],
  [46.38, 29],
  [49.81, 29],
  [80.68, 29],
  [84.11, 29],
  [87.54, 29],
  [90.97, 29],
  [94.4, 29],
  [97.84, 29],
  [101.27, 29],
  [104.7, 29],
  [108.13, 29],
  [111.56, 29],
  [114.99, 29],
  [118.42, 29],
  [121.85, 29],
  [125.28, 29],
  [-116.32, 32],
  [-112.79, 32],
  [-109.25, 32],
  [-105.71, 32],
  [-102.17, 32],
  [-98.64, 32],
  [-95.1, 32],
  [-91.56, 32],
  [-88.02, 32],
  [-84.49, 32],
  [-80.95, 32],
  [67.63, 32],
  [71.16, 32],
  [74.7, 32],
  [78.24, 32],
  [81.78, 32],
  [85.32, 32],
  [88.85, 32],
  [92.39, 32],
  [95.93, 32],
  [99.47, 32],
  [103, 32],
  [106.54, 32],
  [110.08, 32],
  [113.62, 32],
  [117.15, 32],
  [120.69, 32],
  [124.23, 32],
  [127.77, 32],
  [-121.4, 35],
  [-117.74, 35],
  [-114.08, 35],
  [-110.42, 35],
  [-106.75, 35],
  [-103.09, 35],
  [-99.43, 35],
  [-95.77, 35],
  [-92.1, 35],
  [-88.44, 35],
  [-84.78, 35],
  [-81.12, 35],
  [61.71, 35],
  [65.38, 35],
  [69.04, 35],
  [72.7, 35],
  [76.36, 35],
  [80.02, 35],
  [83.69, 35],
  [87.35, 35],
  [91.01, 35],
  [94.67, 35],
  [98.34, 35],
  [102, 35],
  [105.66, 35],
  [109.32, 35],
  [112.99, 35],
  [116.65, 35],
  [120.31, 35],
  [123.97, 35],
  [127.64, 35],
  [131.3, 35],
  [134.96, 35],
  [-122.89, 38],
  [-119.09, 38],
  [-115.28, 38],
  [-111.47, 38],
  [-107.67, 38],
  [-103.86, 38],
  [-100.05, 38],
  [-96.24, 38],
  [-92.44, 38],
  [-88.63, 38],
  [-84.82, 38],
  [-81.02, 38],
  [-77.21, 38],
  [-8.68, 38],
  [-4.88, 38],
  [59.84, 38],
  [63.65, 38],
  [67.46, 38],
  [71.27, 38],
  [75.07, 38],
  [78.88, 38],
  [82.69, 38],
  [86.49, 38],
  [90.3, 38],
  [94.11, 38],
  [97.91, 38],
  [101.72, 38],
  [105.53, 38],
  [109.34, 38],
  [113.14, 38],
  [116.95, 38],
  [120.76, 38],
  [124.56, 38],
  [128.37, 38],
  [132.18, 38],
  [135.99, 38],
  [139.79, 38],
  [-120.37, 41],
  [-116.4, 41],
  [-112.42, 41],
  [-108.45, 41],
  [-104.47, 41],
  [-100.5, 41],
  [-96.52, 41],
  [-92.55, 41],
  [-88.57, 41],
  [-84.6, 41],
  [-80.62, 41],
  [-76.65, 41],
  [-72.67, 41],
  [-9.07, 41],
  [-5.1, 41],
  [-1.12, 41],
  [14.78, 41],
  [18.75, 41],
  [22.73, 41],
  [26.7, 41],
  [50.55, 41],
  [54.53, 41],
  [58.5, 41],
  [62.48, 41],
  [66.45, 41],
  [70.43, 41],
  [74.4, 41],
  [78.38, 41],
  [82.35, 41],
  [86.33, 41],
  [90.3, 41],
  [94.28, 41],
  [98.25, 41],
  [102.23, 41],
  [106.2, 41],
  [110.18, 41],
  [114.15, 41],
  [118.13, 41],
  [122.1, 41],
  [126.08, 41],
  [130.05, 41],
  [134.03, 41],
  [138, 41],
  [141.98, 41],
  [-121.61, 44],
  [-117.44, 44],
  [-113.27, 44],
  [-109.1, 44],
  [-104.93, 44],
  [-100.76, 44],
  [-96.59, 44],
  [-92.42, 44],
  [-88.25, 44],
  [-84.08, 44],
  [-79.91, 44],
  [-75.74, 44],
  [-71.57, 44],
  [-67.4, 44],
  [-9.01, 44],
  [-4.84, 44],
  [-0.67, 44],
  [3.5, 44],
  [7.67, 44],
  [11.84, 44],
  [16.01, 44],
  [20.18, 44],
  [24.35, 44],
  [28.52, 44],
  [36.87, 44],
  [41.04, 44],
  [45.21, 44],
  [49.38, 44],
  [53.55, 44],
  [57.72, 44],
  [61.89, 44],
  [66.06, 44],
  [70.23, 44],
  [74.4, 44],
  [78.57, 44],
  [82.74, 44],
  [86.91, 44],
  [91.08, 44],
  [95.25, 44],
  [99.42, 44],
  [103.59, 44],
  [107.76, 44],
  [111.93, 44],
  [116.1, 44],
  [120.28, 44],
  [124.45, 44],
  [128.62, 44],
  [132.79, 44],
  [136.96, 44],
  [141.13, 44],
  [145.3, 44],
  [-122.82, 47],
  [-118.42, 47],
  [-114.02, 47],
  [-109.62, 47],
  [-105.22, 47],
  [-100.82, 47],
  [-96.42, 47],
  [-92.02, 47],
  [-87.62, 47],
  [-83.23, 47],
  [-78.83, 47],
  [-74.43, 47],
  [-70.03, 47],
  [-65.63, 47],
  [-61.23, 47],
  [-8.45, 47],
  [-4.05, 47],
  [0.35, 47],
  [4.75, 47],
  [9.15, 47],
  [13.55, 47],
  [17.95, 47],
  [22.35, 47],
  [26.75, 47],
  [31.14, 47],
  [35.54, 47],
  [39.94, 47],
  [44.34, 47],
  [48.74, 47],
  [53.14, 47],
  [57.54, 47],
  [61.94, 47],
  [66.33, 47],
  [70.73, 47],
  [75.13, 47],
  [79.53, 47],
  [83.93, 47],
  [88.33, 47],
  [92.73, 47],
  [97.13, 47],
  [101.53, 47],
  [105.92, 47],
  [110.32, 47],
  [114.72, 47],
  [119.12, 47],
  [123.52, 47],
  [127.92, 47],
  [132.32, 47],
  [136.72, 47],
  [141.12, 47],
  [145.51, 47],
  [149.91, 47],
  [-123.99, 50],
  [-119.33, 50],
  [-114.66, 50],
  [-109.99, 50],
  [-105.33, 50],
  [-100.66, 50],
  [-95.99, 50],
  [-91.32, 50],
  [-86.66, 50],
  [-81.99, 50],
  [-77.32, 50],
  [-72.66, 50],
  [-67.99, 50],
  [-63.32, 50],
  [-58.65, 50],
  [-7.31, 50],
  [-2.65, 50],
  [2.02, 50],
  [6.69, 50],
  [11.35, 50],
  [16.02, 50],
  [20.69, 50],
  [25.36, 50],
  [30.02, 50],
  [34.69, 50],
  [39.36, 50],
  [44.02, 50],
  [48.69, 50],
  [53.36, 50],
  [58.03, 50],
  [62.69, 50],
  [67.36, 50],
  [72.03, 50],
  [76.69, 50],
  [81.36, 50],
  [86.03, 50],
  [90.7, 50],
  [95.36, 50],
  [100.03, 50],
  [104.7, 50],
  [109.36, 50],
  [114.03, 50],
  [118.7, 50],
  [123.37, 50],
  [128.03, 50],
  [132.7, 50],
  [137.37, 50],
  [142.03, 50],
  [146.7, 50],
  [151.37, 50],
  [-125.17, 53],
  [-120.18, 53],
  [-115.2, 53],
  [-110.21, 53],
  [-105.23, 53],
  [-100.24, 53],
  [-95.26, 53],
  [-90.27, 53],
  [-85.29, 53],
  [-80.3, 53],
  [-75.32, 53],
  [-70.33, 53],
  [-65.35, 53],
  [-60.36, 53],
  [-55.38, 53],
  [-5.53, 53],
  [-0.54, 53],
  [4.44, 53],
  [9.43, 53],
  [14.41, 53],
  [19.4, 53],
  [24.38, 53],
  [29.37, 53],
  [34.35, 53],
  [39.34, 53],
  [44.32, 53],
  [49.31, 53],
  [54.29, 53],
  [59.28, 53],
  [64.26, 53],
  [69.25, 53],
  [74.23, 53],
  [79.22, 53],
  [84.2, 53],
  [89.19, 53],
  [94.17, 53],
  [99.16, 53],
  [104.14, 53],
  [109.13, 53],
  [114.11, 53],
  [119.1, 53],
  [124.08, 53],
  [129.07, 53],
  [134.05, 53],
  [139.03, 53],
  [144.02, 53],
  [149, 53],
  [153.99, 53],
  [-131.72, 56],
  [-126.35, 56],
  [-120.99, 56],
  [-115.62, 56],
  [-110.26, 56],
  [-104.89, 56],
  [-99.53, 56],
  [-94.16, 56],
  [-88.8, 56],
  [-83.43, 56],
  [-78.07, 56],
  [-72.7, 56],
  [-67.34, 56],
  [-61.97, 56],
  [-56.61, 56],
  [-8.32, 56],
  [-2.96, 56],
  [2.41, 56],
  [7.77, 56],
  [13.14, 56],
  [18.5, 56],
  [23.87, 56],
  [29.23, 56],
  [34.59, 56],
  [39.96, 56],
  [45.32, 56],
  [50.69, 56],
  [56.05, 56],
  [61.42, 56],
  [66.78, 56],
  [72.15, 56],
  [77.51, 56],
  [82.88, 56],
  [88.24, 56],
  [93.61, 56],
  [98.97, 56],
  [104.34, 56],
  [109.7, 56],
  [115.07, 56],
  [120.43, 56],
  [125.8, 56],
  [131.16, 56],
  [136.53, 56],
  [141.89, 56],
  [147.26, 56],
  [152.62, 56],
  [157.99, 56],
  [-139.23, 59],
  [-133.4, 59],
  [-127.58, 59],
  [-121.75, 59],
  [-115.93, 59],
  [-110.1, 59],
  [-104.28, 59],
  [-98.45, 59],
  [-92.63, 59],
  [-86.8, 59],
  [-80.98, 59],
  [-75.15, 59],
  [-69.33, 59],
  [-63.5, 59],
  [-57.68, 59],
  [6.39, 59],
  [12.22, 59],
  [18.04, 59],
  [23.87, 59],
  [29.69, 59],
  [35.52, 59],
  [41.34, 59],
  [47.17, 59],
  [52.99, 59],
  [58.82, 59],
  [64.64, 59],
  [70.47, 59],
  [76.29, 59],
  [82.12, 59],
  [87.94, 59],
  [93.77, 59],
  [99.59, 59],
  [105.42, 59],
  [111.24, 59],
  [117.07, 59],
  [122.89, 59],
  [128.72, 59],
  [134.54, 59],
  [140.36, 59],
  [146.19, 59],
  [152.01, 59],
  [157.84, 59],
  [-160.83, 62],
  [-154.44, 62],
  [-148.05, 62],
  [-141.66, 62],
  [-135.27, 62],
  [-128.88, 62],
  [-122.49, 62],
  [-116.1, 62],
  [-109.71, 62],
  [-103.32, 62],
  [-96.93, 62],
  [-90.54, 62],
  [-84.15, 62],
  [-77.76, 62],
  [-71.37, 62],
  [-64.98, 62],
  [-52.2, 62],
  [-45.81, 62],
  [-39.42, 62],
  [-33.03, 62],
  [-26.64, 62],
  [11.7, 62],
  [18.1, 62],
  [24.49, 62],
  [30.88, 62],
  [37.27, 62],
  [43.66, 62],
  [50.05, 62],
  [56.44, 62],
  [62.83, 62],
  [69.22, 62],
  [75.61, 62],
  [82, 62],
  [88.39, 62],
  [94.78, 62],
  [101.17, 62],
  [107.56, 62],
  [113.95, 62],
  [120.34, 62],
  [126.73, 62],
  [133.12, 62],
  [139.51, 62],
  [145.9, 62],
  [152.29, 62],
  [158.68, 62],
  [165.07, 62],
  [-165.8, 65],
  [-158.7, 65],
  [-151.61, 65],
  [-144.51, 65],
  [-137.41, 65],
  [-130.31, 65],
  [-123.21, 65],
  [-116.11, 65],
  [-109.01, 65],
  [-101.92, 65],
  [-94.82, 65],
  [-87.72, 65],
  [-80.62, 65],
  [-73.52, 65],
  [-52.23, 65],
  [-45.13, 65],
  [-38.03, 65],
  [-30.93, 65],
  [-23.83, 65],
  [11.66, 65],
  [18.76, 65],
  [25.86, 65],
  [40.06, 65],
  [47.16, 65],
  [54.25, 65],
  [61.35, 65],
  [68.45, 65],
  [75.55, 65],
  [82.65, 65],
  [89.75, 65],
  [96.85, 65],
  [103.94, 65],
  [111.04, 65],
  [118.14, 65],
  [125.24, 65],
  [132.34, 65],
  [139.44, 65],
  [146.54, 65],
  [153.63, 65],
  [160.73, 65],
  [167.83, 65],
  [-155.97, 68],
  [-147.97, 68],
  [-139.96, 68],
  [-131.95, 68],
  [-123.94, 68],
  [-115.93, 68],
  [-107.92, 68],
  [-99.92, 68],
  [-91.91, 68],
  [-83.9, 68],
  [-75.89, 68],
  [-51.87, 68],
  [-43.86, 68],
  [-35.85, 68],
  [-27.84, 68],
  [20.21, 68],
  [44.24, 68],
  [52.24, 68],
  [60.25, 68],
  [68.26, 68],
  [76.27, 68],
  [84.28, 68],
  [92.29, 68],
  [100.29, 68],
  [108.3, 68],
  [116.31, 68],
  [124.32, 68],
  [132.33, 68],
  [140.34, 68],
  [148.34, 68],
  [156.35, 68],
  [164.36, 68],
  [172.37, 68],
  [-115.5, 71],
  [-106.28, 71],
  [-97.07, 71],
  [-87.85, 71],
  [-78.64, 71],
  [-50.99, 71],
  [-41.78, 71],
  [-32.57, 71],
  [-23.35, 71],
  [59.58, 71],
  [68.8, 71],
  [78.01, 71],
  [87.23, 71],
  [96.44, 71],
  [105.65, 71],
  [114.87, 71],
  [124.08, 71],
  [133.3, 71],
  [142.51, 71],
  [151.73, 71],
  [160.94, 71],
  [170.16, 71],
  [179.37, 71],
  [-49.39, 74],
  [-38.51, 74],
  [-27.63, 74],
  [59.45, 74],
  [70.33, 74],
  [81.21, 74],
  [92.1, 74],
  [102.98, 74],
  [113.86, 74],
  [124.75, 74],
  [135.63, 74],
  [146.52, 74],
  [157.4, 74],
  [168.28, 74],
  [179.17, 74],
  [-46.64, 77],
  [-33.3, 77],
  [73.39, 77],
  [86.72, 77],
  [100.06, 77],
  [140.07, 77],
  [153.41, 77],
  [-41.79, 80],
];
