import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const BrilliantApp());
}

// ============================================================
// BRILLIANT
// ============================================================
//
// Tablero 7 x 7
//
// COLORES:
//
// Amarillo -> números diferentes
// Verde    -> cualquier número
// Lila     -> máximo 2 números
// Azul     -> números iguales
// Rojo     -> números diferentes
//
// REGLA DE VECINDAD:
//
// Solo cuentan:
// arriba
// abajo
// izquierda
// derecha
//
// DIADOS:
//
// Dado 1 = número que debe buscarse
// Dado 2 = número que debe colocarse
//
// EJEMPLO:
//
// 4 - 6
//
// Buscar un 4 propio y colocar 6
// en una casilla ortogonalmente adyacente.
//
// ============================================================


// ============================================================
// COLORES DEL TABLERO
// ============================================================

enum ColorZona {
  amarillo,
  rojo,
  verde,
  azul,
  lila,
}


// ============================================================
// CASILLA
// ============================================================

class Casilla {
  ColorZona zona;
  int? numero;

  Casilla({
    required this.zona,
    this.numero,
  });

  bool get ocupada => numero != null;
}


// ============================================================
// JUGADOR
// ============================================================

class Jugador {
  final int id;
  final String nombre;

  int puntos = 0;

  late List<List<Casilla>> tablero;

  // ==========================================================
  // CONTADOR DE TURNOS
  // ==========================================================

  int turno = 1;

  // ==========================================================
  // ANCLAS
  // ==========================================================

  // Indica cuántas anclas 1-6 ha colocado.
  int anclasColocadas = 0;

  // Indica si ya terminó su preparación inicial.
  bool anclasCompletadas = false;

  // ==========================================================
  // CONTROL DEL TURNO
  // ==========================================================

  // Solo se permite colocar un número normal por turno.
  bool numeroColocadoEsteTurno = false;

  // Indica si lanzó los dados en este turno.
  bool dadosLanzados = false;

  // ==========================================================
  // CONJUNTOS YA PUNTUADOS
  // ==========================================================

  Set<String> conjuntosCompletados = {};

  Jugador({
    required this.id,
    required this.nombre,
  }) {
    tablero = [];
  }
}


// ============================================================
// APLICACIÓN
// ============================================================

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brilliant',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const BrilliantGame(),
    );
  }
}


// ============================================================
// JUEGO
// ============================================================

class BrilliantGame extends StatefulWidget {
  const BrilliantGame({super.key});

  @override
  State<BrilliantGame> createState() =>
      _BrilliantGameState();
}


class _BrilliantGameState
    extends State<BrilliantGame> {

  // ==========================================================
  // CONFIGURACIÓN
  // ==========================================================

  static const int filas = 7;
  static const int columnas = 7;

  static const int puntosParaGanar = 20;

  final Random random = Random();

  // ==========================================================
  // JUGADORES
  // ==========================================================

  late List<Jugador> jugadores;

  int jugadorActual = 0;

  Jugador get jugador =>
      jugadores[jugadorActual];

  // ==========================================================
  // DADOS
  // ==========================================================

  int dado1 = 1;
  int dado2 = 1;


  // ==========================================================
  // ANCLAS
  // ==========================================================

  final List<int> numerosAncla = [
    1,
    2,
    3,
    4,
    5,
    6,
  ];



  // ==========================================================
  // ESTADO
  // ==========================================================

  bool juegoTerminado = false;

  String mensaje = '';

  @override
  void initState() {
    super.initState();

    iniciarJuego();
  }


  // ==========================================================
  // INICIAR JUEGO
  // ==========================================================

  void iniciarJuego() {

  jugadores = [
    Jugador(
      id: 1,
      nombre: 'Jugador 1',
    ),
    Jugador(
      id: 2,
      nombre: 'Jugador 2',
    ),
  ];

  jugadorActual = 0;

  for (Jugador j in jugadores) {

    j.tablero =
        generarPatronColores();

    j.puntos = 0;

    j.turno = 1;

    j.anclasColocadas = 0;

    j.anclasCompletadas = false;

    j.numeroColocadoEsteTurno = false;

    j.dadosLanzados = false;

    j.conjuntosCompletados.clear();
  }

  dado1 = 1;
  dado2 = 1;

  juegoTerminado = false;

  mensaje =
      '${jugador.nombre}: Turno 1. '
      'Debes colocar los números ancla '
      '1, 2, 3, 4, 5 y 6.';
}

int obtenerSiguienteAncla() {

  return jugador.anclasColocadas + 1;
}

  // ==========================================================
  // GENERAR TABLERO DE COLORES
  // ==========================================================

  List<List<Casilla>> generarPatronColores() {

    // --------------------------------------------------------
    // Primero creamos una cuadrícula aleatoria.
    // --------------------------------------------------------

    List<List<ColorZona>> colores =
        List.generate(
      filas,
      (_) => List.generate(
        columnas,
        (_) => ColorZona.amarillo,
      ),
    );


    List<ColorZona> coloresDisponibles = [
      ColorZona.amarillo,
      ColorZona.rojo,
      ColorZona.verde,
      ColorZona.azul,
      ColorZona.lila,
    ];


    // --------------------------------------------------------
    // Intentar generar un patrón válido.
    // --------------------------------------------------------

    for (int intento = 0; intento < 500; intento++) {

      for (int f = 0; f < filas; f++) {

        for (int c = 0; c < columnas; c++) {

          colores[f][c] =
              coloresDisponibles[
                random.nextInt(
                  coloresDisponibles.length,
                )
              ];
        }
      }


      if (patronValido(colores)) {

        break;
      }
    }


    // --------------------------------------------------------
    // Convertir a Casillas.
    // --------------------------------------------------------

    return List.generate(
      filas,
      (f) => List.generate(
        columnas,
        (c) => Casilla(
          zona: colores[f][c],
        ),
      ),
    );
  }


  // ==========================================================
  // COMPROBAR PATRÓN
  // ==========================================================

  bool patronValido(
    List<List<ColorZona>> colores,
  ) {

    for (int f = 0; f < filas; f++) {

      for (int c = 0; c < columnas; c++) {

        ColorZona color =
            colores[f][c];


        // ----------------------------------------------------
        // Amarillo puede estar aislado.
        // ----------------------------------------------------

        if (color == ColorZona.amarillo) {
          continue;
        }


        bool tieneVecinoMismoColor = false;


        // ARRIBA
        if (f > 0 &&
            colores[f - 1][c] == color) {

          tieneVecinoMismoColor = true;
        }


        // ABAJO
        if (f < filas - 1 &&
            colores[f + 1][c] == color) {

          tieneVecinoMismoColor = true;
        }


        // IZQUIERDA
        if (c > 0 &&
            colores[f][c - 1] == color) {

          tieneVecinoMismoColor = true;
        }


        // DERECHA
        if (c < columnas - 1 &&
            colores[f][c + 1] == color) {

          tieneVecinoMismoColor = true;
        }


        if (!tieneVecinoMismoColor) {
          return false;
        }
      }
    }

    return true;
  }


  // ==========================================================
  // VECINOS ORTOGONALES
  // ==========================================================

  List<Point<int>> vecinosOrtogonal(
    int fila,
    int columna,
  ) {

    List<Point<int>> vecinos = [];


    if (fila > 0) {
      vecinos.add(
        Point(fila - 1, columna),
      );
    }


    if (fila < filas - 1) {
      vecinos.add(
        Point(fila + 1, columna),
      );
    }


    if (columna > 0) {
      vecinos.add(
        Point(fila, columna - 1),
      );
    }


    if (columna < columnas - 1) {
      vecinos.add(
        Point(fila, columna + 1),
      );
    }


    return vecinos;
  }


  // ==========================================================
  // COLOCAR ANCLA
  // ==========================================================

  void colocarAncla(
  int fila,
  int columna,
) {

  // ----------------------------------------------------------
  // Comprobar que estamos en el primer turno.
  // ----------------------------------------------------------

  if (jugador.turno != 1 ||
      jugador.anclasCompletadas) {

    return;
  }

  Casilla casilla =
      jugador.tablero[fila][columna];

  // ----------------------------------------------------------
  // No permitir ocupar una casilla que ya tenga número.
  // ----------------------------------------------------------

  if (casilla.ocupada) {

    setState(() {

      mensaje =
          'Esta casilla ya contiene '
          'un número.';
    });

    return;
  }

  // ----------------------------------------------------------
  // Número que corresponde colocar.
  // ----------------------------------------------------------

  int numero =
      obtenerSiguienteAncla();

  // ----------------------------------------------------------
  // Colocar ancla.
  // ----------------------------------------------------------

  setState(() {

    casilla.numero = numero;

    jugador.anclasColocadas++;

    // --------------------------------------------------------
    // ¿Ya colocó 1-6?
    // --------------------------------------------------------

    if (jugador.anclasColocadas >= 6) {

      jugador.anclasCompletadas = true;

      jugador.numeroColocadoEsteTurno = true;

      mensaje =
          '${jugador.nombre} terminó de colocar '
          'sus 6 números ancla. '
          'Ahora termina el turno.';
    }

    else {

      int siguiente =
          obtenerSiguienteAncla();

      mensaje =
          '${jugador.nombre}: coloca el '
          'número ancla $siguiente.';
    }
  });
}

void finalizarTurnoInicial() {

  if (jugador.turno != 1) {
    return;
  }

  if (!jugador.anclasCompletadas) {

    setState(() {

      mensaje =
          'Debes colocar los 6 números ancla '
          'antes de terminar tu primer turno.';
    });

    return;
  }

  pasarTurno();
}


  // ==========================================================
  // LANZAR DADOS
  // ==========================================================

  void lanzarDados() {

  if (juegoTerminado) {
    return;
  }

  // ----------------------------------------------------------
  // Las anclas deben estar colocadas.
  // ----------------------------------------------------------

  if (!jugador.anclasCompletadas) {

    setState(() {

      mensaje =
          'Primero debes colocar los números '
          'ancla 1, 2, 3, 4, 5 y 6.';
    });

    return;
  }

  // ----------------------------------------------------------
  // Ya colocó un número en este turno.
  // ----------------------------------------------------------

  if (jugador.numeroColocadoEsteTurno) {

    setState(() {

      mensaje =
          'Ya colocaste un número durante este turno. '
          'Debes pasar al siguiente turno.';
    });

    return;
  }

  // ----------------------------------------------------------
  // Evitar lanzar los dados dos veces.
  // ----------------------------------------------------------

  if (jugador.dadosLanzados) {

    setState(() {

      mensaje =
          'Ya lanzaste los dados. '
          'Debes colocar el número $dado2.';
    });

    return;
  }

  setState(() {

    dado1 =
        random.nextInt(6) + 1;

    dado2 =
        random.nextInt(6) + 1;

    jugador.dadosLanzados = true;

    mensaje =
        '${jugador.nombre}: '
        'Dado 1 = $dado1, '
        'Dado 2 = $dado2. '
        'Busca un $dado1 y coloca un $dado2 '
        'en una casilla vecina.';
  });
}


  // ==========================================================
  // ¿EXISTE EL NÚMERO?
  // ==========================================================

  bool existeNumero(
    int numero,
  ) {

    for (int f = 0; f < filas; f++) {

      for (int c = 0; c < columnas; c++) {

        if (
          jugador.tablero[f][c].numero ==
          numero
        ) {

          return true;
        }
      }
    }

    return false;
  }


  // ==========================================================
  // ¿CASILLA ES VECINA DE DADO 1?
  // ==========================================================

  bool esVecinaDelNumero(
    int fila,
    int columna,
  ) {

    for (
      Point<int> vecino
      in vecinosOrtogonal(
        fila,
        columna,
      )
    ) {

      if (
        jugador
            .tablero[vecino.x][vecino.y]
            .numero ==
        dado1
      ) {

        return true;
      }
    }

    return false;
  }


  // ============================================================
// OBTENER CONJUNTO DE COLOR
// ============================================================
//
// Un conjunto está formado ÚNICAMENTE por casillas del mismo
// color conectadas mediante:
//
//        ARRIBA
// IZQUIERDA  X  DERECHA
//        ABAJO
//
// Las diagonales NO cuentan.
//
// ============================================================

List<Point<int>> obtenerConjunto(
  int fila,
  int columna,
) {
  ColorZona color =
      jugador.tablero[fila][columna].zona;

  List<Point<int>> conjunto = [];

  // Casillas que ya fueron revisadas.
  Set<String> visitadas = {};

  // Cola de búsqueda.
  List<Point<int>> pendientes = [
    Point(fila, columna),
  ];

  while (pendientes.isNotEmpty) {
    Point<int> actual =
        pendientes.removeLast();

    String claveActual =
        '${actual.x}-${actual.y}';

    // Evitar revisar la misma casilla.
    if (visitadas.contains(claveActual)) {
      continue;
    }

    visitadas.add(claveActual);

    // ----------------------------------------------------------
    // Si la casilla no pertenece al mismo color, NO pertenece
    // al conjunto.
    // ----------------------------------------------------------

    if (jugador
            .tablero[actual.x][actual.y]
            .zona !=
        color) {
      continue;
    }

    conjunto.add(actual);

    // ----------------------------------------------------------
    // SOLAMENTE vecinos ortogonales.
    // ----------------------------------------------------------

    final vecinos = vecinosOrtogonal(
      actual.x,
      actual.y,
    );

    for (Point<int> vecino in vecinos) {
      String claveVecino =
          '${vecino.x}-${vecino.y}';

      if (!visitadas.contains(claveVecino)) {
        pendientes.add(vecino);
      }
    }
  }

  return conjunto;
}

// ============================================================
// IDENTIFICADOR ÚNICO DEL CONJUNTO
// ============================================================

String obtenerIdConjunto(
  List<Point<int>> conjunto,
) {
  List<String> posiciones = conjunto.map(
    (p) => '${p.x}-${p.y}',
  ).toList();

  posiciones.sort();

  return posiciones.join('|');
}


// ============================================================
// VALIDAR REGLA AL COLOCAR UN NÚMERO
// ============================================================

String? validarReglaColor(
  int fila,
  int columna,
  int numero,
) {
  ColorZona color =
      jugador
          .tablero[fila][columna]
          .zona;

  List<Point<int>> conjunto =
      obtenerConjunto(
    fila,
    columna,
  );

  List<int> numerosExistentes = [];

  for (Point<int> posicion in conjunto) {

    int? valor =
        jugador
            .tablero[
              posicion.x
            ][
              posicion.y
            ]
            .numero;

    if (valor != null) {
      numerosExistentes.add(valor);
    }
  }

  // ==========================================================
  // AMARILLO
  // ==========================================================

  if (color == ColorZona.amarillo) {

    if (numerosExistentes.contains(numero)) {

      return
          'En el conjunto amarillo '
          'los números deben ser diferentes.';
    }
  }

  // ==========================================================
  // VERDE
  // ==========================================================

  if (color == ColorZona.verde) {

    return null;
  }

  // ==========================================================
  // LILA
  // ==========================================================

  if (color == ColorZona.lila) {

    if (numerosExistentes.length >= 2) {

      return
          'El conjunto lila solamente '
          'puede contener 2 números.';
    }
  }

  // ==========================================================
  // AZUL
  // ==========================================================

  if (color == ColorZona.azul) {

    if (numerosExistentes.isNotEmpty) {

      int numeroEsperado =
          numerosExistentes.first;

      if (numero != numeroEsperado) {

        return
            'En el conjunto azul todos '
            'los números deben ser iguales.';
      }
    }
  }

  // ==========================================================
  // ROJO
  // ==========================================================

  if (color == ColorZona.rojo) {

    if (numerosExistentes.contains(numero)) {

      return
          'En el conjunto rojo todos '
          'los números deben ser diferentes.';
    }
  }

  return null;
}


  // ==========================================================
  // VALIDAR MOVIMIENTO
  // ==========================================================

  String? validarMovimiento(
    int fila,
    int columna,
  ) {

    if (!jugador.dadosLanzados) {

      return 'Primero debes lanzar los dados.';
    }


    Casilla casilla =
        jugador.tablero[fila][columna];


    if (casilla.ocupada) {

      return
          'Esta casilla ya está ocupada.';
    }


    // --------------------------------------------------------
    // Debe existir el número del primer dado.
    // --------------------------------------------------------

    if (!existeNumero(dado1)) {

      return
          'No existe ningún $dado1 '
          'en tu hoja.';
    }


    // --------------------------------------------------------
    // Regla de vecindad.
    // SOLO 4 DIRECCIONES.
    // --------------------------------------------------------

    if (
      !esVecinaDelNumero(
        fila,
        columna,
      )
    ) {

      return
          'La casilla debe estar arriba, '
          'abajo, izquierda o derecha '
          'de un $dado1.';
    }


    // --------------------------------------------------------
    // Regla del color.
    // --------------------------------------------------------

    String? error =
        validarReglaColor(
      fila,
      columna,
      dado2,
    );


    if (error != null) {
      return error;
    }


    return null;
  }


  // ==========================================================
  // COLOCAR NÚMERO
  // ==========================================================

  void colocarNumero(
  int fila,
  int columna,
) {

  // ==========================================================
  // PRIMER TURNO: COLOCACIÓN DE ANCLAS
  // ==========================================================

  if (jugador.turno == 1 &&
      !jugador.anclasCompletadas) {

    colocarAncla(
      fila,
      columna,
    );

    return;
  }

  // ==========================================================
  // LAS ANCLAS DEBEN ESTAR COMPLETAS
  // ==========================================================

  if (!jugador.anclasCompletadas) {

    setState(() {

      mensaje =
          'Debes colocar primero las 6 '
          'anclas: 1, 2, 3, 4, 5 y 6.';
    });

    return;
  }

  // ==========================================================
  // SOLO UN NÚMERO NORMAL POR TURNO
  // ==========================================================

  if (jugador.numeroColocadoEsteTurno) {

    setState(() {

      mensaje =
          'Ya colocaste un número en este turno. '
          'Debes pasar al siguiente jugador.';
    });

    return;
  }

  // ==========================================================
  // DEBEN HABERSE LANZADO LOS DADOS
  // ==========================================================

  if (!jugador.dadosLanzados) {

    setState(() {

      mensaje =
          'Primero debes lanzar los dados.';
    });

    return;
  }

  // ==========================================================
  // VALIDAR MOVIMIENTO
  // ==========================================================

  String? error =
      validarMovimiento(
    fila,
    columna,
  );

  if (error != null) {

    setState(() {

      mensaje = error;
    });

    return;
  }

  // ==========================================================
  // COLOCAR
  // ==========================================================

  setState(() {

    jugador
        .tablero[fila][columna]
        .numero = dado2;

    // --------------------------------------------------------
    // MARCAR QUE YA COLOCÓ SU ÚNICO NÚMERO DEL TURNO.
    // --------------------------------------------------------

    jugador.numeroColocadoEsteTurno = true;

    jugador.dadosLanzados = false;

    mensaje =
        '${jugador.nombre} colocó '
        '$dado2 correctamente.';

    // --------------------------------------------------------
    // Comprobar conjuntos.
    // --------------------------------------------------------

    comprobarConjuntos();

    // --------------------------------------------------------
    // Comprobar victoria.
    // --------------------------------------------------------

    comprobarVictoria();
  });
}


 // ============================================================
// COMPROBAR CONJUNTOS
// ============================================================
//
// Un conjunto solamente se considera COMPLETO cuando:
//
// 1. Todas sus casillas son del mismo color.
// 2. Todas las casillas están conectadas ortogonalmente.
// 3. NO existen conexiones diagonales.
// 4. TODAS las casillas del conjunto tienen número.
// 5. El conjunto todavía no ha sido puntuado.
//
// ============================================================

void comprobarConjuntos() {

  Set<String> casillasProcesadas = {};

  for (int fila = 0; fila < filas; fila++) {

    for (int columna = 0;
        columna < columnas;
        columna++) {

      String clave =
          '$fila-$columna';

      // Ya encontramos este conjunto anteriormente.
      if (casillasProcesadas.contains(clave)) {
        continue;
      }

      // --------------------------------------------------------
      // Obtener únicamente las casillas conectadas
      // ortogonalmente.
      // --------------------------------------------------------

      List<Point<int>> conjunto =
          obtenerConjunto(
        fila,
        columna,
      );

      // --------------------------------------------------------
      // Marcar todas las casillas de este conjunto
      // como procesadas.
      // --------------------------------------------------------

      for (Point<int> posicion in conjunto) {

        casillasProcesadas.add(
          '${posicion.x}-${posicion.y}',
        );
      }

      if (conjunto.isEmpty) {
        continue;
      }

      // --------------------------------------------------------
      // Identificador único.
      // --------------------------------------------------------

      String idConjunto =
          obtenerIdConjunto(
        conjunto,
      );

      // --------------------------------------------------------
      // Si ya fue puntuado, no volver a puntuarlo.
      // --------------------------------------------------------

      if (jugador
          .conjuntosCompletados
          .contains(idConjunto)) {

        continue;
      }

      // --------------------------------------------------------
      // Comprobar que TODAS las casillas estén ocupadas.
      // --------------------------------------------------------

      bool conjuntoCompleto = true;

      for (Point<int> posicion in conjunto) {

        Casilla casilla =
            jugador
                .tablero[posicion.x]
                [posicion.y];

        if (!casilla.ocupada) {

          conjuntoCompleto = false;

          break;
        }
      }

      // --------------------------------------------------------
      // Si falta aunque sea UNA casilla,
      // NO se considera lleno.
      // --------------------------------------------------------

      if (!conjuntoCompleto) {
        continue;
      }

      // --------------------------------------------------------
      // Comprobar las reglas del conjunto.
      // --------------------------------------------------------

      if (!reglaConjuntoCumplida(
        conjunto,
      )) {

        continue;
      }

      // --------------------------------------------------------
      // El conjunto está completamente lleno.
      // --------------------------------------------------------

      jugador
          .conjuntosCompletados
          .add(idConjunto);

      // --------------------------------------------------------
      // Otorgar puntos.
      //
      // Puedes cambiar esta fórmula después.
      // Por ahora cada casilla vale 1 punto.
      // --------------------------------------------------------

      jugador.puntos += conjunto.length;

      ColorZona color =
          jugador
              .tablero[
                conjunto.first.x
              ][
                conjunto.first.y
              ]
              .zona;

      mensaje +=
          ' Conjunto ${nombreZona(color)} '
          'completado: '
          '+${conjunto.length} puntos.';
    }
  }
}


// ============================================================
// VALIDAR REGLA DEL CONJUNTO
// ============================================================

bool reglaConjuntoCumplida(
  List<Point<int>> conjunto,
) {
  if (conjunto.isEmpty) {
    return false;
  }

  ColorZona color =
      jugador
          .tablero[
            conjunto.first.x
          ][
            conjunto.first.y
          ]
          .zona;

  List<int> numeros = [];

  // ----------------------------------------------------------
  // Obtener todos los números.
  // ----------------------------------------------------------

  for (Point<int> posicion in conjunto) {

    int? numero =
        jugador
            .tablero[
              posicion.x
            ][
              posicion.y
            ]
            .numero;

    // Si falta un número, el conjunto no puede estar lleno.
    if (numero == null) {
      return false;
    }

    numeros.add(numero);
  }

  // ==========================================================
  // AMARILLO
  // ==========================================================

  if (color == ColorZona.amarillo) {

    return numeros.toSet().length ==
        numeros.length;
  }

  // ==========================================================
  // VERDE
  // ==========================================================

  if (color == ColorZona.verde) {

    return true;
  }

  // ==========================================================
  // LILA
  // ==========================================================

  if (color == ColorZona.lila) {

    // Máximo 2 números en el conjunto.
    return numeros.length <= 2;
  }

  // ==========================================================
  // AZUL
  // ==========================================================

  if (color == ColorZona.azul) {

    int primerNumero =
        numeros.first;

    return numeros.every(
      (numero) =>
          numero == primerNumero,
    );
  }

  // ==========================================================
  // ROJO
  // ==========================================================

  if (color == ColorZona.rojo) {

    return numeros.toSet().length ==
        numeros.length;
  }

  return false;
}


  // ==========================================================
  // VICTORIA
  // ==========================================================

  void comprobarVictoria() {

    if (
      jugador.puntos >=
      puntosParaGanar
    ) {

      juegoTerminado = true;

      mensaje =
          '¡${jugador.nombre} ha ganado '
          'con ${jugador.puntos} puntos!';
    }
  }


  // ==========================================================
  // PASAR TURNO
  // ==========================================================

  void pasarTurno() {

  if (juegoTerminado) {
    return;
  }

  // ==========================================================
  // EL JUGADOR 1 ESTÁ EN SU PRIMER TURNO
  // ==========================================================

  if (jugador.turno == 1 &&
      !jugador.anclasCompletadas) {

    setState(() {

      mensaje =
          '${jugador.nombre} todavía debe colocar '
          'los 6 números ancla.';
    });

    return;
  }

  // ==========================================================
  // CAMBIAR JUGADOR
  // ==========================================================

  setState(() {

    // --------------------------------------------------------
    // Aumentar turno del jugador que acaba de jugar.
    // --------------------------------------------------------

    jugador.turno++;

    // --------------------------------------------------------
    // Reiniciar control del turno.
    // --------------------------------------------------------

    jugador.numeroColocadoEsteTurno = false;

    jugador.dadosLanzados = false;

    // --------------------------------------------------------
    // Siguiente jugador.
    // --------------------------------------------------------

    jugadorActual++;

    if (jugadorActual >= jugadores.length) {

      jugadorActual = 0;
    }

    // --------------------------------------------------------
    // Preparar mensaje del nuevo jugador.
    // --------------------------------------------------------

    if (!jugador.anclasCompletadas) {

      mensaje =
          '${jugador.nombre}: '
          'Turno ${jugador.turno}. '
          'Debes colocar tus números ancla '
          '1 al 6.';
    }

    else {

      mensaje =
          '${jugador.nombre}: '
          'Turno ${jugador.turno}. '
          'Lanza los dados.';
    }
  });
}


  // ==========================================================
  // NOMBRE DEL COLOR
  // ==========================================================

  String nombreZona(
    ColorZona zona,
  ) {

    switch (zona) {

      case ColorZona.amarillo:
        return 'AMARILLO';

      case ColorZona.rojo:
        return 'ROJO';

      case ColorZona.verde:
        return 'VERDE';

      case ColorZona.azul:
        return 'AZUL';

      case ColorZona.lila:
        return 'LILA';
    }
  }


  // ==========================================================
  // COLOR VISUAL
  // ==========================================================

  Color colorZona(
    ColorZona zona,
  ) {

    switch (zona) {

      case ColorZona.amarillo:
        return Colors.amber;

      case ColorZona.rojo:
        return Colors.red;

      case ColorZona.verde:
        return Colors.green;

      case ColorZona.azul:
        return Colors.cyan;

      case ColorZona.lila:
        return Colors.deepPurple;
    }
  }


  // ==========================================================
  // DADO
  // ==========================================================

  Widget dadoVisual(
    int numero,
  ) {

    return Container(

      width: 70,
      height: 70,

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade400,
          width: 2,
        ),

        boxShadow: const [

          BoxShadow(
            blurRadius: 6,
            offset: Offset(2, 3),
            color: Colors.black26,
          ),
        ],
      ),

      child: Center(

        child: Text(
          '$numero',

          style: const TextStyle(
            fontSize: 34,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }


  // ==========================================================
  // PANEL DE DADOS
  // ==========================================================

  Widget panelDados() {

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(15),

        child: Column(

          children: [

            const Text(
              'DADOS COMPARTIDOS',

              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                dadoVisual(dado1),

                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                dadoVisual(dado2),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Buscar: $dado1   →   Colocar: $dado2',

              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            
          ],
        ),
      ),
    );
  }


  // ==========================================================
  // PUNTUACIÓN
  // ==========================================================

  Widget panelPuntuacion() {

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(12),

        child: Column(

          children: [

            const Text(
              'PUNTUACIÓN',

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ...jugadores.map(
              (j) {

                bool activo =
                    j.id ==
                    jugador.id;


                return Container(

                  margin:
                      const EdgeInsets.only(
                    bottom: 5,
                  ),

                  padding:
                      const EdgeInsets.all(9),

                  decoration:
                      BoxDecoration(

                    color: activo
                        ? Colors.deepPurple
                            .withOpacity(0.12)
                        : null,

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),

                  child: Row(

                    children: [

                      Expanded(
                        child: Text(
                          j.nombre,
                          style:
                              TextStyle(
                            fontWeight:
                                activo
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),

                      Text(
                        '${j.puntos} / $puntosParaGanar',

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  // ==========================================================
  // LEYENDA
  // ==========================================================

  Widget leyenda() {

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(12),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'REGLAS DE LOS COLORES',

              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            reglaColor(
              Colors.amber,
              'Amarillo',
              'Todos diferentes',
            ),

            reglaColor(
              Colors.green,
              'Verde',
              'Cualquier número',
            ),

            reglaColor(
              Colors.deepPurple,
              'Lila',
              'Máximo 2 números',
            ),

            reglaColor(
              Colors.cyan,
              'Azul',
              'Todos iguales',
            ),

            reglaColor(
              Colors.red,
              'Rojo',
              'Todos diferentes',
            ),
          ],
        ),
      ),
    );
  }


  Widget reglaColor(
    Color color,
    String nombre,
    String regla,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 6,
      ),

      child: Row(

        children: [

          Container(
            width: 18,
            height: 18,

            decoration:
                BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(4),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              '$nombre: $regla',
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // TABLERO
  // ==========================================================

  Widget tableroVisual() {

    return AspectRatio(

      aspectRatio: 1,

      child: Container(

        padding:
            const EdgeInsets.all(7),

        decoration:
            BoxDecoration(

          color:
              Colors.grey.shade800,

          borderRadius:
              BorderRadius.circular(16),

          boxShadow: const [

            BoxShadow(
              blurRadius: 12,
              offset: Offset(2, 5),
              color: Colors.black26,
            ),
          ],
        ),

        child: GridView.builder(

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount:
              filas * columnas,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(

            crossAxisCount:
                columnas,

            crossAxisSpacing: 3,

            mainAxisSpacing: 3,
          ),

          itemBuilder:
              (context, index) {

            int fila =
                index ~/ columnas;

            int columna =
                index % columnas;


            Casilla casilla =
                jugador
                    .tablero[fila]
                    [columna];


            Color color =
                colorZona(
                  casilla.zona,
                );


            return GestureDetector(

              onTap: () {

                colocarNumero(
                  fila,
                  columna,
                );
              },

              child: AnimatedContainer(

                duration:
                    const Duration(
                  milliseconds: 120,
                ),

                decoration:
                    BoxDecoration(

                  color: casilla.ocupada
                      ? color
                      : color.withOpacity(
                          0.55,
                        ),

                  borderRadius:
                      BorderRadius.circular(
                    5,
                  ),

                  border:
                      Border.all(
                    color:
                        Colors.white
                            .withOpacity(
                      0.8,
                    ),
                    width: 1,
                  ),
                ),

                child: Center(

                  child:
                      casilla.ocupada

                          ? Text(
                              '${casilla.numero}',

                              style:
                                  const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Colors.white,
                              ),
                            )

                          : const Icon(
                              Icons.add,
                              size: 15,
                              color:
                                  Colors.white70,
                            ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  // ==========================================================
  // MENSAJE
  // ==========================================================

  Widget mensajeWidget() {

    return Container(

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(

        color:
            Colors.deepPurple.shade50,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              Colors.deepPurple.shade100,
        ),
      ),

      child: Row(

        children: [

          const Icon(
            Icons.info_outline,
            color:
                Colors.deepPurple,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              mensaje,
              style:
                  const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // BOTONES
  // ==========================================================

  Widget botones() {

    return Row(

      children: [

        Expanded(

          child:
              OutlinedButton.icon(

            onPressed:
                juegoTerminado 
                    ? null
                    : jugador.turno == 1 &&
                            !jugador.anclasCompletadas
                        ? finalizarTurnoInicial
                        : pasarTurno,

            icon: const Icon(
              Icons.skip_next,
            ),

            label: Text(
              jugador.turno == 1 &&
                      !jugador.anclasCompletadas
                  ? 'Terminar anclas'
                  : 'Pasar turno',
            ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(

          child:
              FilledButton.icon(

            onPressed: () {

              setState(() {

                iniciarJuego();
              });
            },

            icon: const Icon(
              Icons.refresh,
            ),

            label:
                const Text(
              'Nueva partida',
            ),
          ),
        ),
      ],
    );
  }


  // ==========================================================
  // INTERFAZ
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'BRILLIANT',

          style: TextStyle(
            fontWeight:
                FontWeight.bold,
            letterSpacing: 3,
          ),
        ),

        centerTitle: true,
      ),

      body: SafeArea(

        child: LayoutBuilder(

          builder:
              (context, constraints) {

            bool escritorio =
                constraints.maxWidth >= 1000;


            if (escritorio) {

              return Row(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ==========================================
                  // TABLERO
                  // ==========================================

                  Expanded(

                    flex: 7,

                    child: Padding(

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      child: Column(

                        children: [

                          mensajeWidget(),

                          const SizedBox(
                            height: 12,
                          ),

                          Expanded(

                            child: Center(

                              child:
                                  ConstrainedBox(

                                constraints:
                                    const BoxConstraints(
                                  maxWidth: 700,
                                  maxHeight: 700,
                                ),

                                child:
                                    tableroVisual(),
                              ),
                            ),
                          ),

                          
                        ],
                      ),
                    ),
                  ),


                  // ==========================================
                  // PANEL DERECHO
                  // ==========================================

                  SizedBox(

                    width: 350,

                    child:
                        SingleChildScrollView(

                      padding:
                          const EdgeInsets.fromLTRB(
                        0,
                        20,
                        20,
                        20,
                      ),

                      child: Column(

                        children: [

                          panelDados(),

                          const SizedBox(
                            height: 12,
                          ),

                          panelPuntuacion(),

                          const SizedBox(
                            height: 12,
                          ),

                          leyenda(),

                          const SizedBox(
                            height: 12,
                          ),

                          panelTurno(),

                          const SizedBox(
                          height: 12,
                          ),

                          panelDados(),

                          botones(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }


            // ================================================
            // PANTALLA PEQUEÑA
            // ================================================

            return SingleChildScrollView(

              padding:
                  const EdgeInsets.all(15),

              child: Column(

                children: [

                  mensajeWidget(),

                  const SizedBox(
                    height: 12,
                  ),

                  panelDados(),

                  const SizedBox(
                    height: 12,
                  ),

                  tableroVisual(),

                  const SizedBox(
                    height: 12,
                  ),

                  panelPuntuacion(),

                  const SizedBox(
                    height: 12,
                  ),

                  leyenda(),

                  const SizedBox(
                    height: 12,
                  ),

                  botones(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


Widget panelTurno() {

  return Card(

    child: Padding(

      padding:
          const EdgeInsets.all(15),

      child: Column(

        children: [

          const Text(
            'TURNO ACTUAL',

            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'Jugador: ${jugador.nombre}',

            style:
                const TextStyle(
              fontSize: 17,
            ),
          ),

          Text(
            'Turno: ${jugador.turno}',

            style:
                const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          if (jugador.turno == 1 &&
              !jugador.anclasCompletadas)

            Text(
              'Anclas: '
              '${jugador.anclasColocadas}/6',

              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            )

          else

            Text(
              jugador.numeroColocadoEsteTurno
                  ? 'Número colocado: 1/1'
                  : 'Número colocado: 0/1',

              style:
                  const TextStyle(
                fontSize: 16,
              ),
            ),
        ],
      ),
    ),
  );
}
    }

// ============================================================
// EXTENSIÓN PARA ORDENAR IDENTIFICADORES DE CONJUNTOS
// ============================================================

extension OrdenarString on List<String> {

  String sortedString() {

    List<String> copia =
        List<String>.from(this);

    copia.sort();

    return copia.join('|');
  }
}