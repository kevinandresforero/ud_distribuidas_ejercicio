-- =============================================================
--  NODO 3: ud_ciudad_bolivar  -  SERVIDOR LOCAL CIUDAD BOLIVAR
--  Fragmento horizontal: solo datos de sede Ciudad Bolivar
-- =============================================================

CREATE DATABASE IF NOT EXISTS ud_ciudad_bolivar
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ud_ciudad_bolivar;

-- Fragmentacion HORIZONTAL: filas donde Sede = 'Ciudad Bolivar'
CREATE TABLE PREGRADO_BOLIVAR (
    Cod_Pregrado  VARCHAR(10)   NOT NULL,
    Nombre        VARCHAR(100)  NOT NULL,
    Creditos      INT           NOT NULL,
    Nota_Minima   DECIMAL(4,2)  NOT NULL,
    Sede          VARCHAR(50)   NOT NULL DEFAULT 'Ciudad Bolivar',
    CONSTRAINT PK_PRE_BOL PRIMARY KEY (Cod_Pregrado)
);

CREATE TABLE CURSO_BOLIVAR (
    Cod_Pregrado_Curso    VARCHAR(15)  NOT NULL,
    Capacidad_Estudiantes INT          NOT NULL,
    CONSTRAINT PK_CUR_BOL PRIMARY KEY (Cod_Pregrado_Curso)
);

CREATE TABLE GRUPO_BOLIVAR (
    Cod_Grupo          VARCHAR(10)   NOT NULL,
    Cod_Pregrado_Curso VARCHAR(15)   NOT NULL,
    Curso              VARCHAR(100)  NOT NULL,
    Semestre           INT           NOT NULL,
    CONSTRAINT PK_GRU_BOL   PRIMARY KEY (Cod_Grupo),
    CONSTRAINT FK_GRU_CUR_B FOREIGN KEY (Cod_Pregrado_Curso)
        REFERENCES CURSO_BOLIVAR(Cod_Pregrado_Curso)
);

-- Fragmentacion MIXTA: horizontal (Ciudad Bolivar) + vertical
CREATE TABLE ASIGNATURA_BOLIVAR (
    Cod_Asignatura    VARCHAR(10)   NOT NULL,
    Nombre_Asignatura VARCHAR(100)  NOT NULL,
    Cod_Pregrado      VARCHAR(10)   NOT NULL,
    Cod_Curso         VARCHAR(15)   NOT NULL,
    Horas_Semanales   INT           NOT NULL,
    CONSTRAINT PK_ASI_BOL   PRIMARY KEY (Cod_Asignatura),
    CONSTRAINT FK_ASI_PRE_B FOREIGN KEY (Cod_Pregrado)
        REFERENCES PREGRADO_BOLIVAR(Cod_Pregrado),
    CONSTRAINT FK_ASI_CUR_B FOREIGN KEY (Cod_Curso)
        REFERENCES CURSO_BOLIVAR(Cod_Pregrado_Curso)
);

-- Fragmentacion VERTICAL de PROFESOR (solo datos publicos)
CREATE TABLE PROFESOR_LOCAL_BOLIVAR (
    Numero_Documento  VARCHAR(20)   NOT NULL,
    Nombre            VARCHAR(100)  NOT NULL,
    E_Mail            VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_PRO_BOL PRIMARY KEY (Numero_Documento)
);

-- ============================================================
-- DATOS DE PRUEBA - SOLO FRAGMENTO CIUDAD BOLIVAR
-- ============================================================

INSERT INTO PREGRADO_BOLIVAR VALUES
    ('LIC-001','Licenciatura en Educacion',155,3.0,'Ciudad Bolivar'),
    ('ART-001','Artes Visuales',140,3.0,'Ciudad Bolivar');

INSERT INTO CURSO_BOLIVAR VALUES
    ('LIC001-PED',30),('ART001-DIS',25);

INSERT INTO GRUPO_BOLIVAR VALUES
    ('G-005','LIC001-PED','Pedagogia General',2),
    ('G-006','ART001-DIS','Diseno Basico',1);

INSERT INTO ASIGNATURA_BOLIVAR VALUES
    ('ASG-005','Pedagogia General','LIC-001','LIC001-PED',3),
    ('ASG-006','Diseno Basico','ART-001','ART001-DIS',5);

INSERT INTO PROFESOR_LOCAL_BOLIVAR VALUES
    ('12345678','Carlos Rodriguez','c.rodriguez@udistrital.edu.co'),
    ('23456789','Maria Gonzalez','m.gonzalez@udistrital.edu.co'),
    ('34567890','Jorge Martinez','j.martinez@udistrital.edu.co'),
    ('45678901','Laura Perez','l.perez@udistrital.edu.co');

-- ============================================================
-- DATOS DE PRUEBA ADICIONALES - CIUDAD BOLIVAR
-- ============================================================

INSERT INTO PREGRADO_BOLIVAR VALUES
    ('SOC-001','Sociologia',152,3.0,'Ciudad Bolivar'),
    ('TEC-001','Tecnologia en Alimentos',145,3.0,'Ciudad Bolivar');

INSERT INTO CURSO_BOLIVAR VALUES
    ('SOC001-INV',35),('TEC001-ALI',25);

INSERT INTO GRUPO_BOLIVAR VALUES
    ('G-011','SOC001-INV','Investigacion Social',1),
    ('G-012','TEC001-ALI','Tecnologia de Alimentos',1);

INSERT INTO ASIGNATURA_BOLIVAR VALUES
    ('ASG-011','Investigacion Social','SOC-001','SOC001-INV',3),
    ('ASG-012','Tecnologia de Alimentos','TEC-001','TEC001-ALI',5);

INSERT INTO PROFESOR_LOCAL_BOLIVAR VALUES
    ('56789012','Ana Torres','a.torres@udistrital.edu.co'),
    ('67890123','Pedro Ramirez','p.ramirez@udistrital.edu.co'),
    ('78901234','Diana Lopez','d.lopez@udistrital.edu.co'),
    ('89012345','Santiago Herrera','s.herrera@udistrital.edu.co');

-- ============================================================
-- CONSULTAS DE VERIFICACION
-- ============================================================


SELECT * FROM PREGRADO_BOLIVAR;


SELECT * FROM ASIGNATURA_BOLIVAR;

SELECT * FROM PROFESOR_LOCAL_BOLIVAR;

-- FIN DEL SCRIPT
