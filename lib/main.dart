import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// ─── Paleta & Tema ────────────────────────────────────────────────────────────

const _kPrimary = Color(0xFF6C63FF);
const _kSecondary = Color(0xFF3ECFCF);
const _kAccent = Color(0xFFFF6584);
const _kDark = Color(0xFF1A1A2E);
const _kCard = Color(0xFF16213E);
const _kSurface = Color(0xFF0F3460);

final _gradientPrimary = const LinearGradient(
  colors: [_kPrimary, _kSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final _gradientCard = LinearGradient(
  colors: [_kCard, _kSurface.withAlpha(200)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

ThemeData _buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _kDark,
    colorScheme: ColorScheme.dark(
      primary: _kPrimary,
      secondary: _kSecondary,
      surface: _kCard,
      error: _kAccent,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white),
      titleLarge: TextStyle(
          fontWeight: FontWeight.w700, letterSpacing: 0.2, color: Colors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFB0B8D0)),
      bodySmall: TextStyle(color: Color(0xFF7A8099)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _kSurface.withAlpha(120),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withAlpha(30)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withAlpha(30)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _kAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _kAccent, width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF9BA5C0)),
      prefixIconColor: _kSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.zero,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

// ─── Entry Point ──────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuarios',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const UsuariosPage(),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String nocuenta;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.nocuenta,
  });

  factory Usuario.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      nocuenta: data['nocuenta'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'email': email,
        'nocuenta': nocuenta,
      };
}

// ─── Avatar colors ────────────────────────────────────────────────────────────

Color _avatarColor(String name) {
  final colors = [
    _kPrimary,
    _kSecondary,
    _kAccent,
    const Color(0xFF43C6AC),
    const Color(0xFFFF9A56),
    const Color(0xFF9B59B6),
  ];
  if (name.isEmpty) return colors[0];
  return colors[name.codeUnitAt(0) % colors.length];
}

// ─── Shared: Gradient Button ──────────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final LinearGradient gradient;
  final double height;
  final double borderRadius;

  const _GradientButton({
    required this.onPressed,
    required this.child,
    this.gradient = const LinearGradient(
      colors: [_kPrimary, _kSecondary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    this.height = 52,
    this.borderRadius = 16,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

// ─── Shared: Particle Background ─────────────────────────────────────────────

class _Particle {
  double x, y, radius, speed, angle;
  Color color;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withAlpha(60)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height),
          p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _AnimatedBackground extends StatefulWidget {
  final Widget child;
  const _AnimatedBackground({required this.child});

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(18, (i) => _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      radius: 2 + _rng.nextDouble() * 5,
      speed: 0.0002 + _rng.nextDouble() * 0.0003,
      angle: _rng.nextDouble() * math.pi * 2,
      color: [_kPrimary, _kSecondary, _kAccent][i % 3],
    ));
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
    _ctrl.addListener(() {
      for (final p in _particles) {
        p.x += math.cos(p.angle) * p.speed;
        p.y += math.sin(p.angle) * p.speed;
        if (p.x < 0 || p.x > 1) p.angle = math.pi - p.angle;
        if (p.y < 0 || p.y > 1) p.angle = -p.angle;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: _ParticlePainter(_particles),
          child: const SizedBox.expand(),
        ),
        widget.child,
      ],
    );
  }
}

// ─── Staggered item animation ─────────────────────────────────────────────────

class _StaggerItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggerItem({required this.index, required this.child});

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Usuario Card ─────────────────────────────────────────────────────────────

class _UsuarioCard extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UsuarioCard({
    required this.usuario,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_UsuarioCard> createState() => _UsuarioCardState();
}

class _UsuarioCardState extends State<_UsuarioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _elevation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.usuario;
    final avatarColor = _avatarColor(u.nombre);
    final initials = u.nombre.isNotEmpty
        ? u.nombre.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return AnimatedBuilder(
      animation: _elevation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -3 * _elevation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _hoverCtrl.forward(),
        onTapUp: (_) => _hoverCtrl.reverse(),
        onTapCancel: () => _hoverCtrl.reverse(),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            gradient: _gradientCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(18), width: 1),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withAlpha(30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [avatarColor, avatarColor.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: avatarColor.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 11, color: _kSecondary.withAlpha(200)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              u.email,
                              style: const TextStyle(
                                  color: Color(0xFF9BA5C0), fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.credit_card_outlined,
                              size: 11, color: _kAccent.withAlpha(200)),
                          const SizedBox(width: 4),
                          Text(
                            u.nocuenta,
                            style: const TextStyle(
                                color: Color(0xFF9BA5C0), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    _IconAction(
                      icon: Icons.edit_rounded,
                      color: _kPrimary,
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(height: 6),
                    _IconAction(
                      icon: Icons.delete_rounded,
                      color: _kAccent,
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: widget.color.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.color.withAlpha(60), width: 1),
          ),
          child: Icon(widget.icon, color: widget.color, size: 16),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatefulWidget {
  const _EmptyState();

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) =>
                Transform.translate(offset: Offset(0, _float.value), child: child),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: _gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withAlpha(80),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 52, color: Colors.white),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Sin usuarios aún',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para\nagregar el primero.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Usuarios Page ────────────────────────────────────────────────────────────

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  Future<void> _deleteUsuario(BuildContext context, Usuario u) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _DeleteDialog(usuario: u),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(u.id)
          .delete();
    }
  }

  void _goToForm(BuildContext context, [Usuario? u]) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => UsuarioFormPage(usuario: u),
        transitionsBuilder: (ctx, anim, sec, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      body: _AnimatedBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                _gradientPrimary.createShader(bounds),
                            child: const Text(
                              'Usuarios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('usuarios')
                                .snapshots(),
                            builder: (context, snap) {
                              final count = snap.data?.docs.length ?? 0;
                              return Text(
                                '$count registro${count == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    color: Color(0xFF7A8099), fontSize: 13),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // FAB inline in header
                    GestureDetector(
                      onTap: () => _goToForm(context),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _gradientPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withAlpha(100),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // ── Divider decorativo ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_kPrimary, _kSecondary, Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ── List ──
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: _kAccent)),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_kPrimary),
                          ),
                        ),
                      );
                    }

                    final usuarios = snapshot.data!.docs
                        .map((d) => Usuario.fromDoc(d))
                        .toList();

                    if (usuarios.isEmpty) {
                      return const _EmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: usuarios.length,
                      itemBuilder: (context, index) {
                        final u = usuarios[index];
                        return _StaggerItem(
                          index: index,
                          child: _UsuarioCard(
                            usuario: u,
                            onEdit: () => _goToForm(context, u),
                            onDelete: () => _deleteUsuario(context, u),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Delete Dialog ────────────────────────────────────────────────────────────

class _DeleteDialog extends StatefulWidget {
  final Usuario usuario;
  const _DeleteDialog({required this.usuario});

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: AlertDialog(
          backgroundColor: _kCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _kAccent.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.delete_forever_rounded, color: _kAccent, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Eliminar usuario',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Eliminar a ${widget.usuario.nombre}?\nEsta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9BA5C0), fontSize: 13),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withAlpha(30)),
                        ),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GradientButton(
                      gradient: LinearGradient(
                          colors: [_kAccent, const Color(0xFFFF8E8E)]),
                      height: 46,
                      borderRadius: 12,
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form Page ────────────────────────────────────────────────────────────────

class UsuarioFormPage extends StatefulWidget {
  final Usuario? usuario;
  const UsuarioFormPage({super.key, this.usuario});

  @override
  State<UsuarioFormPage> createState() => _UsuarioFormPageState();
}

class _UsuarioFormPageState extends State<UsuarioFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _nocuentaCtrl;
  bool _loading = false;

  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  bool get _isEditing => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.usuario?.nombre ?? '');
    _emailCtrl = TextEditingController(text: widget.usuario?.email ?? '');
    _nocuentaCtrl =
        TextEditingController(text: widget.usuario?.nocuenta ?? '');

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _nocuentaCtrl.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'nocuenta': _nocuentaCtrl.text.trim(),
    };

    try {
      final col = FirebaseFirestore.instance.collection('usuarios');
      if (_isEditing) {
        await col.doc(widget.usuario!.id).update(data);
      } else {
        await col.add(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: _kAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      body: _AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 12, 24, 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withAlpha(25), width: 1),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  _gradientPrimary.createShader(bounds),
                              child: Text(
                                _isEditing ? 'Editar usuario' : 'Nuevo usuario',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              _isEditing
                                  ? 'Actualiza la información'
                                  : 'Completa los campos',
                              style: const TextStyle(
                                  color: Color(0xFF7A8099), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Form ──
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar preview
                        _AnimatedAvatarPreview(controller: _nombreCtrl),
                        const SizedBox(height: 28),

                        _StaggerItem(
                          index: 0,
                          child: _FormField(
                            controller: _nombreCtrl,
                            label: 'Nombre completo',
                            icon: Icons.person_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa el nombre'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StaggerItem(
                          index: 1,
                          child: _FormField(
                            controller: _emailCtrl,
                            label: 'Correo electrónico',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Ingresa el email';
                              }
                              if (!v.contains('@')) return 'Email no válido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StaggerItem(
                          index: 2,
                          child: _FormField(
                            controller: _nocuentaCtrl,
                            label: 'Número de cuenta',
                            icon: Icons.credit_card_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa el número de cuenta'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _StaggerItem(
                          index: 3,
                          child: _GradientButton(
                            onPressed: _loading ? null : _submit,
                            height: 56,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isEditing
                                            ? Icons.save_rounded
                                            : Icons.add_circle_outline_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isEditing ? 'Actualizar' : 'Guardar',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated Avatar Preview ──────────────────────────────────────────────────

class _AnimatedAvatarPreview extends StatefulWidget {
  final TextEditingController controller;
  const _AnimatedAvatarPreview({required this.controller});

  @override
  State<_AnimatedAvatarPreview> createState() => _AnimatedAvatarPreviewState();
}

class _AnimatedAvatarPreviewState extends State<_AnimatedAvatarPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  String _initials = '?';
  Color _color = _kPrimary;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    widget.controller.addListener(_onNameChanged);
    _updateInitials(widget.controller.text);
  }

  void _onNameChanged() => _updateInitials(widget.controller.text);

  void _updateInitials(String text) {
    final trimmed = text.trim();
    final newInitials = trimmed.isEmpty
        ? '?'
        : trimmed.split(' ').take(2).map((w) => w[0].toUpperCase()).join();
    final newColor = _avatarColor(trimmed);
    if (newInitials != _initials || newColor != _color) {
      _ctrl.forward(from: 0);
      setState(() {
        _initials = newInitials;
        _color = newColor;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onNameChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color, _color.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _color.withAlpha(100),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Form Field ────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: _gradientPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
        ),
      ),
    );
  }
}
