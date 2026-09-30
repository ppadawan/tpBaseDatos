-- =====================================================================
-- Centro Médico "Saludable" 
-- =====================================================================

-- =====================================================================
-- 0. CREACION BASE DE DATOS    
-- =====================================================================
SET NAMES utf8mb4;
SET SQL_MODE = "STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION";

CREATE DATABASE IF NOT EXISTS mi_apellido    
   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
 USE mi_apellido;

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
-- 1. ENTIDADES BASE
-- =====================================================================

-- ---------------------------------------------------------------------
-- Servicio
-- ---------------------------------------------------------------------
CREATE TABLE Servicio (
    id_servicio     INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- ObraSocial
-- ---------------------------------------------------------------------
CREATE TABLE ObraSocial (
    id_obra_social  INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Paciente
-- ---------------------------------------------------------------------
CREATE TABLE Paciente (
    id_paciente         INT AUTO_INCREMENT PRIMARY KEY,
    dni                 INT NOT NULL UNIQUE,
    nombre              VARCHAR(100) NOT NULL,
    apellido            VARCHAR(100) NOT NULL,
    fecha_nacimiento    DATE NOT NULL,
    telefono            VARCHAR(30),
    email               VARCHAR(150),
    id_obra_social      INT NULL,
    numero_afiliado     VARCHAR(50) NULL,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_baja          DATE NULL,
    CONSTRAINT fk_paciente_obra_social
        FOREIGN KEY (id_obra_social) REFERENCES ObraSocial(id_obra_social)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Validación de coherencia de afiliación del paciente
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_afiliacion_paciente_insert
BEFORE INSERT ON Paciente
FOR EACH ROW
BEGIN
    IF (NEW.id_obra_social IS NULL AND NEW.numero_afiliado IS NOT NULL)
       OR (NEW.id_obra_social IS NOT NULL AND NEW.numero_afiliado IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La obra social y el número de afiliado deben informarse juntos o quedar ambos NULL.';
    END IF;
END$$

CREATE TRIGGER validar_afiliacion_paciente_update
BEFORE UPDATE ON Paciente
FOR EACH ROW
BEGIN
    IF (NEW.id_obra_social IS NULL AND NEW.numero_afiliado IS NOT NULL)
       OR (NEW.id_obra_social IS NOT NULL AND NEW.numero_afiliado IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La obra social y el número de afiliado deben informarse juntos o quedar ambos NULL.';
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- Medico (incluye auto-relación de supervisión)
-- ---------------------------------------------------------------------
CREATE TABLE Medico (
    id_medico               INT AUTO_INCREMENT PRIMARY KEY,
    dni                     INT NOT NULL UNIQUE,
    nombre                  VARCHAR(100) NOT NULL,
    apellido                VARCHAR(100) NOT NULL,
    id_servicio             INT NOT NULL,
    id_medico_supervisor    INT NULL,
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_baja              DATE NULL,
    CONSTRAINT fk_medico_servicio
        FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_medico_supervisor
        FOREIGN KEY (id_medico_supervisor) REFERENCES Medico(id_medico)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Validación de autosupervisión del médico
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_medico_no_autosupervision_insert
AFTER INSERT ON Medico
FOR EACH ROW
BEGIN
    IF NEW.id_medico_supervisor IS NOT NULL
       AND NEW.id_medico_supervisor = NEW.id_medico THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un médico no puede supervisarse a sí mismo.';
    END IF;
END$$

CREATE TRIGGER validar_medico_no_autosupervision_update
AFTER UPDATE ON Medico
FOR EACH ROW
BEGIN
    IF NEW.id_medico_supervisor IS NOT NULL
       AND NEW.id_medico_supervisor = NEW.id_medico THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un médico no puede supervisarse a sí mismo.';
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- Practica
-- ---------------------------------------------------------------------
CREATE TABLE Practica (
    id_practica         INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(150) NOT NULL,
    duracion_minutos    INT NOT NULL,
    id_servicio         INT NOT NULL,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_baja          DATE NULL,
    CONSTRAINT fk_practica_servicio
        FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_practica_duracion
        CHECK (duracion_minutos > 0)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Equipo
-- ---------------------------------------------------------------------
CREATE TABLE Equipo (
    id_equipo       INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    id_servicio     INT NOT NULL,
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_baja      DATE NULL,
    CONSTRAINT fk_equipo_servicio
        FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =====================================================================
-- 2. ENTIDADES ASOCIATIVAS (relaciones N:M)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Medico_Practica — qué prácticas puede realizar cada médico
-- ---------------------------------------------------------------------
CREATE TABLE Medico_Practica (
    id_medico       INT NOT NULL,
    id_practica     INT NOT NULL,
    PRIMARY KEY (id_medico, id_practica),
    CONSTRAINT fk_mp_medico
        FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mp_practica
        FOREIGN KEY (id_practica) REFERENCES Practica(id_practica)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Practica_Equipo — compatibilidad entre práctica y equipo
-- ---------------------------------------------------------------------
CREATE TABLE Practica_Equipo (
    id_practica     INT NOT NULL,
    id_equipo       INT NOT NULL,
    PRIMARY KEY (id_practica, id_equipo),
    CONSTRAINT fk_pe_practica
        FOREIGN KEY (id_practica) REFERENCES Practica(id_practica)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pe_equipo
        FOREIGN KEY (id_equipo) REFERENCES Equipo(id_equipo)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- ObraSocial_Practica — qué prácticas cubre cada obra social
-- ---------------------------------------------------------------------
CREATE TABLE ObraSocial_Practica (
    id_obra_social  INT NOT NULL,
    id_practica     INT NOT NULL,
    PRIMARY KEY (id_obra_social, id_practica),
    CONSTRAINT fk_op_obra_social
        FOREIGN KEY (id_obra_social) REFERENCES ObraSocial(id_obra_social)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_op_practica
        FOREIGN KEY (id_practica) REFERENCES Practica(id_practica)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =====================================================================
-- 3. DISPONIBILIDAD Y HORARIO DEL CENTRO
-- =====================================================================

-- ---------------------------------------------------------------------
-- Disponibilidad — franjas semanales recurrentes de cada médico
-- ---------------------------------------------------------------------
CREATE TABLE Disponibilidad (
    id_disponibilidad  INT AUTO_INCREMENT PRIMARY KEY,
    id_medico          INT NOT NULL,
    dia_semana         ENUM('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado','Domingo') NOT NULL,
    hora_desde         TIME NOT NULL,
    hora_hasta         TIME NOT NULL,
    CONSTRAINT fk_disponibilidad_medico
        FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_disponibilidad_franja_valida
        CHECK (hora_desde < hora_hasta)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- FranjaAtencion — horario general de atención del centro
-- (tabla de referencia; no se enlaza por FK a Turno, se usa para validar)
-- ---------------------------------------------------------------------
CREATE TABLE FranjaAtencion (
    id_franja       INT AUTO_INCREMENT PRIMARY KEY,
    dia_semana      ENUM('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado','Domingo') NOT NULL,
    hora_desde      TIME NOT NULL,
    hora_hasta      TIME NOT NULL,
    CONSTRAINT chk_franja_atencion_valida
        CHECK (hora_desde < hora_hasta)
) ENGINE = InnoDB;

-- =====================================================================
-- 4. TURNO Y AGENDAS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Turno
-- ---------------------------------------------------------------------
CREATE TABLE Turno (
    id_turno            INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente         INT NOT NULL,
    id_practica         INT NOT NULL,
    id_medico           INT NOT NULL,
    id_equipo           INT NOT NULL,
    fecha               DATE NOT NULL,
    hora                TIME NOT NULL,
    medio_solicitud     ENUM('Telefono','Email') NOT NULL,
    estado              ENUM('Reservado','Confirmado','Cancelado') NOT NULL DEFAULT 'Reservado',
    fecha_confirmacion  DATE NULL,
    medio_confirmacion  ENUM('Telefono','Email') NULL,
    CONSTRAINT fk_turno_paciente
        FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_turno_practica
        FOREIGN KEY (id_practica) REFERENCES Practica(id_practica)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_turno_medico
        FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_turno_equipo
        FOREIGN KEY (id_equipo) REFERENCES Equipo(id_equipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Agenda_Equipo — ocupación en el tiempo de cada equipo
-- ---------------------------------------------------------------------
CREATE TABLE Agenda_Equipo (
    id_agenda_equipo   INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo          INT NOT NULL,
    fecha              DATE NOT NULL,
    hora               TIME NOT NULL,
    hora_fin           TIME NOT NULL,
    id_turno           INT NOT NULL,
    CONSTRAINT fk_agenda_equipo_equipo
        FOREIGN KEY (id_equipo) REFERENCES Equipo(id_equipo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_agenda_equipo_turno
        FOREIGN KEY (id_turno) REFERENCES Turno(id_turno)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_agenda_equipo_horario_valido
        CHECK (hora < hora_fin)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Agenda_Medico — ocupación en el tiempo de cada médico
-- ---------------------------------------------------------------------
CREATE TABLE Agenda_Medico (
    id_agenda_medico   INT AUTO_INCREMENT PRIMARY KEY,
    id_medico          INT NOT NULL,
    fecha              DATE NOT NULL,
    hora               TIME NOT NULL,
    hora_fin           TIME NOT NULL,
    id_turno           INT NOT NULL,
    CONSTRAINT fk_agenda_medico_medico
        FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_agenda_medico_turno
        FOREIGN KEY (id_turno) REFERENCES Turno(id_turno)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_agenda_medico_horario_valido
        CHECK (hora < hora_fin)
) ENGINE = InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- 5. TRIGGERS DE VALIDACIÓN
-- =====================================================================

-- ---------------------------------------------------------------------
-- 5.1 No solapamiento de turnos por equipo (Agenda_Equipo)
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_solapamiento_equipo
BEFORE INSERT ON Agenda_Equipo
FOR EACH ROW
BEGIN
    DECLARE cantidad_conflictos INT;

    SELECT COUNT(*) INTO cantidad_conflictos
    FROM Agenda_Equipo
    WHERE id_equipo = NEW.id_equipo
      AND fecha = NEW.fecha
      AND hora < NEW.hora_fin
      AND NEW.hora < hora_fin;

    IF cantidad_conflictos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El equipo ya tiene un turno asignado que se superpone con ese horario.';
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 5.2 No solapamiento de turnos por médico (Agenda_Medico)
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_solapamiento_medico
BEFORE INSERT ON Agenda_Medico
FOR EACH ROW
BEGIN
    DECLARE cantidad_conflictos INT;

    SELECT COUNT(*) INTO cantidad_conflictos
    FROM Agenda_Medico
    WHERE id_medico = NEW.id_medico
      AND fecha = NEW.fecha
      AND hora < NEW.hora_fin
      AND NEW.hora < hora_fin;

    IF cantidad_conflictos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El médico ya tiene un turno asignado que se superpone con ese horario.';
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 5.3 Coherencia de servicio: Médico y Práctica deben ser del mismo servicio
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_servicio_medico_practica
BEFORE INSERT ON Medico_Practica
FOR EACH ROW
BEGIN
    DECLARE servicio_medico INT;
    DECLARE servicio_practica INT;

    SELECT id_servicio INTO servicio_medico FROM Medico WHERE id_medico = NEW.id_medico;
    SELECT id_servicio INTO servicio_practica FROM Practica WHERE id_practica = NEW.id_practica;

    IF servicio_medico <> servicio_practica THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El médico y la práctica pertenecen a servicios distintos.';
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 5.4 Coherencia de servicio: Práctica y Equipo deben ser del mismo servicio
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_servicio_practica_equipo
BEFORE INSERT ON Practica_Equipo
FOR EACH ROW
BEGIN
    DECLARE servicio_practica INT;
    DECLARE servicio_equipo INT;

    SELECT id_servicio INTO servicio_practica FROM Practica WHERE id_practica = NEW.id_practica;
    SELECT id_servicio INTO servicio_equipo FROM Equipo WHERE id_equipo = NEW.id_equipo;

    IF servicio_practica <> servicio_equipo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La práctica y el equipo pertenecen a servicios distintos.';
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 5.5 Horario de atención del centro (FranjaAtencion) contra Turno
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_horario_atencion_turno
BEFORE INSERT ON Turno
FOR EACH ROW
BEGIN
    DECLARE v_dia_semana VARCHAR(15);
    DECLARE v_duracion INT;
    DECLARE v_hora_fin TIME;
    DECLARE v_franjas_ok INT;

    SET v_dia_semana = CASE DAYOFWEEK(NEW.fecha)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Lunes'
        WHEN 3 THEN 'Martes'
        WHEN 4 THEN 'Miercoles'
        WHEN 5 THEN 'Jueves'
        WHEN 6 THEN 'Viernes'
        WHEN 7 THEN 'Sabado'
    END;

    SELECT duracion_minutos INTO v_duracion
    FROM Practica WHERE id_practica = NEW.id_practica;

    SET v_hora_fin = ADDTIME(NEW.hora, SEC_TO_TIME(v_duracion * 60));

    SELECT COUNT(*) INTO v_franjas_ok
    FROM FranjaAtencion
    WHERE dia_semana = v_dia_semana
      AND hora_desde <= NEW.hora
      AND hora_hasta >= v_hora_fin;

    IF v_franjas_ok = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El turno cae fuera del horario de atención del centro.';
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 5.6 Disponibilidad del médico contra Turno
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER validar_disponibilidad_medico_turno
BEFORE INSERT ON Turno
FOR EACH ROW
BEGIN
    DECLARE v_dia_semana VARCHAR(15);
    DECLARE v_duracion INT;
    DECLARE v_hora_fin TIME;
    DECLARE v_franjas_ok INT;

    SET v_dia_semana = CASE DAYOFWEEK(NEW.fecha)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Lunes'
        WHEN 3 THEN 'Martes'
        WHEN 4 THEN 'Miercoles'
        WHEN 5 THEN 'Jueves'
        WHEN 6 THEN 'Viernes'
        WHEN 7 THEN 'Sabado'
    END;

    SELECT duracion_minutos INTO v_duracion
    FROM Practica WHERE id_practica = NEW.id_practica;

    SET v_hora_fin = ADDTIME(NEW.hora, SEC_TO_TIME(v_duracion * 60));

    SELECT COUNT(*) INTO v_franjas_ok
    FROM Disponibilidad
    WHERE id_medico = NEW.id_medico
      AND dia_semana = v_dia_semana
      AND hora_desde <= NEW.hora
      AND hora_hasta >= v_hora_fin;

    IF v_franjas_ok = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El médico no tiene disponibilidad declarada para ese día y horario.';
    END IF;
END$$

DELIMITER ;

-- =====================================================================
-- Fin del script
-- =====================================================================
