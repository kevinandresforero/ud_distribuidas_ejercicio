-- =============================================================
--  NODO 2: ud_macarena  -  SERVIDOR LOCAL LA MACARENA
--  Fragmento horizontal: solo datos de sede La Macarena
-- =============================================================

CREATE DATABASE IF NOT EXISTS ud_macarena
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ud_macarena;

-- Fragmentacion HORIZONTAL: filas donde Sede = 'La Macarena'
CREATE TABLE PREGRADO_MACARENA (
    Cod_Pregrado  VARCHAR(10)   NOT NULL,
    Nombre        VARCHAR(100)  NOT NULL,
    Creditos      INT           NOT NULL,
    Nota_Minima   DECIMAL(4,2)  NOT NULL,
    Sede          VARCHAR(50)   NOT NULL DEFAULT 'La Macarena',
    CONSTRAINT PK_PRE_MAC PRIMARY KEY (Cod_Pregrado)
);

CREATE TABLE CURSO_MACARENA (
    Cod_Pregrado_Curso    VARCHAR(15)  NOT NULL,
    Capacidad_Estudiantes INT          NOT NULL,
    CONSTRAINT PK_CUR_MAC PRIMARY KEY (Cod_Pregrado_Curso)
);

CREATE TABLE GRUPO_MACARENA (
    Cod_Grupo          VARCHAR(10)   NOT NULL,
    Cod_Pregrado_Curso VARCHAR(15)   NOT NULL,
    Curso              VARCHAR(100)  NOT NULL,
    Semestre           INT           NOT NULL,
    CONSTRAINT PK_GRU_MAC   PRIMARY KEY (Cod_Grupo),
    CONSTRAINT FK_GRU_CUR_M FOREIGN KEY (Cod_Pregrado_Curso)
        REFERENCES CURSO_MACARENA(Cod_Pregrado_Curso)
);

-- Fragmentacion MIXTA: horizontal (La Macarena) + vertical
CREATE TABLE ASIGNATURA_MACARENA (
    Cod_Asignatura    VARCHAR(10)   NOT NULL,
    Nombre_Asignatura VARCHAR(100)  NOT NULL,
    Cod_Pregrado      VARCHAR(10)   NOT NULL,
    Cod_Curso         VARCHAR(15)   NOT NULL,
    Horas_Semanales   INT           NOT NULL,
    CONSTRAINT PK_ASI_MAC   PRIMARY KEY (Cod_Asignatura),
    CONSTRAINT FK_ASI_PRE_M FOREIGN KEY (Cod_Pregrado)
        REFERENCES PREGRADO_MACARENA(Cod_Pregrado),
    CONSTRAINT FK_ASI_CUR_M FOREIGN KEY (Cod_Curso)
        REFERENCES CURSO_MACARENA(Cod_Pregrado_Curso)
);

-- Fragmentacion VERTICAL de PROFESOR (solo datos publicos)
CREATE TABLE PROFESOR_LOCAL_MACARENA (
    Numero_Documento  VARCHAR(20)   NOT NULL,
    Nombre            VARCHAR(100)  NOT NULL,
    E_Mail            VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_PRO_MAC PRIMARY KEY (Numero_Documento)
);

-- ============================================================
-- DATOS DE PRUEBA - SOLO FRAGMENTO LA MACARENA
-- ============================================================

INSERT INTO PREGRADO_MACARENA VALUES
    ('ADM-001','Administracion de Empresas',148,3.0,'La Macarena'),
    ('DER-001','Derecho',170,3.0,'La Macarena');

INSERT INTO CURSO_MACARENA VALUES
    ('ADM001-ADM',45),('DER001-CON',50);

INSERT INTO GRUPO_MACARENA VALUES
    ('G-003','ADM001-ADM','Fund de Administracion',1),
    ('G-004','DER001-CON','Derecho Constitucional',1);

INSERT INTO ASIGNATURA_MACARENA VALUES
    ('ASG-003','Fund de Administracion','ADM-001','ADM001-ADM',3),
    ('ASG-004','Derecho Constitucional','DER-001','DER001-CON',4);

INSERT INTO PROFESOR_LOCAL_MACARENA VALUES
    ('12345678','Carlos Rodriguez','c.rodriguez@udistrital.edu.co'),
    ('23456789','Maria Gonzalez','m.gonzalez@udistrital.edu.co'),
    ('34567890','Jorge Martinez','j.martinez@udistrital.edu.co'),
    ('45678901','Laura Perez','l.perez@udistrital.edu.co');

-- ============================================================
-- DATOS DE PRUEBA ADICIONALES - LA MACARENA
-- ============================================================

INSERT INTO PREGRADO_MACARENA VALUES
    ('ECO-001','Economia',150,3.0,'La Macarena'),
    ('PSI-001','Psicologia',165,3.0,'La Macarena');

INSERT INTO CURSO_MACARENA VALUES
    ('ECO001-MIC',40),('PSI001-GEN',30);

INSERT INTO GRUPO_MACARENA VALUES
    ('G-009','ECO001-MIC','Microeconomia',1),
    ('G-010','PSI001-GEN','Psicologia General',2);

INSERT INTO ASIGNATURA_MACARENA VALUES
    ('ASG-009','Microeconomia','ECO-001','ECO001-MIC',4),
    ('ASG-010','Psicologia General','PSI-001','PSI001-GEN',3);

INSERT INTO PROFESOR_LOCAL_MACARENA VALUES
    ('56789012','Ana Torres','a.torres@udistrital.edu.co'),
    ('67890123','Pedro Ramirez','p.ramirez@udistrital.edu.co'),
    ('78901234','Diana Lopez','d.lopez@udistrital.edu.co'),
    ('89012345','Santiago Herrera','s.herrera@udistrital.edu.co');

-- ============================================================
-- CONSULTAS DE VERIFICACION
-- ============================================================

SELECT * FROM PREGRADO_MACARENA;

SELECT * FROM ASIGNATURA_MACARENA;

SELECT * FROM PROFESOR_LOCAL_MACARENA;

-- FIN DEL SCRIPT
