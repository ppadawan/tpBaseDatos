-- =====================================================================
-- Centro Médico "Saludable" — Datos de prueba (DML)
-- =====================================================================

-- =====================================================================
-- 1. Servicio
-- =====================================================================
INSERT INTO Servicio (id_servicio, nombre) VALUES
(1, 'Radiología'),
(2, 'Tomografía'),
(3, 'Ecografía');

-- =====================================================================
-- 2. ObraSocial
-- =====================================================================
INSERT INTO ObraSocial (id_obra_social, nombre) VALUES
(1, 'OSDE'),
(2, 'Swiss Medical'),
(3, 'PAMI');

-- =====================================================================
-- 3. Paciente
-- =====================================================================
INSERT INTO Paciente
    (id_paciente, dni, nombre, apellido, fecha_nacimiento, telefono, email, id_obra_social, numero_afiliado, activo, fecha_baja)
VALUES
    (1, 20111222, 'Martina',  'Suárez',  '1990-03-14', '11-4000-1111', 'martina.suarez@mail.com',  1, 'OSDE-0001', TRUE,  NULL),
    (2, 20222333, 'Federico', 'López',   '1985-07-22', '11-4000-2222', 'federico.lopez@mail.com',  2, 'SM-0002',   TRUE,  NULL),
    (3, 20333444, 'Camila',   'Fernández','1998-11-05','11-4000-3333', 'camila.fernandez@mail.com',NULL, NULL,     TRUE,  NULL),
    (4, 20444555, 'Roberto',  'Díaz',    '1970-01-30', '11-4000-4444', 'roberto.diaz@mail.com',    3, 'PAMI-0004', TRUE,  NULL),
    (5, 20555666, 'Sofía',    'Torres',  '2001-09-18', '11-4000-5555', 'sofia.torres@mail.com',    NULL, NULL,     TRUE,  NULL);

-- =====================================================================
-- 4. Medico (incluye auto-relación de supervisión)
-- =====================================================================
INSERT INTO Medico
    (id_medico, dni, nombre, apellido, id_servicio, id_medico_supervisor, activo, fecha_baja)
VALUES
    (1, 27111222, 'Juan',   'Pérez',  1, NULL, TRUE, NULL),
    (2, 27222333, 'Ana',    'Gómez',  1, 1,    TRUE, NULL),  -- supervisada por Juan Pérez
    (3, 27333444, 'Carlos', 'Ruiz',   2, NULL, TRUE, NULL),
    (4, 27444555, 'Laura',  'Díaz',   3, NULL, TRUE, NULL);

-- =====================================================================
-- 5. Practica
-- =====================================================================
INSERT INTO Practica (id_practica, nombre, duracion_minutos, id_servicio, activo, fecha_baja) VALUES
(1, 'Radiografía de tórax',            15, 1, TRUE, NULL),
(2, 'Radiografía de columna',          20, 1, TRUE, NULL),
(3, 'Tomografía computada de cráneo',  30, 2, TRUE, NULL),
(4, 'Tomografía computada de abdomen', 45, 2, TRUE, NULL),
(5, 'Ecografía abdominal',             30, 3, TRUE, NULL),
(6, 'Ecografía obstétrica',            30, 3, TRUE, NULL);

-- =====================================================================
-- 6. Equipo
-- =====================================================================
INSERT INTO Equipo (id_equipo, nombre, id_servicio, activo, fecha_baja) VALUES
(1, 'Equipo de Rayos X 1', 1, TRUE, NULL),
(2, 'Equipo de Rayos X 2', 1, TRUE, NULL),
(3, 'Tomógrafo 1',         2, TRUE, NULL),
(4, 'Ecógrafo 1',          3, TRUE, NULL);

-- =====================================================================
-- 7. Medico_Practica (dispara validar_servicio_medico_practica)
-- =====================================================================
INSERT INTO Medico_Practica (id_medico, id_practica) VALUES
(1, 1),  -- Juan Pérez - Radiografía de tórax
(1, 2),  -- Juan Pérez - Radiografía de columna
(2, 1),  -- Ana Gómez  - Radiografía de tórax
(3, 3),  -- Carlos Ruiz - Tomografía de cráneo
(3, 4),  -- Carlos Ruiz - Tomografía de abdomen
(4, 5),  -- Laura Díaz - Ecografía abdominal
(4, 6);  -- Laura Díaz - Ecografía obstétrica

-- =====================================================================
-- 8. Practica_Equipo (dispara validar_servicio_practica_equipo)
-- =====================================================================
INSERT INTO Practica_Equipo (id_practica, id_equipo) VALUES
(1, 1), (1, 2),  -- Radiografía de tórax   -> Rayos X 1 y 2
(2, 1), (2, 2),  -- Radiografía de columna -> Rayos X 1 y 2
(3, 3),          -- Tomografía de cráneo   -> Tomógrafo 1
(4, 3),          -- Tomografía de abdomen  -> Tomógrafo 1
(5, 4),          -- Ecografía abdominal    -> Ecógrafo 1
(6, 4);          -- Ecografía obstétrica   -> Ecógrafo 1

-- =====================================================================
-- 9. ObraSocial_Practica
-- =====================================================================
INSERT INTO ObraSocial_Practica (id_obra_social, id_practica) VALUES
-- OSDE cubre todas las prácticas
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
-- Swiss Medical cubre radiografías y ecografías, no tomografías
(2, 1), (2, 2), (2, 5), (2, 6),
-- PAMI cubre solo radiografía de tórax y ecografía abdominal
(3, 1), (3, 5);

-- =====================================================================
-- 10. Disponibilidad (franjas semanales recurrentes de cada médico)
-- =====================================================================
INSERT INTO Disponibilidad (id_disponibilidad, id_medico, dia_semana, hora_desde, hora_hasta) VALUES
(1, 1, 'Lunes',     '08:00', '12:00'),  -- Juan Pérez
(2, 1, 'Miercoles', '08:00', '12:00'),
(3, 2, 'Martes',    '09:00', '13:00'),  -- Ana Gómez
(4, 2, 'Jueves',    '09:00', '13:00'),
(5, 3, 'Lunes',     '14:00', '18:00'),  -- Carlos Ruiz
(6, 3, 'Viernes',   '09:00', '13:00'),
(7, 4, 'Martes',    '08:00', '12:00'),  -- Laura Díaz
(8, 4, 'Sabado',    '08:00', '12:00');

-- =====================================================================
-- 11. FranjaAtencion (horario general del centro: L-V 8-20, Sáb 8-14)
-- =====================================================================
INSERT INTO FranjaAtencion (id_franja, dia_semana, hora_desde, hora_hasta) VALUES
(1, 'Lunes',     '08:00', '20:00'),
(2, 'Martes',    '08:00', '20:00'),
(3, 'Miercoles', '08:00', '20:00'),
(4, 'Jueves',    '08:00', '20:00'),
(5, 'Viernes',   '08:00', '20:00'),
(6, 'Sabado',    '08:00', '14:00');
-- Domingo: sin fila -> el centro no atiende, ningún turno puede caer ese día

-- =====================================================================
-- 12. Turno
-- Fechas usadas (año 2026): 28/09 = lunes, 29/09 = martes, 30/09 = miércoles,
-- 02/10 = viernes — elegidas para coincidir con la Disponibilidad y
-- FranjaAtencion cargadas arriba.
-- =====================================================================
INSERT INTO Turno
    (id_turno, id_paciente, id_practica, id_medico, id_equipo, fecha, hora,
     medio_solicitud, estado, fecha_confirmacion, medio_confirmacion)
VALUES
    -- 1) Reservado, solicitado por teléfono, sin confirmar todavía
    (1, 1, 1, 1, 1, '2026-09-28', '09:00', 'Telefono', 'Reservado', NULL, NULL),
    -- 2) Reservado, solicitado por email
    (2, 2, 3, 3, 3, '2026-09-28', '14:30', 'Email',    'Reservado', NULL, NULL),
    -- 3) Reservado, paciente sin obra social
    (3, 3, 5, 4, 4, '2026-09-29', '08:30', 'Telefono', 'Reservado', NULL, NULL),
    -- 4) Confirmado: se registró fecha y medio de confirmación
    (4, 4, 1, 2, 2, '2026-09-29', '09:30', 'Email',    'Confirmado', '2026-09-27', 'Telefono'),
    -- 5) Se va a cancelar más abajo, para mostrar cómo se libera la agenda
    (5, 5, 4, 3, 3, '2026-10-02', '10:00', 'Telefono', 'Reservado', NULL, NULL),
    -- 6) Confirmado, solicitado y confirmado por email
    (6, 1, 2, 1, 1, '2026-09-30', '08:00', 'Email',    'Confirmado', '2026-09-26', 'Email');

-- =====================================================================
-- 13. Agenda_Equipo (una fila por turno activo, dispara validar_solapamiento_equipo)
-- =====================================================================
INSERT INTO Agenda_Equipo (id_agenda_equipo, id_equipo, fecha, hora, hora_fin, id_turno) VALUES
(1, 1, '2026-09-28', '09:00', '09:15', 1),
(2, 3, '2026-09-28', '14:30', '15:00', 2),
(3, 4, '2026-09-29', '08:30', '09:00', 3),
(4, 2, '2026-09-29', '09:30', '09:45', 4),
(5, 3, '2026-10-02', '10:00', '10:45', 5),
(6, 1, '2026-09-30', '08:00', '08:20', 6);

-- =====================================================================
-- 14. Agenda_Medico (una fila por turno activo, dispara validar_solapamiento_medico)
-- =====================================================================
INSERT INTO Agenda_Medico (id_agenda_medico, id_medico, fecha, hora, hora_fin, id_turno) VALUES
(1, 1, '2026-09-28', '09:00', '09:15', 1),
(2, 3, '2026-09-28', '14:30', '15:00', 2),
(3, 4, '2026-09-29', '08:30', '09:00', 3),
(4, 2, '2026-09-29', '09:30', '09:45', 4),
(5, 3, '2026-10-02', '10:00', '10:45', 5),
(6, 1, '2026-09-30', '08:00', '08:20', 6);

-- =====================================================================
-- 15. Ejemplo de cancelación de turno (Turno 5)
-- Procedimiento documentado: se marca el turno como Cancelado y se
-- eliminan sus filas de agenda para liberar el horario del médico y del equipo.
-- =====================================================================
UPDATE Turno
SET estado = 'Cancelado'
WHERE id_turno = 5;

DELETE FROM Agenda_Equipo WHERE id_turno = 5;
DELETE FROM Agenda_Medico WHERE id_turno = 5;

